---
title: "Implementation Discussion"
labels: ["implementation"]
body:
  - type: input
    id: title
    attributes:
      label: "What are you implementing?"
      placeholder: "e.g., User login system"
    validations:
      required: true

  - type: dropdown
    id: status
    attributes:
      label: "Status"
      options:
        - Planning
        - In Progress
        - Done
    validations:
      required: true

  - type: textarea
    id: description
    attributes:
      label: "Describe your implementation"
      placeholder: "What problem does this solve? How will you implement it?"
    validations:
      required: true

  - type: textarea
    id: feedback
    attributes:
      label: "What feedback do you need?"
      placeholder: "What specific help or input are you looking for?"
---