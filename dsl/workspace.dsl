workspace deep "DEEP-Hybrid-DataCloud architecture" {

    model {
        user = person "AI Scientist"

        deep = enterprise "DEEP-Hybrid-DataCloud" {
            catalog = softwareSystem "DEEP Open Catatalog" {
                marketplace = container "DEEP marketplace" "" "Pelican" "dashboard"

                catalog_repo = container "DEEP Catalog" "" "GitHub" "repository"

                jenkins = container "CI/CD" "" "Jenkins"

                container_repo = container "Container registry" "" "DockerHub" "repository" 
            }

            training = softwareSystem "DEEP Training Facility" {
                dashboard = container "DEEP Dashboard" "" "aiohttp" "dashboard"
                paas_dashboard = container "PaaS Dashboard" "" "Flask" "dashboard"
                a4c = container "Topology Composer" "" "Alien4Cloud" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"
                im = container "Infrastructure Manager"

                coe = container "Container Orchestration Engine" "" "Mesos"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"

                model_container = container "Model container" "" "Docker" {
                    api = component "API" "" "DEEPaaS API"

                    framework = component "ML/AI framework"

                    user_model = component "User code and model"

                    api -> user_model
                    user_model -> framework
                }
            }
            deepaas = softwareSystem "DEEP as a Service" {
                openwhisk = container "Serverless platform" "" "OpenWhisk"
            }
        }

        storage = softwareSystem "Storage Services"

        # User - system interaction
        user -> catalog "Publish and share model"
        user -> training "Build and train deep learning model"
        user -> deepaas "Deploy model as a service"

        # System - system interaction
        catalog -> training "Reuse and extend"
        training -> catalog "Store new model"
        catalog -> deepaas "Publish new service"
        training -> storage "Model results"
        storage -> training "Input data"
        storage -> deepaas "Data and configuration"
        deepaas -> storage "Model results"

        # Container level

        user -> marketplace "Browse and download models"
        user -> catalog_repo "Create/update model"
        marketplace -> catalog_repo "Points to"
        marketplace -> container_repo "Points to"
        catalog_repo -> jenkins "Triggers catalog update"
        jenkins -> marketplace "Generates web page"
        jenkins -> container_repo "Create Docker container"

        user -> dashboard "Train new model or update existing"
        dashboard -> catalog_repo "Read models"
        dashboard -> tosca_repo "Read topologies"

        a4c -> paas_orchestrator "Create topology""
        a4c -> tosca_repo "Read Topologies"

        dashboard -> paas_orchestrator "Create training"
        paas_dashboard -> paas_orchestrator "Create deployment"
        paas_dashboard -> tosca_repo "Read topologies"
        paas_orchestrator -> tosca_repo "Read topologies"
        paas_orchestrator -> im "Uses"

        paas_orchestrator -> coe "Create Container"
        im -> coe "Provisions"

        coe -> model_container "Create"
        user -> model_container "Train/Predict"

        user -> api
#        mesos -> model_container

        deploymentEnvironment "Production" {
            deploymentNode "marketplace.deep-hybrid-datacloud.eu" "" "GitHub Pages" {
                liveMarketplace = containerInstance marketplace
            }
            
            deploymentNode "train.deep-hybrid-datacloud.eu" "" "nginx" {
                liveDashboard = containerInstance dashboard
            }
        }
    }

    views {
        theme Default
        
        systemLandscape {
            include *
        }
        
        container catalog {
            include *
#            autoLayout
        }

        container training {
            include *
        }

        component model_container {
            include *
        }
        
        deployment catalog "Production" {
            include *
        }

        deployment training "Production" {
            include *
        }

        styles {
            element "dashboard" {
                shape WebBrowser
            }       

            element "repository" {
                shape Cylinder
            }
        }
    }
}
