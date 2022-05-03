# AI4EOSC Architecture repository

## Instructions

The AI4EOSC architecture is based on the [C4 model](https://c4model.com/),
follow the C4 guidelines to record changes into the architecture diagrams.

### Record decisions

Use [`adr-tools`](https://github.com/npryce/adr-tools) to record significant
architecture changes:

    adr new "Descriptive title"
    git add decisions/
    git commit ...


## Generating the architecture

To generate the DEEP legacy architecture:

    STRUCTURIZR_WORKSPACE_PATH=deep make

To generate the AI4EOSC architecture:

    STRUCTURIZR_WORKSPACE_PATH=ai4eosc make

In either case, browse to http://127.0.0.1:8080/workspace/diagrams to see what
is generated.
