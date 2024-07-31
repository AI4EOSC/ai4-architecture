# 19. Ease integration with storage systems

Date: 2024-05-01

## Status

Accepted

## Context

Users need to deal with NextCloud credentials when creating a deployment. This
means that users need to go to the NextCloud server, create their credentials,
pencil them down, and then manually include their client ID and secret in the
deployment. This is a UX problem.

## Decision

Register the AI4-PAPI as a NextCloud client using the login flow, and store the
generated ID and secret in the secrets management tool. Populate rClone fields
automatically or via a dropdown menu.

## Consequences

Users do not need to deal with the credentials, as they are stored in the
secrets system. It is possible to register several nexcloud instances, and to
extend it to other storage systems (e.g. ownCloud).
