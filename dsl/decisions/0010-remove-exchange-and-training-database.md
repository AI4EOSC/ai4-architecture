# 10. Remove exchange and training database

Date: 2024-01-01

## Status

Accepted

## Context

The original architecture included two different databases in the design: the
exchange database and the training database. However, we consider that these
are not needed as the exchange is managed via git repositories and the training
database is stored directly as metadata in the workload management system.

## Decision

Remove the database components, but the API implementation should consider that
we may change to an external database in the future, therefore its design
should allow for an easy switch.

## Consequences

No standalone databases are considered for the time being.
