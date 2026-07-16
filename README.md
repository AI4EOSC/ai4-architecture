# AI4EOSC Architecture repository

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13343448.svg)](https://doi.org/10.5281/zenodo.13343448)


This repository contains the [AI4EOSC](https://ai4eosc.eu) project architecture
diagrams. An online read-only version is [available here](https://ai4eosc.eu/ai4-architecture/static-diagrams/static/index.html).

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

To view the interactive diagrams (for both AI4EOSC and the DEEP legacy architecture):

    make

In either case, browse to <http://127.0.0.1:8080> to see what is generated.

To validate (the AI4EOSC architecture):

    make validate

To export the static diagrams in HTML format:

    make generate-static

> To export in PNG/SVG:
>
>     EXPORT_FORMAT=png make generate-static
>
> However this command currently raises:
>
>     12:58:52.068 [main] ERROR com.structurizr.command.ExportCommand -- Exporting to PNG/SVG is not supported in this build
>
> PNG diagrams can nevertheless be manually exported from the interactive server instance.

## License

This work is licensed under a
[Creative Commons Attribution 4.0 International License](https://github.com/AI4EOSC/ai4-architecture/blob/main/LICENSE).

## Acknowledgements

<img width=300 align="left" src="https://raw.githubusercontent.com/AI4EOSC/.github/ai4eosc/profile/EN-Funded.jpg" alt="Funded by the European Union" />

This project has received funding from the European Union’s Horizon Research and Innovation programme under Grant agreement No. [101058593](https://cordis.europa.eu/project/id/101058593)
