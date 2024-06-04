# 14. Sidecar tasks

Date: 2024-06-04

## Status

Accepted

## Context

The underlying platform allows us to define sidecar tasks (i.e. tasks that run
in parallel with the user tasks) providing additional functionality to the user
tasks. This allows us to implement, transparently, more complex functionality.

## Decision

Include a "Container" with the user job, so that we can draw the different
(user, sidecar, pre, post) tasks.

## Consequences

Consider sidecar tasks when complex functionality is required.
