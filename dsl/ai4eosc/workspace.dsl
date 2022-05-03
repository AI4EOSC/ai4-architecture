workspace extends ../eosc-landscape.dsl {
    
    name "DEEP-Hybrid-DataCloud"
    description "DEEP-Hybrid-DataCloud legacy architecture"

    model {

        user = person "AI Scientist" "EOSC user willing to use an AI platform to develop an AI application."

        paas_ops = person "PaaS Operator" "Resource provider operator or platform operator managing the PaaS deployments."

        ai4eosc = enterprise "AI4EOSC" {
            catalog = softwareSystem "DEEP Open Catatalog" "Allows users to store and retrieve AI models and related assets." {
                marketplace = container "DEEP marketplace" "" "Pelican" "dashboard"

                catalog_repo = container "DEEP Catalog" "" "GitHub" "repository"

                jenkins = container "CI/CD" "" "Jenkins"

                container_repo = container "Container registry" "" "DockerHub" "repository" 
            }

            user_management = softwareSystem "User management system" "Provides tools to manage platform users and new user requests." {
                iam = container "Identity and Access Management" "" "INDIGO IAM"
            }

            orchestration = softwareSystem "PaaS Orchestration and provisioning" "Allows PaaS operators to manage PaaS deployments and resources." {
                paas_dashboard = container "PaaS Dashboard" "" "Flask" "dashboard"
                
                a4c = container "Topology Composer" "" "Alien4Cloud" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"

                im = container "Infrastructure Manager"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"
            }

            training = softwareSystem "DEEP Training Facility" "Allows users to develop, build and train an AI application." {
                dashboard = container "DEEP Dashboard" "" "aiohttp" "dashboard"
                coe = container "Container Orchestration Engine" "" "Mesos"

                model_container = container "Model container" "" "Docker" {
                    api = component "API" "" "DEEPaaS API"

                    framework = component "ML/AI framework"

                    user_model = component "User code and model"

                    api -> user_model
                    user_model -> framework
                }
            }

            deepaas = softwareSystem "DEEP as a Service" "Allows users to deploy an AI application as a service." {
                openwhisk = container "Serverless platform" "" "OpenWhisk"
                
                deep_connector = container "DEEP - Serverless connector"

                deepaas_container = container "DEEPaaS Containar"
                
                serverless_coe = container "Container Orchestration Engine" "" "Mesos"
            }
        }

        storage = softwareSystem "Storage Services" "External storage where data assets are stored."

        # User - system interaction
        user -> catalog "Publish and share model"
        user -> training "Build and train deep learning model"
        user -> deepaas "Deploy model as a service"

        paas_ops -> orchestration "Manage PaaS resources and deployments"

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

        paas_orchestrator -> iam "AuthN/Z"
        im -> iam "AuthN/Z"
        coe -> iam "AuthN/Z"

        paas_orchestrator -> coe "Create Container"
        im -> coe "Provisions"

        coe -> model_container "Create Containers"
        user -> model_container "Train/Predict"

        model_container -> container_repo "Stored in"

        jenkins -> deep_connector "Trigger update"
        deep_connector -> openwhisk "Create/delete/update actions"
        openwhisk -> serverless_coe "Create container functions"
        openwhisk -> deepaas_container "Redirects to"

        deepaas_container -> model_container "Stored in"
        serverless_coe -> deepaas_container "Creates Containers"

        user -> api

        aai -> iam "Federate users"
#        mesos -> model_container

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

        container deepaas {
            include *
        }

        container orchestration {
            include *
        }

        container user_management {
            include *
        }
        
        component model_container {
            include *
        }
        
#        styles {
#            element "dashboard" {
#                shape WebBrowser
#            }       
#
#            element "repository" {
#                shape Cylinder
#            }
#        }
    }
}

