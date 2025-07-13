@description('Azure region where resources will be deployed')
param location string = resourceGroup().location

@description('Name for the ice cream dispenser system')
param dispenserName string = 'icecream-dispenser'

@description('Cone size compatibility setting')
@allowed([
  'small'
  'medium'
  'large'
])
param coneSize string = 'medium'

@description('Enable monitoring and alerts')
param enableMonitoring bool = true

// Storage account for logging dispenser operations
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${dispenserName}storage${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool' // Appropriate for ice cream storage!
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// IoT Hub for managing ice cream dispenser devices
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${dispenserName}-iot-hub'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 2
      }
    }
    routing: {
      endpoints: {
        storageContainers: [
          {
            name: 'dispenser-logs'
            connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
            containerName: 'logs'
            fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
            batchFrequencyInSeconds: 60
            maxChunkSizeInBytes: 10485760
            encoding: 'JSON'
          }
        ]
      }
      routes: [
        {
          name: 'DispenserTelemetryRoute'
          source: 'DeviceMessages'
          condition: 'true'
          endpointNames: [
            'dispenser-logs'
          ]
          isEnabled: true
        }
      ]
    }
  }
}

// Function App for processing ice cream dispensing logic
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${dispenserName}-functions'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${dispenserName}-functions')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'CONE_SIZE_SETTING'
          value: coneSize
        }
        {
          name: 'IOT_HUB_CONNECTION_STRING'
          value: 'HostName=${iotHub.name}.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=${iotHub.listKeys().value[0].primaryKey}'
        }
      ]
    }
  }
}

// App Service Plan for the Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${dispenserName}-plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

// Application Insights for monitoring (if enabled)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (enableMonitoring) {
  name: '${dispenserName}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
  }
}

// Output important connection information
output storageAccountName string = storageAccount.name
output iotHubName string = iotHub.name
output functionAppName string = functionApp.name
output dispenserEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/dispense-ice-cream'

@description('Instructions for cone loading workaround')
output coneLoadingInstructions string = 'Ice cream dispenser deployed successfully! Use the dispenser endpoint to trigger automated cone loading with ${coneSize} cone compatibility.'
