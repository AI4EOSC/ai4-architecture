# 26. FlowFuse to support multitenancy in Node-RED

Date: 2023-09-14

## Status
Accepted

## Context

Node-RED is not multitenant. So, even if we can create user accounts, we cannot operate simultaneously in a single instance to support concurrent users. This discards the approach of having a single instance of Node-RED integrated with the AI4EOSC dashboard.

## Decision

Integrate Flowfuse as the best option to manage multiple instances of Node-RED.

## Consequences

Deploy and administrate a Flowfuse instance for the project.
