# 13. Include secret management system

Date: 2023-10-08

## Status

Accepted

## Context

Several AI4EOSC services require that the users provide a secret (password,
token, etc.) to interact with them. Instead of including them directly in the
deployment, we need to include a secret management system so that we can handle
them correctly.

## Decision

Include a secret management system. Add routes in the API to manage them.

## Consequences

User deployments must interact with the secret management system transparently,
so that secrets are configured, updated and revoked. This includes:

 - Federated servers.
 - Interactive development environment.
