# 6. Replace legacy and unmaintained PaaS components

Date: 2023-01-10

## Status

Accepted

## Context

The PaaS Orchestrator scheduling capability is based on the information provided by the CMDB 
(Configuration Management Database) and the Monitoring System. The CMDB is responsible for 
storing and managing the description of providers and their services, resources, and virtual 
machine images, flavors, and networks. The Monitoring system collects data about the status 
health of the provider services and their performances. These information are then used by 
the Orchestrator to select the best provider for the user deployment.
Both CMDB and the Monitoring system are currently based on legacy, unmaintained software 
components  that represent a risk for the stability and security of the platform.

## Decision

The old, unmaintained and vulnerable components will be replaced with new open-source solutions. 
The new services must be scalable, reliable, and secure, with a focus on data accuracy and consistency. 
This will involve implementing robust data validation and error handling mechanisms, as well as 
appropriate security measures such as authentication and access control.


## Consequences

The new services will be integrated within the PaaS layer.
