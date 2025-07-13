# Ice Cream Cone Loading Workaround

## Overview
This example demonstrates a workaround for efficiently getting ice cream into a cone using Azure infrastructure automation.

## Problem Statement
Traditional ice cream cone loading methods often result in:
- Uneven distribution of ice cream
- Spillage and waste
- Inconsistent cone filling
- Poor customer experience

## Solution
This Bicep template deploys an automated ice cream dispensing system that addresses the cone loading challenges through:
- Precision dispensing controls
- Temperature management
- Automated cone positioning
- Quality assurance monitoring

## Files
- `ice-cream-dispenser.bicep` - Main Bicep template for deploying the ice cream dispensing infrastructure
- `README.md` - This documentation file

## Deployment Instructions
1. Ensure you have Azure CLI installed and configured
2. Navigate to this directory
3. Run the deployment command:
   ```bash
   az deployment group create \
     --resource-group your-resource-group \
     --template-file ice-cream-dispenser.bicep \
     --parameters location=eastus
   ```

## Parameters
- `location` - Azure region for deployment (default: eastus)
- `dispenserName` - Name for the ice cream dispenser instance
- `coneSize` - Size specification for cone compatibility (small/medium/large)

## Expected Outcome
After successful deployment, you will have a fully automated ice cream cone loading system that eliminates common dispensing issues and provides consistent results.
