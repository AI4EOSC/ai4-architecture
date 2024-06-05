# AI4EOSC Architecture repository

This repository contains the [AI4EOSC](https://ai4eosc.eu) project architecture
diagrams.

## Instructions

The AI4EOSC architecture is based on the [C4 model](https://c4model.com/),
follow the C4 guidelines to record changes into the architecture diagrams.

### Record decisions

Use [`adr-tools`](https://github.com/npryce/adr-tools) to record significant
architecture changes:

    adr new "Descriptive title"
    git add dsl/decisions/
    git commit ...


## Generating the architecture

To generate the DEEP legacy architecture:

    STRUCTURIZR_WORKSPACE_PATH=deep make

To generate the AI4EOSC architecture:

    STRUCTURIZR_WORKSPACE_PATH=ai4eosc make

In either case, browse to http://127.0.0.1:8080/workspace/diagrams to see what
is generated.

## License

This work is licensed under a
[Creative Commons Attribution 4.0 International License](https://github.com/AI4EOSC/ai4-architecture/blob/main/LICENSE).

## Acknowledgements

<img width=300 align="left" src="https://github.com/AI4EOSC/.github/raw/main/profile/EN-Funded.jpg" alt="Funded by the European Union" />

This project has received funding from the European Union’s Horizon Research and Innovation programme under Grant agreement No. 101058593
