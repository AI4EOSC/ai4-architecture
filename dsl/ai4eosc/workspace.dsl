workspace extends ../eosc-landscape.dsl {
    
    /* !impliedRelationships false */

    name "AI4EOSC"
    description "AI4EOSC architecture"

    model {

        !ref eosc_user {
            description "EOSC user willing to use an AI platform to develop an AI application."
        }

        paas_ops = person "PaaS Operator" "Resource provider operator or platform operator managing the PaaS deployments."

        ai4eosc = enterprise "AI4EOSC" {
            ai4eosc_platform = softwareSystem "AI4EOSC Platform" "Allows EOSC users to develop, build and share AI models." {
                exchange = group "AI4EOSC Exchange" {
                    exchange_api =  container "Exchange API" "Provides exchange functionality via HTTPS/JSON API."
    
                    data_repo = container "Model and data repository" "Track AI models and data sets." "dvc" "repository"
                    model_repo = container "Model code repository" "Track AI model code." "Git" "repository"
                    container_repo = container "Container registry" "Store container images." "DockerHub" "repository" 
    
                    exchange_db = container "Exchange database" "Stores AI4EOSC exchange registered models." "" "database"

                    ci = container "Continuous Integration" "Ensures quality aspects are fulfilled (code checks, unit checks, etc.)."
                    cd = container "Continuous Delivery & Deployment" "Ensures delivery and deployment of new assets."
                }

                model_container = container "Model container" "Encapsulates user code." "Docker" {
                    api = component "API" "" "DEEPaaS API"

                    framework = component "ML/AI framework"

                    user_model = component "User code and model"

                    api -> user_model
                    user_model -> framework
                }

                identity = group "Identity and user management" {

                    iam = container "Identity and Access Management" "Provides user and group management." "INDIGO IAM"
    
                    order = container "Order management system" "Manages orders coming both from the EOSC portal or for new users." ""

                }
                
                dashboard = container "AI4EOSC dashboard" "Provides access to existing modules (anonymous), experiment and training definition (logged users)." "aiohttp" "dashboard"

                training = group "AI4EOSC training" {
                    training_api = container "Training API" "Provides training creation and monitoring functionality via a JSON/HTTPS API." "aiohttp"

                    training_db = container "Training database" "Stores AI4EOSC training requests." "" "database"
    
                    dev = container "Interactive development Environment" "An interactive development environment with access to resources and limited execution time." "Jupyter"
    
                    coe = container "Workload Management System" "Manages and schedules the execution of compute requests." "Hashicorp Nomad"
    
                    resources = container "Compute resources" "Executes user workloads." "Hashicorp Nomad"
                }
            }
            
            orchestration = softwareSystem "PaaS Orchestration and provisioning" "Allows PaaS operators to manage PaaS deployments and resources." {
                paas_dashboard = container "PaaS Dashboard" "Web User Interface that allows to easily interact with the PaaS services" "Flask" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"

                federated_service_catalogue = container "Federated Service Catalogue" "Provides information about the available capabilities offered by the resource (compute and data) providers" 

                monitoring_system = container "Monitoring & Metering System" "Gathers metrics from the different services (status, resource availabilty, performance, etc.)"

                cloud_provider_ranker = container "Cloud Provider Ranker" "Returns the service/resource offers that best fit the deployment requiments"

                im = container "Infrastructure Manager"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"
            }

            deepaas = softwareSystem "DEEP as a Service" "Allows users to deploy an AI application as a service." {
                OSCARSystem = group "OSCAR"{
                    OSCAR = container "OSCAR Manager" 
                    Kubernetes = container "Kubernetes API" 
                    MinIO = container "MinIO" 
                    Knative = container "Knative" 
                    FaaSS = container "FaaS Supervisor" 
                }
            }
        }

        storage = softwareSystem "Storage Services" "External storage where data assets are stored." "external" {
            ESP = group "External Storage Provider"{
                s3 = container "Amazon S3"
                MinIOExternal = container "MinIO External"
                oneData = container "Onedata"
                dcache = container "dCache"
            }
        }
        cloud_providers = softwareSystem "Cloud/HPC Providers" "" external

        end_user = person "User" "An end-user, willing to exploit existing production models."

        # User - system interaction
        eosc_user -> ai4eosc_platform "Reuse, develop, publish new AI models"
        paas_ops -> orchestration "Manage PaaS resources and deployments"
        end_user -> deepaas "Uses deployed models from"
        /* eosc_user -> deepaas "Deploy models as services" */

        # System - system interaction
        orchestration -> ai4eosc_platform "Creates PaaS deployments and provisions resources for"
        orchestration -> deepaas "Provisions resources for"
        ai4eosc_platform -> storage "Consumes data from"
        ai4eosc_platform -> aai "Is integrated with"
        /* ai4eosc_platform -> portal "Is integrated with" */
        ai4eosc_platform -> deepaas "Deploy models on"


        # AI4EOSC platform

        eosc_user -> dashboard "Browse models, train existing model, build new one."

        # Training 
        eosc_user -> dev "Access interactive environments"

        dashboard -> training_api "Define new trainings, check training status, etc. "

        training_api -> coe "Create training job, interactive environment using API calls to"
        training_api -> training_db "Stores training data in"
        training_api -> model_container "Queries training status"

        coe -> resources "Create new task/workload"

        resources -> dev "Create on-demand environments"
        resources -> model_container "Executes user model in a"

        /* eosc_user -> model_container "Trigger new training jobs" */

        exchange_api -> iam "Authenticates users with"
        training_api -> iam "Authenticates users with"
        dashboard -> iam "Authenticates users with" 
            
        dev -> storage "Read data from"
        model_container -> storage "Read data from"

        # User management

        portal -> order "Creates new order/request for services"
        iam -> aai "Federate users from" "OpenID Connect"
        order -> iam "Creates new users for new orders"
        

        # AI4EOSC exchange
        /* eosc_user -> exchange_api "Register new model" */
        dashboard -> exchange_api "Reads available models from"

        exchange_api -> data_repo "Reads from"
        exchange_api -> model_repo "Reads from"
        exchange_api -> container_repo "Reads from"

        eosc_user -> data_repo "Registers data"
        eosc_user -> model_repo "Registers model"
        eosc_user -> container_repo "Registers container"

        ci -> data_repo "Ensures QA aspects"
        ci -> model_repo "Ensures QA aspects"

        cd -> model_repo "Reacts to events from"
        cd -> container_repo "Creates containers"
        cd -> deepaas "Deploys models on"

        data_repo -> storage "Refers to data stored in"

        exchange_api -> exchange_db "Reads from writes to"

        model_container -> container_repo "Stored in"

        orchestration -> resources "Provisions"


        # Orchestration

        paas_ops -> paas_dashboard "Manages AI4EOSC PaaS deployments"
        paas_dashboard -> paas_orchestrator "Create deployment"
        paas_dashboard -> tosca_repo "Read topologies"
        paas_orchestrator -> tosca_repo "Read topologies"
        paas_orchestrator -> im "Uses"
        paas_orchestrator -> federated_service_catalogue "Get information"
        monitoring_system -> federated_service_catalogue "Send aggregated metrics"
        paas_orchestrator -> cloud_provider_ranker "Get matching offers"

        /* paas_orchestrator -> iam "Authenticates users with" */
        /* im -> iam "AuthN/Z" */

        paas_orchestrator -> resources "Provisions resources for"
        cloud_providers -> resources "offer"
        cloud_providers -> federated_service_catalogue "register/update service & resources metadata"
        cloud_providers -> monitoring_system "push/pull metrics"

        paas_orchestrator -> resources "Provisions resources for"
        paas_orchestrator -> Knative "Provisions resources for" 
        paas_orchestrator -> OSCAR "Provisions resources for" 

        # DEEPaaS OSCAR
        OSCAR -> MinIO "Create buckets and folders. Configure event and notifications. Download/ Upload Files. Trigger jobs (webhook events)"
        OSCAR -> Kubernetes "Manage services. Register jobs. Retrieve logs"
        OSCAR -> Knative "Execute services synchronously (optional)"
        FaaSS -> Knative "Assign to function's pod(s)"
        Kubernetes -> FaaSS "Create jobs"
            #FaaSS -> ESP "Upload Output"
        FaaSS -> MinIO "Download input. Upload output"
        FaaSS -> storage "Read/store data"
        FaaSS -> s3 "Read/store data"
        FaaSS -> MinIOExternal "Read/store data"
        FaaSS -> oneData "Read/store data"
        FaaSS -> dcache "Read/store data"

        /* eosc_user -> OSCAR "Requests the depoyment of inference services" */

        ai4eosc_platform -> OSCAR "Deployment of inference services"
        end_user -> OSCAR "Synchronous inference request"
        end_user -> MinIO "Store data for asynchronous inference"

    }

    views {
        theme Default

        terminology {
            enterprise "Project"
            container "Component"
            component "OldComponent"
        }

        branding {
            /* logo "logo.png" */
            font "Roboto" "http://fonts.googleapis.com/css?family=Roboto"
        }

        
        systemLandscape {
            include *
        }

        systemContext ai4eosc_platform {
            include *
            exclude "eosc_user -> data_repo"
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"
        }

        systemContext orchestration {
            include *
        }

        systemContext deepaas {
            include *
        }
        
        container deepaas {
            include *
            exclude "ai4eosc_platform -> storage" 
        }

        
        container ai4eosc_platform {
            include *
            exclude "eosc_user -> data_repo"
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"
        }

        container orchestration {
            include *
            include cloud_providers
        }

        # Dynamic views

        dynamic ai4eosc_platform {
            title "Develop and register a model"
            eosc_user -> dashboard "Requests a development environment"
            dashboard -> iam "Checks user credentials"
            iam -> dashboard "Returns access token"
            dashboard -> training_api "Requests new development enviroment with user access token"
            training_api -> coe "Register new Nomad job, using robot account"
            coe -> resources "Submit Nomad job to Nomad agent on provisioned resources"
            resources -> dev "Executes Development Environment as container"

            dev -> storage "Read and store data from"

            eosc_user -> dev "Develops new model"
            eosc_user -> data_repo
            eosc_user -> model_repo
            eosc_user -> container_repo
            dashboard -> exchange_api "Registers new model"
            /* dashboard -> exchange_api */
            /* exchange_api -> dashboard "Provides list of models" */
        }
        
        dynamic ai4eosc_platform {
            title "Retrain a model"

            eosc_user -> dashboard "Requests available modules"
            dashboard -> iam "Checks user credentials"
            iam -> dashboard "Returns access token"
            dashboard -> training_api "Requests new training job"
            training_api -> coe "Register new Nomad job, using robot account"
            coe -> resources "Submit Nomad job to Nomad agent on provisioned resources"
            resources -> model_container "Executes training job as container"

            storage -> model_container "Read training data"
            model_container -> storage "Write training results"


            /* eosc_user -> dev "Develops new model" */
            /* eosc_user -> data_repo */
            /* eosc_user -> model_repo */
            /* eosc_user -> container_repo */
            /* dashboard -> exchange_api "Registers new model" */
            /* dashboard -> exchange_api */
            /* exchange_api -> dashboard "Provides list of models" */
        }

        styles {
            element "Container" {
                background #008792
                /* color #ffffff */
                /* shape RoundedBox */
            }

            element "Software System" {
                background #ff9db2
                color #000000
            }

            element "Person" {
                background #004f56
            }

#            element "dashboard" {
#                shape WebBrowser
#            }       
#
#            element "repository" {
#                shape Cylinder
#            }
        }
    }
}

