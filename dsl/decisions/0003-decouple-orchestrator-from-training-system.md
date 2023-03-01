# 3. Decouple orchestrator from training system

Date: 2022-05-03

## Status

Accepted

Extended by [8. Use Nomad as workload management system](0008-use-nomad-as-workload-management-system.md)

## Context

Currently we are using the INDIGO PaaS orchestrator as the tool that provisions
the infrastructure and to submit user tasks (i.e. training and request for new
development environments) acting as the workload management system. This is
sub-optimal, as the PaaS orchestrator is built on a generic way, creating
additional complexity that we must hide in the dashboard (i.e. removing TOSCA
complexity).

## Decision

The decision is to decouple the PaaS orchestration from the user workload
management.

## Consequences

The PaaS orchestrator will be in charge of the provisioning of the AI4EOSC
platform and to provision additional resources when needed. As a side effect,
taking into account the Mesos is deprecated, we propose to utilzie Hashicorp
Nomad as a substitute for the orchestration of containers, acting as the new
workload management system due to its ability to work in distributed scenarios.

A new API must be developed, as an interface between our dashboard and the
workload management system and existing tools must be adapted.
