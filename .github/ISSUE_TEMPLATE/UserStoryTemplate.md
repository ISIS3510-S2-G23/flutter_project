name: 🚀 Feature Request
description: "As a [user], I want [feature] so that [benefit]."
title: "[Feature] "
labels: ["code"]
assignees: []
milestone: "first prototype"

body:
  - type: markdown
    attributes:
      value: "### 📌 Description"

  - type: textarea
    attributes:
      label: "User Story"
      description: "Use the format: As a [user], I want [feature] so that [benefit]."
      placeholder: "Example: As a user, I want a points system to encourage recycling."
  
  - type: markdown
    attributes:
      value: "### 🎯 Acceptance Criteria"
  
  - type: markdown
    attributes:
      value: "### 📌 Possible Solution"

  - type: textarea
    attributes:
      label: "Proposed Solution"
      description: "Describe how this feature could be implemented."
      placeholder: "Example: Implement a Node.js backend with Firebase as the database..."
  
  - type: dropdown
    attributes:
      label: "Size"
      description: "Estimate the task size."
      options:
        - "XS"
        - "S"
        - "M"
        - "L"
        - "XL"
      default: 2
