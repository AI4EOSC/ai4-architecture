# 9. Use a single API endpoint for platform and marketplace

Date: 2023-04-01

## Status

Accepted

## Context

The previous architecture considered two API endpoints: one for exploring the
marketplace, one for interacting with the platform. However, this introduced an
additional complexity to the platform.

## Decision

Merge the two API endpoints into a platform-wide API: AI4-PAPI.

## Consequences

A single API will be developed, including all the required functionality.
