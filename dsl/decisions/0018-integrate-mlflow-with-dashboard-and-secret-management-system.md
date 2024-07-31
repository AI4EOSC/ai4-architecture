# 18. Integrate MLFlow with dashboard and secret management system

Date: 2024-06-20

## Status

Accepted

## Context

MLFlow requires that users register individually (OpenID Connect is not yet supported) and this requires an additional step. Moreover, users need to remember the MLFlow password to interact with it. This has been alleviated to an extent by auto-registering users through an enrolment page.

## Decision

MLFlow will be integrated with the secrets management tool, so that user secrets (i.e. MLFlow password) will be stored in it.

## Consequences

MLFLow secret management will be done via the platform API and the secrets service, making it more coherent.
