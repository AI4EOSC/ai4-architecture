workspace extends ../eosc-landscape.dsl {
    
    /* !impliedRelationships false */

    name "AI4EOSC"
    description "AI4EOSC architecture"

    model {

        !element eosc_user {
            description "EOSC user willing to use an AI platform to develop an AI application."
        }

        paas_ops = person "PaaS Operator" "Resource provider operator or platform operator managing the PaaS deployments."

        ai4eosc = group "AI4EOSC" {
            ai4eosc_platform = softwareSystem "AI4EOSC Platform" "Allows EOSC users to develop, build and share AI models." {

                platform_api = container "AI4 Platform API" "Provides marketplace browseing, training creation and monitoring functionality via a JSON/HTTPS API." "FastAPI + python-nomad"

                model_repo = container "AI4 module repository" "Track AI model and AI4EOSC code integration." "Git" "repository"
                container_repo = container "AI4 container registry" "Store container images." "Harbor.io" "repository" 

                cicd = container "Continuous Integration, Delivery & Deployment" "Ensures quality aspects are fulfilled (code checks, unit checks, etc.). Performs delivery and deployment of new assets." "Jenkins" {
                    #drift_monitoring = component "Drift Monitoring" "Monitors data and model drift; alerts whenever a drift is detected" "DriftWatch" 
                    qa_pipeline = component "AI4OS QA Pipeline" "Ensures quality aspects are fulfilled (code checks, unit checks, etc.)" "Jenkins"
                    user_pipeline = component "User QA Pipeline" "Runs user-defined QA checks" "Jenkins"
                    
                }
                
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
                
                mlflow = container "MLflow" "Tracks experiments and manages model versions" {
                    TrackingServer = component "Tracking Server" "Logs and queries experiments"
                    ArtifactStore = component "Artifact Store" "Stores model artifacts and related files"
                    ModelRegistry = component "Model Registry" "Manages model versions and stages"
                }
                drift_monitoring = container "DriftWatch" "Monitors drift; alerts whenever a drift is detected" "python client" {
                        Frouros = component "Frouros" "Detects data and model drift (python lib)" 
                    }
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
                
        external_resources = softwareSystem "External resources" "External resources, not controlled by the platform" "external" {
            external_container = container "User-managed model code" "Encapsulates user code, not executed on the platform" "" 
            external_container -> federated_server "Gets updated model, sends weights to federated server"
        }
        cloud_providers = softwareSystem "Cloud/HPC Providers" "" external

        end_user = person "User" "An end-user, willing to exploit existing production models."

        # System landscape interactions

        ## User - system interaction
        eosc_user -> ai4eosc_platform "Reuse, develop, publish new AI models"
        paas_ops -> orchestration "Manage PaaS resources and deployments"
        end_user -> aiaas "Uses deployed models from"
        eosc_user -> platform_storage "Stores data in"

        ## System - system interaction
        orchestration -> ai4eosc_platform "Creates PaaS deployments and provisions resources for"
        orchestration -> aiaas "Creates OSCAR clusters and provisions resources for"
        ai4eosc_platform -> storage "Consumes data from"
        ai4eosc_platform -> aai "Is integrated with"
        ai4eosc_platform -> portal "is Registered in"
        ai4eosc_platform -> aiaas "Deploy models on"
    
        # AI4EOSC platform
        eosc_user -> dashboard "Browse models, train existing model, build new one."

        # Training 
        eosc_user -> dev_task "Access interactive environments"
        eosc_user -> deepaas_task "Access DEEPaaS API"
        eosc_user -> federated_server "Access federated learning server"

        dev_task -> secrets "Access user secrets"

        dashboard -> platform_api "Reads available models, defines new trainings, checks training status, etc. "

        platform_api -> coe "Create training job, interactive environment using API calls to"

        platform_api -> secrets "Creates and manages user secrets"
    
        coe -> user_task "Creates and manages"
        coe -> dev_task "Creates and manages"
        coe -> deepaas_task "Creates and manages"
        coe -> zenodo_task "Creates and manages"
        coe -> storage_task "Creates and manages"

        coe -> federated_server "Creates and manages"
        federated_server -> secrets "Gets secrets for federated server/clients"
        dev_task -> federated_server "Gets updated model, sends new weights"

        platform_api -> aai "Authenticates users with"
        dashboard -> aai "Authenticates users with" 
            
        user_task -> platform_storage "Reads and writes data from"
        user_task -> storage "Syncs external data from"

        storage_task -> platform_storage "Reads and writes data from"
        storage_task -> storage "Reads and writes data from"

        # AI4EOSC exchange

        platform_api -> model_repo "Reads from"
        platform_api -> container_repo "Reads from"

        eosc_user -> model_repo "Registers module"
        eosc_user -> container_repo "Registers container"

        cicd -> model_repo "Ensures QA aspects"
        cicd -> container_repo "Creates containers"
        cicd -> aiaas "Deploys and updates models as services on"

        cicd -> zenodo "Publishes models to"
        model_repo -> zenodo "Publishes modules to"
        platform_api -> zenodo "Read available datasets from"

        zenodo_task -> zenodo "Pull dataset from"

        coe -> container_repo "Gets Docker containers from"

        orchestration -> coe "Provisions resources for"

        # QA
        qa_pipeline -> model_repo "Runs platform-defined QA checks on"
        qa_pipeline -> container_repo "Publishes container images to"
        qa_pipeline -> zenodo "Publishes models and code to"
        user_pipeline -> model_repo "Runs user-defined QA checks on"
        drift_monitoring -> model_repo "Monitors drift on"


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

        cloud_providers -> federated_service_catalogue "register/update service & resources metadata"
        cloud_providers -> monitoring_system "push/pull metrics"

        paas_orchestrator -> Knative "Provisions resources for" 
        paas_orchestrator -> OSCAR "Provisions resources for" 
        im -> OSCAR "Manages"

        # DEEPaaS OSCAR
        flowfuse -> nodered "Manage instances"
        end_user -> jupyter "Compose pipelines"
        end_user -> flowfuse "Compose pipelines"
        nodered -> OSCAR "Invoke Service and trigger inference"
        jupyter -> elyra "Manage Notebooks"
        elyra -> OSCAR "Invoke Service and trigger inference"
        nodered -> nodered_repository "Obtain custom OSCAR nodes"
        elyra -> ai4compose_repository "Obtain custom OSCAR nodes"

        OSCAR -> MinIO "Manage buckets, folders, event and notifications"
        OSCAR -> Kubernetes "Manage services"
        OSCAR -> Knative "Execute services synchronously"
        Knative -> FaaSS "Assign to function's pod(s)"
        Kubernetes -> FaaSS "Create jobs"
        FaaSS -> MinIO "Download input. Upload output"

        ai4eosc_platform -> OSCAR "Deployment or update of inference services"
        end_user -> OSCAR "Synchronous inference request"
        end_user -> MinIO "Store data for asynchronous inference"


        # Some MLFlow + Drift interactions
        dev_task -> mlflow "Logs experiment parametres, metrics, models to MLFlow"
        eosc_user -> mlflow "Tracks and visualizes model performance"
        mlflow -> secrets "Gets secrets for tracking server users"
        mlflow -> cicd "Detects new model version in Model Registry"
        drift_monitoring -> cicd "Triggers the pipeline upon detecting drift (potential retrain)"

        drift_monitoring -> dashboard "Updates dashboard with drift status"
        drift_monitoring -> eosc_user "Visualize model performance"  
       
        production = deploymentEnvironment "Production" {
            ifca_instance = deploymentGroup "IFCA Cloud Instance"
            iisas_instance = deploymentGroup "IISAS Cloud"
            cnaf_instance = deploymentGroup "INFN-CNAF Cloud"
            incd_instance = deploymentGroup "INCD Cloud"

            nomad_cluster = deploymentGroup "Nomad Cluster"
            global = deploymentGroup "Global deployment"
            federated = deploymentGroup "FL deployment"

            deploymentNode "GitHub / Gitlab" {
                containerInstance model_repo global
                /* containerInstance ai4compose_repository global */
                containerInstance nodered_repository global
            }

            /* deploymentNode "DockerHub" { */
            /*     containerInstance container_repo global */
            /* } */

            deploymentNode "IFCA-CSIC" {
                deploymentNode "IFCA Cloud" "" "OpenStack" {
                    deploymentNode "dashboard.cloud.ai4eosc.eu" "" "nginx" {
                        containerInstance dashboard global
                    }
                    /* deploymentNode "tutorials.cloud.ai4eosc.eu" "" "nginx" { */
                    /*     containerInstance dashboard global */
                    /* } */
                    /* deploymentNode "dashboard.dev.ai4eosc.eu" "" "nginx" { */
                    /*     containerInstance dashboard global */
                    /* } */

                    deploymentNode "api.cloud.ai4eosc.eu" "" "FastAPI" {
                        containerInstance platform_api global,ifca_instance
                    }
                    /* deploymentNode "api.dev.ai4eosc.eu" "" "FastAPI" { */
                    /*     containerInstance platform_api global */
                    /* } */

                    deploymentNode "jenkins.services.ai4os.eu" "" "Jenkins" {
                        containerInstance cicd global
                    }
                    
                    deploymentNode "share.services.ai4os.eu" "" "NextCloud" {
                        containerInstance platform_storage global
                    }
                    
        /*             deploymentNode "AI4 Control pane" "" "Kubernetes" { */
        /*                 containerInstance platform_api global */
        /*                 containerInstance exchange_db  global */
        /*                 containerInstance platform_api global,nomad_cluster */
        /*                 containerInstance training_db  global */

        /*                 containerInstance ci           global */
        /*                 containerInstance cd           global */
        /*             } */

                    deploymentNode "driftwatch.dev.ai4eosc.eu" "" "DriftWatch" {
                        containerInstance drift_monitoring global
                    }
                    nomad_cluster_ifca = deploymentNode "vm*.cloud.ifca.es" "" "" "" 100 {
                        ifca_coe = containerInstance coe            nomad_cluster,ifca_instance
                        containerInstance user_task                 ifca_instance,global
                        containerInstance federated_server          ifca_instance,federated
                    }

                }
            }

            deploymentNode "INCD" {
                deploymentNode "stratus.ncg.ingrid.pt" {
                    deploymentNode "registry.services.ai4os.eu" "" "Harbor" {
                        registry_incd = containerInstance container_repo global
                    }
                    deploymentNode "mlflow.cloud.ai4eosc.eu" "" "MLflow" {
                        containerInstance mlflow global
                    }
                    deploymentNode "inference.cloud.ai4eosc.eu" "" "OSCAR" {
                        containerInstance OSCAR global
                        /* containerInstance KNative global */
                        /* containerInstance MinIO global */
                        /* containerInstance FaaSS global */
                    }
                    deploymentNode "forge.flows.dev.ai4eosc.eu" "" "Flowfuse" {
                        containerInstance flowfuse global
                        containerInstance nodered global
                    }
                    deploymentNode "console.minio.crazy-kowalevski5.im.grycap.net" "" "MinIO" {
                        containerInstance MinIO global
                    }
                    nomad_cluster_incd = deploymentNode "vm*" "" "" "" 10 {
                        incd_coe = containerInstance coe                    incd_instance,nomad_cluster
                        incd_container = containerInstance user_task        incd_instance
                    }
                }
            }
            
            deploymentNode "IISAS" {
                deploymentNode "cloud.ui.sav.sk"  { 
                    deploymentNode "secret.services.ai4os.eu" "" "Vault" {
                        secret = containerInstance secrets global
                    }
                    
                    nomad_cluster_iisas = deploymentNode "vm*" "" "" "" 10 {
                        iisas_coe = containerInstance coe                   iisas_instance,nomad_cluster
                        iisas_container = containerInstance user_task       iisas_instance
                    }
                }
            }

            deploymentNode "INFN-CNAF" {
                deploymentNode "cloud.cnaf.infn.it"  {
                    /* deploymentNode "iam.ai4eosc.eu" "" "nginx" { */
                    /*     containerInstance iam   global */
                    /* } */
                    deploymentNode "paas.ai4eosc.eu" "" "nginx" {
                        containerInstance paas_dashboard                global
                        containerInstance paas_orchestrator             global
                        containerInstance im                            global
                        containerInstance federated_service_catalogue   global
                        containerInstance monitoring_system             global
                        containerInstance cloud_provider_ranker         global
                    }
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
                }
            }
            
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

            deploymentNode "External resources" {
                softwareSystemInstance storage global
            }
            deploymentNode "CERN" {
                deploymentNode "zenodo.org" {
                    softwareSystemInstance zenodo global
                }
            }
            deploymentNode "External user resources" {
                softwareSystemInstance external_resources global,federated
            }
            nomad_cluster_ifca -> nomad_cluster_incd "Connects to"
            nomad_cluster_ifca -> nomad_cluster_iisas "Connects to"
            nomad_cluster_iisas -> nomad_cluster_incd "Connects to"
        }
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
        }

        systemContext orchestration orchestration_view {
            include *
            exclude "ai4eosc_platform -> aai"
        }

        systemContext aiaas aiaas_view {
            include *
        }

        container aiaas aiaas_container_view {
            include *
        }

        container ai4eosc_platform ai4eosc_container_view {
            include *

            exclude "orchestration -> aai"
        
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"

            exclude "user_task -> oscar"
            exclude "user_task -> aiaas"
            exclude "oscar -> user_task"
            exclude "aiaas -> user_task"
            exclude "drift_monitoring -> dashboard"
            exclude "drift_monitoring -> eosc_user"
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

        component cicd cicd_component_view {
            include *
        }

        # Dynamic views

        dynamic user_task develop_view {
            title "[Dynamic view] Develop a model and register an AI4EOSC module"
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
            dev_task -> secrets "Gets configured user secrets (i.e. token) for interative access"
            dev_task -> storage_task "Reads and writes from"

            eosc_user -> dev_task "Develops (new/updated) model in"
            dev_task -> mlflow "Logs experiment parametres and metrics to MLFlow"
            eosc_user -> mlflow "Checks model performance in"
            eosc_user -> model_repo "Submits new/updated AI4 module"
            cicd -> model_repo "Runs platform and user checks"
            cicd -> container_repo "Creates new Docker container"
            cicd -> zenodo "Enables repository integration"
            cicd -> aiaas "Notifies about new/updated module"
            model_repo -> zenodo "Triggers deposit of code"
        }

        dynamic user_task federated_train_view {
            title "[Dynamic view] Federated learning scenario"

            eosc_user -> dashboard "Requests available modules"
            dashboard -> aai "Checks user credentials"
            aai -> dashboard "Returns access token"

            dashboard -> platform_api "Requests new federated learning job"
            platform_api -> secrets "Create secrets for federated server" 

            platform_api -> coe "Register new federated learning Nomad job"
            coe -> federated_server "Deploy federated learning server"
            federated_server -> secrets "Get secrets for federated server"

            platform_api -> coe "Register new training / interactive job"
            coe -> dev_task "Executes Development Environment as container"
            dev_task -> secrets "Gets configured user secrets (i.e. token) for interative access"
            dev_task -> storage_task "Reads and writes from"

            dev_task -> federated_server "Get updated model, using server credentials"
            dev_task -> federated_server "Send updates to federated server, using configured secret"
            
            
            external_container -> federated_server "Get updated model, using configured secret"
            external_container -> federated_server "Send updates to federated server, using configured secret"
            
            eosc_user -> dev_task "Develops (new/updated) model in"
            eosc_user -> model_repo "Submits new/updated module"

        }

        dynamic aiaas oscar_dynamic {
            title "[Dynamic view] OSCAR dynamic view"
            end_user -> OSCAR "Deploy service"
            OSCAR -> MinIO "Buckets and folders will be created"
            end_user -> MinIO "Store data for asynchronous inference (Option A)"
            OSCAR -> Knative "Execute services synchronously (Option B)"
            OSCAR -> Kubernetes "Manage services. Register jobs. Retrieve logs (Option A)"
            Kubernetes -> FaaSS "Create jobs (Option A)"
            Knative -> FaaSS  "Assign to function's pod(s). (Option B)"
            FaaSS -> MinIO "Download input. Upload output."
            /* FaaSS ->  "Read/store data " */
        }

        dynamic aiaas AI4Compose_dynamic { 
            title "[Dynamic view] AI4Compose dynamic view" 

            end_user -> flowfuse "Compose pipelines"
            flowfuse -> nodered "Manage instances"
            nodered -> nodered_repository "Obtain custom OSCAR nodes"
            nodered -> OSCAR "Invoke Service and trigger inference"
            flowfuse -> end_user  "Visualize results"

            end_user -> jupyter "Compose pipelines"
            jupyter -> elyra "Manage Notebooks"
            Elyra -> ai4compose_repository "Obtain custom OSCAR nodes"
            elyra -> OSCAR "Invoke Service and trigger inference"
            jupyter  -> end_user  "Visualize results"
         }

        dynamic ai4eosc_platform MLOps_dynamic {
            title "[Dynamic view] MLOps: high-level automation"
            eosc_user -> dashboard "Enable/request MLflow to track experiments" 
            eosc_user -> mlflow "Initiates a new experiment-run"
            mlflow -> secrets "Gets secrets for mlflow tracking server users into Vault"
            user_task -> mlflow  "Logs exp-run parametres, metrics to mlflow during model dev"      
            user_task -> mlflow "Registers the model with tags/alias into Model Registry"
            cicd -> mlflow "Selects best model for deployment"

            #mlflow -> model_repo "Updates AI model version and source code"      
            model_repo -> cicd "Gets the updated model version for deployment"
            cicd -> aiaas "Deploys best performed model in production"
            
                       
            drift_monitoring -> cicd "Triggers drift monitoring actions for the deployed model"
            drift_monitoring -> dashboard "Updates dashboard with drift status"
                            
            drift_monitoring -> eosc_user "Visualize model performance"                
            dashboard -> eosc_user "Notifies user in case a drift occurs"
        }
        
        dynamic ai4eosc_platform Drift_detection {
            title "[Dynamic view] Automatic (data/concept) drift detection (rebuild the  model)"

            # ML developer perspective

            cicd -> zenodo "Detects new data version"   
            cicd -> drift_monitoring "Triggers model monitoring"
            drift_monitoring -> dashboard "Updates dashboard with drift status"            
            dashboard -> eosc_user "Notifies user about drift occurrence"

            eosc_user -> user_task "Update the developed model in"
            #zenodo -> storage_task "Writes the new dataset to"
            #user_task -> platform_storage "Reads and writes data from"
            user_task -> storage "Syncs external data from"


            #eosc_user -> mlflow "Log the metrics of the experiments for the updated model"
            #eosc_user -> mlflow "Registers the retrained model"

                        
            user_task -> mlflow "Logs new experiment-runs, stores model to Model Registry"
            eosc_user -> mlflow "Registers the retrained model"
            #mlflow -> model_repo "Updates the model source code"
            model_repo -> cicd "Updates the model and requests model retraining if data is valid and not poisoned"

            cicd -> container_repo "Creates new Docker container for retrained model"
            cicd -> model_repo "Updates model repository with new version"
            cicd -> aiaas "Deploy the new model trained with new data in production"
            
            model_repo -> zenodo "Triggers deposit of updated model"            
            
        }
            
 

        deployment * production {
            include *
            /* autoLayout */
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

