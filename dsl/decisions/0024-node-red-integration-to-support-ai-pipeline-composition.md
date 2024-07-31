# 24. Node-RED integration to support AI pipeline composition

Date: 2023-04-28

## Status
Accepted

## Context
In the quest of searching for solutions to support the graphical composition of AI pipelines, Node-RED appears
as the most popular flow-based programming tool.

## Decision
Adopt Node-RED as the main solution to support the graphical composition of AI pipelines, leveraging the
execution of the inference phase to OSCAR.

## Consequences
Develop custom nodes to execute AI models in OSCAR and contribute with them to the public Node-RED Library.
