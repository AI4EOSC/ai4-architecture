# 6. Use OSCAR for the DEEP as a Service system

Date: 2023-01-10

## Status

Accepted

## Context

After the model has been trained in the platform, we need to deploy it in a 
production environment and host the model on a cloud-based platform, using 
a containerization technology such as Docker. This will allow users to obtain 
insights from the new data collected and take action based on the predictions 
made by the model.


## Decision

The implementation of the DEEP as a Service will be based on the open-source 
[OSCAR](https://oscar.grycap.net) serverless computing platform for data-processing 
applications. Users upload files to an object-storage system (provided by MinIO) 
and this automatically triggers the execution of parallel invocations to a function
(OSCAR service) responsible for processing each file. Output files are delivered into
an output bucket for the convenience of the user. A user-provided shell script is 
executed inside the container run from the user-defined Docker image to achieve 
the right execution environment for the application.

## Consequences

The usage of OSCAR involves also other tools and technologies, like the 
[Infrastructure Manager](https://www.grycap.upv.es/im), to deploy OSCAR on top of an 
elastic Kubernetes cluster dynamically provisioned on any supported Cloud provider. 
For clusters of low-powered devices such as Raspberry PIs, OSCAR can be deployed over 
a minimalistic Kubernetes distribution such as [K3s](https://k3s.io/). Synchronous invocations, required 
for short-lived inference requests, are handled via [KNative](https://knative.dev).
