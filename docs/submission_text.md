# Hackathon Submission Text

## Project Title

SoloBob Supply Chain Copilot

## Selected Problem Statement

Domain-Specific AI Copilot

## Short Description

SoloBob Supply Chain Copilot is an AI-powered supply chain decision-support system built on Snowflake. It helps managers detect inventory risks, identify supplier-related causes, and generate actionable replenishment recommendations through an end-to-end Snowflake workflow.

## Problem Statement

Supply chain teams often need to make fast inventory decisions, but operational data is fragmented across inventory, sales, supplier, and delivery systems. This makes it difficult to detect stockout risks early and take timely replenishment actions.

## Solution

SoloBob centralizes supply chain data in Snowflake and applies a modular copilot workflow to classify inventory risk, explain supplier delays, recommend reorder quantities, generate urgent alerts, and produce a manager-ready brief.

## Key Features

- Inventory risk classification
- Supplier delay analysis
- Recommended reorder quantity
- Critical alert generation
- Action log creation
- Workflow run history
- Manager brief
- Streamlit dashboard
- CoCo / Cortex Code natural language demo prompts
- Modular agent skills

## How It Uses Snowflake

- Snowflake SQL stores and analyzes supply chain data.
- Snowflake views transform raw data into risk analysis and recommendations.
- A Snowflake stored procedure runs the end-to-end copilot workflow.
- Streamlit in Snowflake provides the user interface.
- Snowflake CoCo / Cortex Code supports natural language interaction with the data and workflow.

## Business Impact

The system helps supply chain managers identify urgent stockout risks earlier, understand supplier-related causes, prioritize replenishment actions, and reduce manual analysis time.

## Technical Execution

The solution contains structured tables, analytical views, a stored procedure, workflow logging, alert generation, Streamlit UI, and agent skill documentation. It is designed as a complete end-to-end decision workflow rather than a simple chatbot.
