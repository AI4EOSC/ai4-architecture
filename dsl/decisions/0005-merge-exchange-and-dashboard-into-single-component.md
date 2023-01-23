# 5. Merge exchange and dashboard into single component

Date: 2023-01-23

## Status

Accepted

## Context

The current architecture has two different components that provide more or less
the same information: The model marketplace and the training dashboard. The
former is basically read-only ccontent, and the latter is where users develop
their models.

## Decision

Since the training dashboard also offers access to existing models (for
retraining), it makes sense to have a single component with different views:
anonymous to serve the marketplace contents, authenticated to allow training
and development.

## Consequences

A single component will be maintained, withour the need for two separate
portals. Information presentation will be more consistent. Besides, new APIs
need to be developed.
