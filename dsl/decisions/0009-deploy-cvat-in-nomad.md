# 9. Deploying CVAT in Nomad

Date: 2024-06-01

## Status

Accepted

## Context

There were two possibilities to deploy CVAT for users:

1) deploy per-user CVAT
2) deploy platform-wide CVAT

And we have to fullfil the following requirements:

**Requirement 1**: we need persistence if we don't want to constantly
regenerate users and annotation tasks

- with option 1:
  possible, saving the database to Nextcloud.

- with option 2:
  straithforward

**Requirement 2**: we need Nextloud to save annotations

- with option 1:
  possible, as we are mounting the virtual filesystem ourselves in /storage.

- with option 2:
  not possible as Nextcloud is not a supported storage in CVAT. And we
  cannot mount the user-specific storage as earlier because this is
  platform-wide.


**Requirement 3**: we have to support EGI authentication

- with option 1:
  Straightforward, as authentication is done from the Dashboard

- with option 2:
  in theory only supported in the entreprise version. But this can
  (possibly?) be overcomed by using a reverse proxy to create users, like
  in the MLflow instance. Maybe can be implmented using CVAT API?


**Summary**:
Only Req.3 is a real hard requirement, while Req.1/2 are more like
convenient features.

So the voting is among:

Option 1:
- persistence
- not latest CVAT (more maintenance work in the Nomad job if we want to
  keep it updated - though no big changes expected)
- dedicated resources
- straightforward EGI integration
- Nextcloud support via virtual filesystem mounting

Option 2:
- persistence
- latests CVAT
- shared resources
- more work initially to support EGI (thought possibly some work can be
  reused from MLflow)
- Nextcloud not supported


## Decision

Option (1) is the clear winner.

## Consequences

Users will be able to choose to launch a CVAT instance from the Dashboard
and this will be deployed in the Nomad platform.
