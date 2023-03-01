# 8. Use Nomad as workload management system

Date: 2023-02-01

## Status

Accepted

Extends [3. Decouple orchestrator from training system](0003-decouple-orchestrator-from-training-system.md)

## Context

The DEEP platform used Apache Mesos and the INDIGO PaaS orchestrator to execute
the user training jobs. Apache Mesos is now being phased out, and therefore a
new solution needs to be integrated.

## Decision

AI4EOSC will use Hashicorp Nomad (and related tools like Consul) to deliver a
platform layer where the user workloads will be executed. Nomad provides
distributed scheduling across multiple sites, and a much simpler management
when compared with analogous orchestration engines, like Kubernetes.

## Consequences

A new API will be delivered for the AI4EOSC platform, as already explained in
[Decision 3](0003-decouple-orchestrator-from-training-system.md). This API will
therefore interact with the Nomad userver, using a robot account approach (i.e.
a single user submitting jobs on behalf of the original user), embedding the
needed metadata in the Nomad job.
