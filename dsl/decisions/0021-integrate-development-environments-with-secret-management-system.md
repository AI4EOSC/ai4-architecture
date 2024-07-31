# 21. Integrate development environments with secret management system

Date: 2024-06-30

## Status

Accepted

## Context

Users need to define a secret for their development environments. This secret
is hardcoded in the job, therefore it cannot be changed if compromised and it
cannot be viewed after the deployment is created.

## Decision

Integrate the development environments with the secret management system, so
that the secret is stored in it.

## Consequences

This change will allow users to check the configured secret after the
deployment is created. Moreover, we can use the secret when redirecting users
to the deployment, thus avoiding to introduce it manually.
