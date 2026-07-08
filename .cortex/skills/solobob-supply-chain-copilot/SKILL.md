---
name: solobob-supply-chain-copilot
description: Use this skill when working with the SoloBob Supply Chain Copilot Snowflake project. It explains the domain logic, key tables, risk scoring, agent workflow, and recommended demo prompts.
---

# SoloBob Supply Chain Copilot Skill

## Purpose

This skill helps Cortex Code understand the SoloBob Supply Chain Copilot project. The project is a domain-specific AI copilot for supply chain managers. It analyzes inventory, sales, supplier, and delivery data to detect stockout risks and generate actionable replenishment recommendations.

## Snowflake Context

Use these objects:

- Warehouse: `SOLOBOB_WH`
- Database: `SOLOBOB_DB`
- Schema: `SUPPLY_CHAIN`

Core tables:

- `PRODUCTS`
- `INVENTORY`
- `SALES`
- `SUPPLIERS`
- `DELIVERIES`

Analysis views:

- `INVENTORY_RISK_ANALYSIS`
- `ACTION_RECOMMENDATIONS`
- `MANAGER_BRIEF`
- `EXECUTIVE_SUMMARY`
- `COPILOT_DASHBOARD`

Workflow objects:

- `RUN_SOLOBOB_COPILOT()`
- `COPILOT_ACTION_LOG`
- `COPILOT_ALERTS`
- `COPILOT_RUN_LOG`

Documentation tables:

- `COPILOT_AGENT_SKILLS`
- `COPILOT_WORKFLOW_STEPS`
- `COPILOT_DEMO_QUESTIONS`

## Agent Skills

### Inventory Risk Analysis Skill
Analyze current stock, safety stock, reorder point, monthly sales, and average weekly sales to classify product-level inventory risk.

### Supplier Delay Intelligence Skill
Analyze delayed deliveries, average delay days, and supplier reliability score to explain whether supplier performance contributes to risk.

### Replenishment Recommendation Skill
Rank products as `URGENT`, `REVIEW SOON`, or `MONITOR`, then recommend order quantities and manager actions.

## Risk Logic

- `HIGH RISK`: current stock is below safety stock, delivery is delayed, and average weekly sales are high.
- `MEDIUM RISK`: current stock is below reorder point or supplier delivery is delayed.
- `LOW RISK`: inventory appears stable.

## Demo Questions

Use these prompts:

1. Which products are at highest inventory risk?
2. Why is Bluetooth Speaker considered high risk?
3. Which products should we reorder first?
4. Give me a manager summary of current supply chain risks.
5. Which supplier is causing the most operational concern?

## Preferred Answer Style

When answering about this project, focus on business value and evidence from the data. Use product names, stock levels, sales velocity, supplier delay, and reliability score. End with manager-ready recommendations.

