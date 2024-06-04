# 11. Reorganize exchange services

Date: 2024-01-01

## Status

Accepted

## Context

The original exchange design considered three different registries and
repositories:

 - Model and data repository.
 - Model code repository.
 - Container registry.
 - Exchange database.

Besides, the exchange considered two differnet services:

 - Continuous Integration
 - Continuous delivery and Deployment

## Decision

Data is handled externally by the users, via dvc or other tools. Models (i.e.
weights) should be handled by another component (i.e. MLOps). CI and CD are
merged into a single component.

## Consequences

Some services are removed or merged, new services are included.
