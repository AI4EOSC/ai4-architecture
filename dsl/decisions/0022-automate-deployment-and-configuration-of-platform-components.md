# 22. Automate deployment and configuratioN of platform components

Date: 2023-09-01

## Status

Accepted

## Context

Including resources into an existing system or deploying a new one is not a trivial task.

## Decision

Leverage automation via Ansible roles, TOSCA templates, PaaS orchestrator and
IM in order to ease the management of the platform resources from an operator
point of view.

## Consequences

Easier manamgement of resources from provider/operator point of view. Easier to
include additional resources when needed.
