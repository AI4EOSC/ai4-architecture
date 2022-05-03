workspace extends ../eosc-landscape.dsl {
    
#    !impliedRelationships false

    name "DEEP-Hybrid-DataCloud"
    description "DEEP-Hybrid-DataCloud legacy architecture"

    model {


        !ref eosc_user {
            description "EOSC user willing to use an AI platform to develop an AI application."
        }


        paas_ops = person "PaaS Operator" "Resource provider operator or platform operator managing the PaaS deployments."

        ai4eosc = enterprise "AI4EOSC" {
            catalog = softwareSystem "DEEP Open Catatalog" "Allows users to store and retrieve AI models and related assets." {
                marketplace = container "DEEP marketplace" "" "Pelican" "dashboard"

                catalog_repo = container "DEEP Catalog" "" "GitHub" "repository"

                jenkins = container "CI/CD" "" "Jenkins"

                container_repo = container "Container registry" "" "DockerHub" "repository" 

                model_container = container "Model container" "Encapsulates user code." "Docker" {
                    api = component "API" "" "DEEPaaS API"

                    framework = component "ML/AI framework"

                    user_model = component "User code and model"

                    api -> user_model
                    user_model -> framework
                }
            }

            user_management = softwareSystem "User management system" "Provides tools to manage platform users and new user requests." {
                iam = container "Identity and Access Management" "" "INDIGO IAM"
            }

            orchestration = softwareSystem "PaaS Orchestration and provisioning" "Allows PaaS operators to manage PaaS deployments and resources." {
                paas_dashboard = container "PaaS Dashboard" "" "Flask" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"

                im = container "Infrastructure Manager"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"
            }

            training = softwareSystem "Training Facility" "Allows users to develop, build and train an AI application." {

                dashboard = container "Dashboard" "Provides access to experiment and training definiton." "aiohttp" "dashboard"

                training_api = container "Training API" "Provides training creation and monitoring functionality via a JSON/HTTPS API" "aiohttp"

                dev = container "Interactive development Environment" "An interactive development environment with access to resources and limited execution time." "Jupyter"

                coe = container "Workload Management System" "Manages and schedules the execution of compute requests." "Hashicorp Nomad"

                resources = container "Compute resources" "Executes user workloads." "Hashicorp Nomad"
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
        eosc_user -> catalog "Publish and share model"
        eosc_user -> training "Build and train deep learning model"
        eosc_user -> deepaas "Deploy model as a service"
        paas_ops -> orchestration "Manage PaaS resources and deployments"

        # System - system interaction
        orchestration -> training "Create PaaS deployments and provision resources for"
        training -> user_management "Authenticate users with"
        user_management -> aai "Federates users from"

        deepaas -> catalog "Deploys models from"

        training -> catalog "Registers models in"
        training -> storage "Gets model datasets from"


        # Train facility
        eosc_user -> dashboard "Train new or existing model"

        dashboard -> training_api "Makes API calls to "
        dashboard -> catalog_repo "Reads available models from"
        dashboard -> dev "Delivers interactive environments"

        dev -> coe "Create on-demand environments"
        coe -> resources "Execute workload"
        
        training_api -> coe "Create training job/task using API calls to"

        training_api -> iam "Authenticates users with"
        dashboard -> iam "Authenticates users with"
        
        # Container level

        eosc_user -> marketplace "Browse and download models"
        eosc_user -> catalog_repo "Create/update model"
        marketplace -> catalog_repo "Points to"
        marketplace -> container_repo "Points to"
        catalog_repo -> jenkins "Triggers catalog update"
        jenkins -> marketplace "Generates web page"
        jenkins -> container_repo "Create Docker container"


#        dashboard -> tosca_repo "Read topologies"

        paas_dashboard -> paas_orchestrator "Create deployment"
        paas_dashboard -> tosca_repo "Read topologies"
        paas_orchestrator -> tosca_repo "Read topologies"
        paas_orchestrator -> im "Uses"

        paas_orchestrator -> iam "Authenticates users with"
        im -> iam "AuthN/Z"
#        coe -> iam "AuthN/Z"

        paas_orchestrator -> resources "Provisions resources"
#        im -> coe "Provisions"

#
        eosc_user -> model_container "Train/Predict"

        model_container -> container_repo "Stored in"

        jenkins -> deep_connector "Trigger update"
        deep_connector -> openwhisk "Create/delete/update actions"
        openwhisk -> serverless_coe "Create container functions"
        openwhisk -> deepaas_container "Redirects to"

        deepaas_container -> model_container "Stored in"
        serverless_coe -> deepaas_container "Creates Containers"

        eosc_user -> api

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

