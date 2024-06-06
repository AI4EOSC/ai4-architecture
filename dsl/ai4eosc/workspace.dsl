workspace extends ../eosc-landscape.dsl {
    
    /* !impliedRelationships false */

    name "AI4EOSC"
    description "AI4EOSC architecture"

    model {

        !ref eosc_user {
            description "EOSC user willing to use an AI platform to develop an AI application."
        }

        paas_ops = person "PaaS Operator" "Resource provider operator or platform operator managing the PaaS deployments."

        ai4eosc = group "AI4EOSC" {
            ai4eosc_platform = softwareSystem "AI4EOSC Platform" "Allows EOSC users to develop, build and share AI models." {

                /* platform_api = container "Exchange API" "Provides exchange functionality via HTTPS/JSON API." */
                platform_api = container "AI4 Platform API" "Provides marketplace browseing, training creation and monitoring functionality via a JSON/HTTPS API." "FastAPI + python-nomad"

                /* data_repo = container "Model and data repository" "Track AI models and data sets." "dvc" "repository" */
                model_repo = container "Model code repository" "Track AI model code." "Git" "repository"
                container_repo = container "Container registry" "Store container images." "Harbor.io" "repository" 

                cicd = container "Continuous Integration, Delivery & Deployment" "Ensures quality aspects are fulfilled (code checks, unit checks, etc.). Performs delivery and deployment of new assets." "Jenkins"
                
                dashboard = container "AI4EOSC dashboard" "Provides access to existing modules (anonymous), experiment and training definition (logged users)." "Angular" "dashboard"

                coe = container "Workload Management System" "Manages and schedules the execution of compute requests." "Hashicorp Nomad" {
                    networking = component "Ingress service" "Manage ingress rules via reverse proxy" "Traefik"
                }

                federated_server = container "Federated learning server" "Agregates federated client updates" "Docker Nomad Job" {
                    flower = component "Flower" "Federated learning monitoring tool" "Flower.ai"
                    nvflaer = component "NVIDIA Federated Learning" "Federated learning framework" "NVFlare"
                }

                secrets = container "Secret management system" "Manages user secrets" "Hashicorp Vault"

                user_task = container "User job/task deployment" "Encapsulates a user task to be executed in the platform." "Docker Nomad Job" {

                    dev_task = component "Interactive development Environment" "An interactive development environment with access to resources and limited execution time." "Jupyter / VSCode"

                    storage_task = component "Storage task" "Providesa acess to external storage" "Docker"

                    zenodo_task = component "Zenodo task" "Gets dataset from Zenodo DOI" "Docker"

                    deepaas_task = component "DEEPaaS task" "Provides access to prediction/training API" "DEEPaaS API"

                    zenodo_task -> storage_task "Saves data to"
                    storage_task -> dev_task "Provides data to"
                    storage_task -> deepaas_task "Provides data to"
                }

                platform_storage = container "Platform storage services" "Provides storage for the users" "NextCloud"
            
                # This is a special case, added here, but ignored in the view, just to
                # be included in the dynamic view
                /* external_container = container "User-managed model container" "Encapsulates user code, not executed on the platform" "Docker" */ 
                /* external_container -> federated_server "Gets updated model, sends weights to server" */
            }

            mlops = softwareSystem "Machine Learning Operations (MLOps)" "Provides the ability to implement MLOps techniques, as needed from use cases" {
                data_preproc = container "Data preparation" "Prepare and process data for training"
                
                data_validation = container "Data validation" "Validate data (if accurate, complete) before using for training or inference" "database"
                
                # model_monitor = container "Model monitoring" "track the performance of models in production" ""
                
                drift_detection = container "Drift detection" "Detects drifts in model performance"
                
                feedback_loop = container "Feedback loop" "Determines when to trigger a new training job" "DS"
                
                deployment_workflow = container "Deployment workflow" "Deploy the newly trained model to production" "pipeline"
                # production = container "Production stage" "The environment where the model is used for inference"
                
                data_preproc -> data_validation "Validate the prepared data"
            }
            
            orchestration = softwareSystem "PaaS Orchestration and provisioning" "Allows PaaS operators to manage PaaS deployments and resources." {
                iam = container "Identity and Access Management" "Provides user and group management." "INDIGO IAM"

                paas_dashboard = container "PaaS Dashboard" "Web User Interface that allows to easily interact with the PaaS services" "Flask" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"

                federated_service_catalogue = container "Federated Service Catalogue" "Provides information about the available capabilities offered by the resource (compute and data) providers" 

                monitoring_system = container "Monitoring & Metering System" "Gathers metrics from the different services (status, resource availabilty, performance, etc.)"

                cloud_provider_ranker = container "Cloud Provider Ranker" "Returns the service/resource offers that best fit the deployment requiments"

                im = container "Infrastructure Manager"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"
            }
        
            aiaas = softwareSystem "AI as a Service" "Allows users to deploy an AI application as a service." {
                ai4compose = group "AI4Compose"{
                    flowfuse = container "Flowfuse" 
                    jupyter = container "Jupyter Notebook" 
                    elyra = container "Elyra" 
                    nodered = container "Node-RED" 
                }
                OSCARSystem = group "OSCAR"{
                    OSCAR = container "OSCAR Manager" 
                    Kubernetes = container "Kubernetes API" 
                    MinIO = container "MinIO" 
                    Knative = container "Knative" 
                    FaaSS = container "FaaS Supervisor" 
                }
                nodered_repository = container "Node-RED Library" "Contain AI4Compose custom nodes" "Git" "repository"
                ai4compose_repository = container "AI4Compose GitHub repo" "Contain AI4Compose custom nodes" "Git" "repository"
            }
        }

        external_storages = group "External storage services" {
            storage = softwareSystem "Storage Services" "External storage where data assets are stored." "external" {
                ESP = group "External Storage Provider"{
                    s3 = container "Amazon S3"
                    MinIOExternal = container "MinIO External"
                    oneData = container "Onedata"
                    dcache = container "dCache"
                }
            }
    
            zenodo = softwareSystem "Zenodo" "A general-purpose open-access repository developed within the OpenAIRE project and operated by CERN." "external"
        }

        cloud_providers = softwareSystem "Cloud/HPC Providers" "" external

        end_user = person "User" "An end-user, willing to exploit existing production models."

        # System landscape interactions

        ## User - system interaction
        eosc_user -> ai4eosc_platform "Reuse, develop, publish new AI models"
        paas_ops -> orchestration "Manage PaaS resources and deployments"
        end_user -> aiaas "Uses deployed models from"
        eosc_user -> platform_storage "Stores data in"
        /* eosc_user -> aiaas "Deploy models as services" */

        ## System - system interaction
        orchestration -> ai4eosc_platform "Creates PaaS deployments and provisions resources for"
        orchestration -> aiaas "Provisions resources for"
        ai4eosc_platform -> storage "Consumes data from"
        ai4eosc_platform -> aai "Is integrated with"
        ai4eosc_platform -> portal "is Registered in"
        ai4eosc_platform -> aiaas "Deploy models on"

        mlops -> aiaas "Monitors production model"
        mlops -> ai4eosc_platform "Triggers model update/retraining"

    
        # AI4EOSC platform

        eosc_user -> dashboard "Browse models, train existing model, build new one."

        # Training 
        eosc_user -> dev_task "Access interactive environments"
        eosc_user -> deepaas_task "Access DEEPaaS API"
        eosc_user -> federated_server "Access federated learning server"

        dev_task -> secrets "Access user secrets"

        dashboard -> platform_api "Reads available models, defines new trainings, checks training status, etc. "

        platform_api -> coe "Create training job, interactive environment using API calls to"
        /* platform_api -> user_task "Queries training status" */

        platform_api -> secrets "Creates and manages user secrets"
    
        coe -> user_task "Creates and manages"
        coe -> dev_task "Creates and manages"
        coe -> deepaas_task "Creates and manages"
        coe -> zenodo_task "Creates and manages"
        coe -> storage_task "Creates and manages"

        coe -> federated_server "Creates and manages"
        /* user_task -> federated_server "Gets updated model, sends new weights" */
        federated_server -> secrets "Gets secrets for federated server/clients"

        /* eosc_user -> user_task "Trigger new training jobs" */

        platform_api -> aai "Authenticates users with"
        dashboard -> aai "Authenticates users with" 
            
        /* dev_task -> storage "Read data from" */
        user_task -> platform_storage "Reads and writes data from"
        user_task -> storage "Syncs external data from"

        storage_task -> platform_storage "Reads and writes data from"
        storage_task -> storage "Reads and writes data from"

        # AI4EOSC exchange

        /* platform_api -> data_repo "Reads from" */
        platform_api -> model_repo "Reads from"
        platform_api -> container_repo "Reads from"

        /* eosc_user -> data_repo "Registers data" */
        eosc_user -> model_repo "Registers model"
        eosc_user -> container_repo "Registers container"

        /* cicd -> data_repo "Ensures QA aspects" */
        cicd -> model_repo "Ensures QA aspects"
        cicd -> container_repo "Creates containers"
        cicd -> aiaas "Deploys and updates models as services on"

        cicd -> zenodo "Publishes models to"
        model_repo -> zenodo "Publishes models to"
        platform_api -> zenodo "Read available datasets from"

        zenodo_task -> zenodo "Pull dataset from"

        /* data_repo -> storage "Refers to data stored in" */

        coe -> container_repo "Gets Docker containers from"

        orchestration -> coe "Provisions resources for"

        /* mlops -> platform_api "Trigger model update/retraining" */
        /* mlops -> data_repo "Monitor new data available, update model after training" */
        /* mlops -> cicd "Trigger model update" */

        /* /1* # #MLOps --new data available *1/ */
        /* /1* data_preproc -> data_repo "Read datasets or new model updates from" *1/ */ 
        /* /1* /2* ci -> data_validation "integrate validated data" *2/ *1/ */

        /* /1* /2* user_task -> container_repo "Pulls trained model from registry" *2/ *1/ */
        /* /1* user_task -> oscar "Loads model into inference service" *1/ */
        /* /1* /2* oscar -> user_task "Receives prediction requests" *2/ *1/ */

        /* /1* #MLOps --a new trained model *1/ */
        /* deployment_workflow -> cicd "Trigger update of most recent model" */


        /* /1* #mlops other relationships *1/ */
        /* /1* /2* data_repo -> data_validation "Sends data for validation" *2/ *1/ */
        /* data_validation -> drift_detection "Sends validated data for monitoring" */
        /* drift_detection -> feedback_loop "Triggers model retraining" */
        /* feedback_loop -> platform_api "Starts model retraining" */
        /* feedback_loop -> deployment_workflow "Notifies of model retraining" */

        /* drift_detection -> oscar "Monitor deployed model" */
        /* /1* platform_api -> deployment_workflow "Deploys new model" *1/ */
        /* /1* deployment_workflow -> oscar "Updates model in production" *1/ */

        /* /1* platform_api -> drift_detection "Receives model performance metrics" *1/ */
        /* /1* data_validation -> platform_api "Sends validated data for monitoring" *1/ */
  
        /* #     model_monitor -> dashboard "Monitors model performance" */
        /* #     dashboard -> model_monitor "Receives performance metrics" */

        # Orchestration

        paas_ops -> paas_dashboard "Manages AI4EOSC PaaS deployments"
        paas_dashboard -> paas_orchestrator "Create deployment"
        paas_dashboard -> tosca_repo "Read topologies"
        paas_orchestrator -> tosca_repo "Read topologies"
        paas_orchestrator -> im "Uses"
        paas_orchestrator -> federated_service_catalogue "Get information"
        monitoring_system -> federated_service_catalogue "Send aggregated metrics"
        paas_orchestrator -> cloud_provider_ranker "Get matching offers"
        iam -> aai "Federate users from" "OpenID Connect"
        paas_orchestrator -> iam "Authenticate users with"

        /* paas_orchestrator -> iam "Authenticates users with" */
        /* im -> iam "AuthN/Z" */

        // FIXME (not sure of this)
        /* cloud_providers -> user_task "Provides resources for" */
        cloud_providers -> federated_service_catalogue "register/update service & resources metadata"
        cloud_providers -> monitoring_system "push/pull metrics"

        /* paas_orchestrator -> resources "Provisions resources for" */
        paas_orchestrator -> Knative "Provisions resources for" 
        paas_orchestrator -> OSCAR "Provisions resources for" 

        # DEEPaaS OSCAR
        flowfuse -> nodered "Manage instances"
        end_user -> jupyter "Compose pipelines"
        end_user -> flowfuse "Compose pipelines"
        nodered -> OSCAR "Invoke Service and trigger inference"
        jupyter -> elyra "Manage Notebooks"
        elyra -> OSCAR "Invoke Service and trigger inference"
        nodered -> nodered_repository "Obtain custom OSCAR nodes"
        elyra -> ai4compose_repository "Obtain custom OSCAR nodes"

        //ai4compose -> OSCAR "Trigger inference"
        OSCAR -> MinIO "Manage buckets, folders, event and notifications"
        OSCAR -> Kubernetes "Manage services"
        OSCAR -> Knative "Execute services synchronously"
        Knative -> FaaSS "Assign to function's pod(s)"
        Kubernetes -> FaaSS "Create jobs"
        FaaSS -> MinIO "Download input. Upload output"
        /* FaaSS -> storage "Read/store data" */
        /* /1* FaaSS -> s3 "Read/store data" *1/ */
        /* FaaSS -> MinIOExternal "Read/store data" */
        /* FaaSS -> oneData "Read/store data" */
        /* FaaSS -> dcache "Read/store data" */

        /* eosc_user -> OSCAR "Requests the depoyment of inference services" */

        ai4eosc_platform -> OSCAR "Deployment or update of inference services"
        end_user -> OSCAR "Synchronous inference request"
        end_user -> MinIO "Store data for asynchronous inference"
        
        /* deploymentEnvironment "Production" { */
        /*     ifca_instance = deploymentGroup "IFCA Cloud Instance" */
        /*     iisas_instance = deploymentGroup "IISAS Cloud" */
        /*     cnaf_instance = deploymentGroup "INFN-CNAF Cloud" */
        /*     bari_instance = deploymentGroup "INFN-BARI Cloud" */
        /*     incd_instance = deploymentGroup "INCD Cloud" */
        /*     nomad_cluster = deploymentGroup "Nomad Cluster" */
        /*     global = deploymentGroup "Global deployment" */
        /*     federated = deploymentGroup "FL deployment" */

        /*     deploymentNode "GitHub / Gitlab" { */
        /*         containerInstance model_repo global */
        /*         containerInstance data_repo  global */
        /*         containerInstance tosca_repo global */
        /*     } */

        /*     deploymentNode "DockerHub" { */
        /*         containerInstance container_repo global */
        /*     } */

        /*     deploymentNode "IFCA-CSIC" { */
        /*         deploymentNode "IFCA Cloud" "" "OpenStack" { */
        /*             deploymentNode "dasboard.ai4eosc.eu" "" "nginx" { */
        /*                 containerInstance dashboard global */
        /*             } */
                    
        /*             deploymentNode "AI4 Control pane" "" "Kubernetes" { */
        /*                 containerInstance platform_api global */
        /*                 containerInstance exchange_db  global */
        /*                 containerInstance platform_api global,nomad_cluster */
        /*                 containerInstance training_db  global */

        /*                 containerInstance ci           global */
        /*                 containerInstance cd           global */
        /*             } */

        /*             deploymentNode "vm*.cloud.ifca.es" "" "" "" 100 { */
        /*                 containerInstance coe               nomad_cluster,ifca_instance */
        /*                 containerInstance resources         ifca_instance */
        /*                 containerInstance user_task   ifca_instance */
        /*                 containerInstance dev               ifca_instance */
        /*                 containerInstance federated_server  ifca_instance,federated */
        /*             } */

        /*         } */
        /*     } */
            
        /*     deploymentNode "IISAS" { */
        /*         deploymentNode "cloud.ui.sav.sk"  { */
        /*             deploymentNode "vm*" "" "" "" 10 { */
        /*                 iisas_coe = containerInstance coe                   iisas_instance,nomad_cluster */
        /*                 iisas_resources = containerInstance resources       iisas_instance */
        /*                 iisas_container = containerInstance user_task iisas_instance,federated */
        /*                 iisas_dev = containerInstance dev                   iisas_instance */
        /*             } */
        /*         } */
        /*     } */

        /*     deploymentNode "INFN-CNAF" { */
        /*         deploymentNode "cloud.cnaf.infn.it"  { */
        /*             deploymentNode "iam.ai4eosc.eu" "" "nginx" { */
        /*                 containerInstance iam   global */
        /*             } */
        /*             /1* deploymentNode "vm*" "" "" "" 10 { *1/ */
        /*             /1*     cnaf_coe = containerInstance coe                    cnaf_instance *1/ */
        /*             /1*     cnaf_resources = containerInstance resources        cnaf_instance *1/ */
        /*             /1*     cnaf_container = containerInstance user_task  cnaf_instance *1/ */
        /*             /1*     cnaf_dev = containerInstance dev                    cnaf_instance *1/ */
        /*             /1* } *1/ */
        /*             deploymentNode "AI4 Control pane" "" "Kubernetes" { */
        /*                 cnaf_eapi = containerInstance platform_api   cnaf_instance */
        /*                 cnaf_edb = containerInstance exchange_db     cnaf_instance */
        /*                 cnaf_tapi = containerInstance platform_api   cnaf_instance */
        /*                 cnaf_tdb = containerInstance training_db     cnaf_instance */

        /*                 cnaf_ci = containerInstance ci               cnaf_instance */
        /*                 cnaf_cd = containerInstance cd               cnaf_instance */
        /*             } */
        /*         } */
        /*     } */
            
        /*     deploymentNode "INFN-BARI" { */
        /*         deploymentNode "cloud.ba.infn.it"  { */
        /*             deploymentNode "vm*" "" "" "" 10 { */
        /*                 bari_coe = containerInstance coe                    bari_instance,nomad_cluster */
        /*                 bari_resources = containerInstance resources        bari_instance */
        /*                 bari_container = containerInstance user_task  bari_instance,federated */
        /*                 bari_dev = containerInstance dev                    bari_instance */
        /*             } */
        /*             deploymentNode "paas.ai4eosc.eu" "" "nginx" { */
        /*                 containerInstance paas_dashboard                global */
        /*                 containerInstance paas_orchestrator             global */
        /*                 containerInstance im */
        /*                 containerInstance federated_service_catalogue   global */
        /*                 containerInstance monitoring_system             global */
        /*                 containerInstance cloud_provider_ranker         global */
        /*             } */
        /*         } */
        /*     } */

        /*     deploymentNode "External resources" { */
        /*         containerInstance external_container federated */
        /*     } */
        /* } */
    }

    views {
        theme Default

        branding {
            /* logo "logo.png" */
            font "Roboto" "http://fonts.googleapis.com/css?family=Roboto"
        }
        
        systemLandscape system_view {
            include *
            exclude "orchestration -> aai"
        }

        systemContext ai4eosc_platform ai4eosc_view {
            include *
            exclude "orchestration -> aai"
            /* /1* exclude "eosc_user -> data_repo" *1/ */
            /* exclude "eosc_user -> model_repo" */
            /* exclude "eosc_user -> container_repo" */

            /* /1* exclude "ci -> data_validation" *1/ */
            /* /1* exclude "data_repo -> data_validation" *1/ */
            /* exclude "platform_api -> deployment_workflow" */ 
            /* exclude "deployment_workflow -> oscar" */
            /* exclude "data_validation -> platform_api" */
        }

        systemContext orchestration orchestration_view {
            include *
            exclude "ai4eosc_platform -> aai"
        }

        systemContext aiaas aiaas_view {
            include *
        }
        
        systemContext mlops mlops_view {
            include *
        }

        container aiaas aiaas_container_view {
            include *
            /* exclude "ai4eosc_platform -> storage" */ 
        }

        container ai4eosc_platform ai4eosc_container_view {
            include *

            exclude "orchestration -> aai"
        
            /* exclude "external_container" */
            /* exclude "external_container -> federated_server" */

            /* exclude "eosc_user -> data_repo" */
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"

            /* exclude "ci -> data_validation" */
            /* exclude "ci -> mlops" */

            /* exclude "data_repo -> data_validation" */
            /* exclude "data_repo -> mlops" */

            exclude "platform_api -> deployment_workflow" 
            exclude "platform_api -> mlops"

            exclude "deployment_workflow -> oscar"

            exclude "data_validation -> platform_api"

            exclude "user_task -> oscar"
            exclude "user_task -> aiaas"
            exclude "oscar -> user_task"
            exclude "aiaas -> user_task"
        }
        
        container mlops mlops_container_view {
            include *
        }

        container orchestration orchestration_container_view {
            include *
            include cloud_providers
        }

        component user_task user_task_component_view {
            include *

            exclude "coe -> storage_task"
            exclude "coe -> zenodo_task"
        }

        component federated_server fl_component_view {
            include *
        }

        # Dynamic views

        dynamic user_task develop_view {
            title "[Dynamic view] Develop and register a model"
            eosc_user -> dashboard "Requests a development environment"
            dashboard -> aai "Checks user credentials"
            aai -> dashboard "Returns access token"
            dashboard -> platform_api "Requests new development enviroment"
            dashboard -> platform_api "Creates secret for development enviromment"
            platform_api -> secrets "Creates secret in "
            platform_api -> coe "Register new Nomad job"
            coe -> container_repo "Gets container from"
            coe -> storage_task "Creates sidecar storage task for the user"
            coe -> zenodo_task "Creates sync task for Zenodo dataset"
            zenodo_task -> zenodo "Read dataset from"
            zenodo_task -> storage_task "Writes dataset to"

            coe -> dev_task "Executes Development Environment as container"
            dev_task -> secrets "Gets configured user secrets"
            dev_task -> storage_task "Reads and writes from"

            eosc_user -> dev_task "Develops (new/updated) model in"
            eosc_user -> model_repo "Submits new/updated model"
            cicd -> model_repo "Runs platform and user checks"
            cicd -> container_repo "Creates new Docker container"
            cicd -> zenodo "Enables repository integration"
            model_repo -> zenodo "Triggers deposit of code"
        }
        
        /* dynamic ai4eosc_platform manual_retrain_view { */
        /*     title "[Dynamic view] Manually retrain a model" */

        /*     eosc_user -> dashboard "Requests available modules" */
        /*     dashboard -> iam "Checks user credentials" */
        /*     iam -> dashboard "Returns access token" */
        /*     dashboard -> platform_api "Requests new training job" */
        /*     platform_api -> coe "Register new Nomad job, using robot account" */
        /*     coe -> resources "Submit Nomad job to Nomad agent on provisioned resources" */
        /*     resources -> user_task "Executes training job as container" */

        /*     storage -> user_task "Read training data" */
        /*     user_task -> storage "Write training results" */
        /* } */

        /* dynamic ai4eosc_platform federated_train_view { */
        /*     title "[Dynamic view] Federated learning scenario" */

        /*     eosc_user -> dashboard "Requests available modules" */
        /*     dashboard -> iam "Checks user credentials" */
        /*     iam -> dashboard "Returns access token" */

        /*     dashboard -> platform_api "Requests new federated learning job" */
        /*     platform_api -> coe "Register new federated learning Nomad job, using robot account" */
        /*     coe -> federated_server "Deploy federated learning server" */
        /*     platform_api -> federated_server "Get federated learning server credentials to interact with it" */

        /*     platform_api -> coe "Register new training Nomad job, using robot account" */
        /*     coe -> resources "Submit Nomad job to Nomad agent on provisioned resources" */
        /*     resources -> user_task "Executes training job as container" */

        /*     user_task -> federated_server "Get updated model, using server credentials" */
        /*     user_task -> federated_server "Send updates to server, using server credentials" */
            
        /*     external_container -> federated_server "Get updated model, using server credentials" */
        /*     external_container -> federated_server "Send updates to server, using server credentials" */

        /*     platform_api -> federated_server "Query federated learning status" */

        /*     storage -> user_task "Read training data" */
        /*     user_task -> storage "Write training results" */
        /* } */

        /* /1* dynamic ai4eosc_platform automatic_retrain_view { *1/ */
        /* /1*     title "[Dynamic view] Automatically retrain a model through MLOps" *1/ */

        /* /1*     /2* data_repo -> data_preproc "Notifies of new data" *2/ *1/ */
        /* /1*     /2* data_preproc -> data_validation "foo" *2/ *1/ */
        /* /1*     /2* eosc_user -> dashboard "Requests available modules" *2/ *1/ */
        /* /1*     /2* dashboard -> iam "Checks user credentials" *2/ *1/ */
        /* /1*     /2* iam -> dashboard "Returns access token" *2/ *1/ */
        /* /1*     /2* dashboard -> platform_api "Requests new training job" *2/ *1/ */
        /* /1*     /2* platform_api -> coe "Register new Nomad job, using robot account" *2/ *1/ */
        /* /1*     /2* coe -> resources "Submit Nomad job to Nomad agent on provisioned resources" *2/ *1/ */
        /* /1*     /2* resources -> user_task "Executes training job as container" *2/ *1/ */

        /* /1*     /2* storage -> user_task "Read training data" *2/ *1/ */
        /* /1*     /2* user_task -> storage "Write training results" *2/ *1/ */

        /* /1*     #mlops --new data *1/ */
            
        /* /1*     /2* data_preproc -> data_repo "Retrieves new data" *2/ *1/ */
        /* /1*     #data_repo -> data_preproc "Retrieves data" *1/ */
        /* /1*     /2* data_preproc -> dev "Preprocesses data" *2/ *1/ */
        /* /1*     #dev -> platform_api "Starts training job" *1/ */
        /* /1*     #platform_api -> drift_detection "Receives model performance metrics" *1/ */
     

        /* /1*     # *1/ */
        /* /1*     /2* user_task -> container_repo "Push trained model to registry" *2/ *1/ */
        /* /1*     /2* user_task -> oscar "Loads model into inference service" *2/ *1/ */
        /* /1*     /2* oscar -> user_task "Receives recent prediction requests" *2/ *1/ */
      

            


        /* /1*     /2* eosc_user -> dev "Develops new model" *2/ *1/ */
        /* /1*     /2* eosc_user -> data_repo *2/ *1/ */
        /* /1*     /2* eosc_user -> model_repo *2/ *1/ */
        /* /1*     /2* eosc_user -> container_repo *2/ *1/ */
        /* /1*     /2* dashboard -> platform_api "Registers new model" *2/ *1/ */
        /* /1*     /2* dashboard -> platform_api *2/ *1/ */
        /* /1*     /2* platform_api -> dashboard "Provides list of models" *2/ *1/ */
        /* /1* } *1/ */
        
        /* dynamic deepaas oscar_dynamic { */
        /*     title "[Dynamic view] OSCAR dynamic view" */
        /*     end_user -> OSCAR "Deploy service" */
        /*     OSCAR -> MinIO "Buckets and folders will be created" */
        /*     end_user -> MinIO "Store data for asynchronous inference (Option A)" */
        /*     OSCAR -> Knative "Execute services synchronously (Option B)" */
        /*     OSCAR -> Kubernetes "Manage services. Register jobs. Retrieve logs (Option A)" */
        /*     Kubernetes -> FaaSS "Create jobs (Option A)" */
        /*     Knative -> FaaSS  "Assign to function's pod(s). (Option B)" */
        /*     FaaSS -> MinIO "Download input. Upload output." */
        /*     FaaSS -> storage "Read/store data " */
        /* } */

        /* #Another dynamic view */
        /* dynamic ai4eosc_platform model_data_drift { */
        /*     title "[Dynamic view] Managing Model/Data Drift" */
 
        /*     /1* data_preproc -> data_repo "Read data updates from" *1/ */
        /*     /1* data_preproc -> data_validation "Sends data for validation" *1/ */
        /*     /1* data_validation -> platform_api "Sends validated data for monitoring" *1/ */
        /*     /1* platform_api -> drift_detection "Detects drift in model performance" *1/ */
        /*     /1* drift_detection -> feedback_loop "Triggers model retraining" *1/ */
        /*     /1* feedback_loop -> platform_api "Starts model retraining" *1/ */
        /*     /1* platform_api -> deployment_workflow "Deploys new model" *1/ */
        /*     /1* deployment_workflow -> oscar "Updates model in production" *1/ */
        /* } */ 
        
        /* deployment * "Production" production_deployment { */
        /*     include * */
        /*     /1* autoLayout *1/ */
        /* } */

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

