# 23. Gather platform level and user statistics

Date: 2023-12-01

## Status

Accepted

## Context

Users have difficulties to know how many resources they are using, or they have
consumed. Reporting becomes a cumbersome and manual task.

## Decision

Implement an `stats` endpoint in the API, and the corresponding view in the
dashboard, so that it is easier to provide statistics both for users and for
platform operators. Implement tasks in the cluster to collect statistics.

## Consequences

Reporting becomes easier, users are aware of resource consumption.
