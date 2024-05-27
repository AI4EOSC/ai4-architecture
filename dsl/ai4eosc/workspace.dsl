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

                data_repo = container "Model and data repository" "Track AI models and data sets." "dvc" "repository"
                model_repo = container "Model code repository" "Track AI model code." "Git" "repository"
                container_repo = container "Container registry" "Store container images." "DockerHub" "repository" 

                exchange_db = container "Exchange database" "Stores AI4EOSC exchange registered models." "" "database"

                ci = container "Continuous Integration" "Ensures quality aspects are fulfilled (code checks, unit checks, etc.)."
                cd = container "Continuous Delivery & Deployment" "Ensures delivery and deployment of new assets."
                
                dashboard = container "AI4EOSC dashboard" "Provides access to existing modules (anonymous), experiment and training definition (logged users)." "Angular" "dashboard"

                training_db = container "Training database" "Stores AI4EOSC training requests." "" "database"

                dev = container "Interactive development Environment" "An interactive development environment with access to resources and limited execution time." "Jupyter"

                coe = container "Workload Management System" "Manages and schedules the execution of compute requests." "Hashicorp Nomad"

                resources = container "Compute client" "Executes user workloads." "Hashicorp Nomad"

                federated_server = container "Federated learning server" "Agregates federated client updates" "flower.io"

                model_container = container "Model container" "Encapsulates user code." "Docker" {
                    api = component "API" "" "DEEPaaS API"

                    framework = component "ML/AI framework"

                    user_model = component "User code and model"

                    api -> user_model
                    user_model -> framework
                }

            
                # This is a special case, added here, but ignored in the view, just to
                # be included in the dynamic view
                external_container = container "User-managed model container" "Encapsulates user code, not executed on the platform" "Docker" 
                external_container -> federated_server "Gets updated model, sends weights to server"
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

            deepaas = softwareSystem "AI as a Service" "Allows users to deploy an AI application as a service." {
                ai4compose = container "AI4Compose"
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

        mlops -> deepaas "Monitors production model"
        mlops -> ai4eosc_platform "Triggers model update/retraining"


        # AI4EOSC platform

        eosc_user -> dashboard "Browse models, train existing model, build new one."

        # Training 
        eosc_user -> dev "Access interactive environments"

        dashboard -> platform_api "Reads available models, defines new trainings, checks training status, etc. "

        platform_api -> coe "Create training job, interactive environment using API calls to"
        platform_api -> training_db "Stores training data in"
        platform_api -> model_container "Queries training status"

        coe -> resources "Create new task/workload"

        resources -> dev "Create on-demand environments"
        resources -> model_container "Executes user model in a"

        coe -> federated_server "Creates"
        model_container -> federated_server "Gets updated model, sends new weights"
        platform_api -> federated_server "Manages federated learning rounds"

        /* eosc_user -> model_container "Trigger new training jobs" */

        platform_api -> aai "Authenticates users with"
        dashboard -> aai "Authenticates users with" 
            
        dev -> storage "Read data from"
        model_container -> storage "Read data from"

        # AI4EOSC exchange

        platform_api -> data_repo "Reads from"
        platform_api -> model_repo "Reads from"
        platform_api -> container_repo "Reads from"

        eosc_user -> data_repo "Registers data"
        eosc_user -> model_repo "Registers model"
        eosc_user -> container_repo "Registers container"

        ci -> data_repo "Ensures QA aspects"
        ci -> model_repo "Ensures QA aspects"
        

        cd -> model_repo "Reacts to events from"
        cd -> container_repo "Creates containers"
        cd -> deepaas "Deploys models on"

        data_repo -> storage "Refers to data stored in"

        platform_api -> exchange_db "Reads from writes to"

        model_container -> container_repo "Stored in"

        orchestration -> resources "Provisions"

        mlops -> platform_api "Trigger model update/retraining"
        mlops -> data_repo "Monitor new data available, update model after training"
        mlops -> cd "Trigger model update"

        /* # #MLOps --new data available */
        data_preproc -> data_repo "Read datasets or new model updates from" 
        /* /1* ci -> data_validation "integrate validated data" *1/ */

        /* /1* model_container -> container_repo "Pulls trained model from registry" *1/ */
        /* model_container -> oscar "Loads model into inference service" */
        /* /1* oscar -> model_container "Receives prediction requests" *1/ */

        /* #MLOps --a new trained model */
        deployment_workflow -> cd "Trigger update of most recent model"


        /* #mlops other relationships */
        /* /1* data_repo -> data_validation "Sends data for validation" *1/ */
        data_validation -> drift_detection "Sends validated data for monitoring"
        drift_detection -> feedback_loop "Triggers model retraining"
        feedback_loop -> platform_api "Starts model retraining"
        feedback_loop -> deployment_workflow "Notifies of model retraining"

        drift_detection -> oscar "Monitor deployed model"
        /* platform_api -> deployment_workflow "Deploys new model" */
        /* deployment_workflow -> oscar "Updates model in production" */

        /* platform_api -> drift_detection "Receives model performance metrics" */
        /* data_validation -> platform_api "Sends validated data for monitoring" */
  
        #     model_monitor -> dashboard "Monitors model performance"
        #     dashboard -> model_monitor "Receives performance metrics"

        # Orchestration

        paas_ops -> paas_dashboard "Manages AI4EOSC PaaS deployments"
        paas_dashboard -> paas_orchestrator "Create deployment"
        paas_dashboard -> tosca_repo "Read topologies"
        paas_orchestrator -> tosca_repo "Read topologies"
        paas_orchestrator -> im "Uses"
        paas_orchestrator -> federated_service_catalogue "Get information"
        monitoring_system -> federated_service_catalogue "Send aggregated metrics"
        paas_orchestrator -> cloud_provider_ranker "Get matching offers"
        /* iam -> aai "Federate users from" "OpenID Connect" */

        /* paas_orchestrator -> iam "Authenticates users with" */
        /* im -> iam "AuthN/Z" */

        cloud_providers -> resources "offer"
        cloud_providers -> federated_service_catalogue "register/update service & resources metadata"
        cloud_providers -> monitoring_system "push/pull metrics"

        paas_orchestrator -> resources "Provisions resources for"
        paas_orchestrator -> Knative "Provisions resources for" 
        paas_orchestrator -> OSCAR "Provisions resources for" 

        # DEEPaaS OSCAR
        ai4compose -> OSCAR "Trigger inference"
        OSCAR -> MinIO "Manage buckets, folders, event and notifications"
        OSCAR -> Kubernetes "Manage services"
        OSCAR -> Knative "Execute services synchronously"
        Knative -> FaaSS "Assign to function's pod(s)"
        Kubernetes -> FaaSS "Create jobs"
        FaaSS -> MinIO "Download input. Upload output"
        FaaSS -> storage "Read/store data"
        FaaSS -> s3 "Read/store data"
        FaaSS -> MinIOExternal "Read/store data"
        FaaSS -> oneData "Read/store data"
        FaaSS -> dcache "Read/store data"

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
        /*                 containerInstance model_container   ifca_instance */
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
        /*                 iisas_container = containerInstance model_container iisas_instance,federated */
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
        /*             /1*     cnaf_container = containerInstance model_container  cnaf_instance *1/ */
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
        /*                 bari_container = containerInstance model_container  bari_instance,federated */
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
        }

        systemContext ai4eosc_platform ai4eosc_view {
            include *
            exclude "eosc_user -> data_repo"
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"

            exclude "ci -> data_validation"
            exclude "data_repo -> data_validation"
            exclude "platform_api -> deployment_workflow" 
            exclude "deployment_workflow -> oscar"
            exclude "data_validation -> platform_api"
        }

        systemContext orchestration orchestration_view {
            include *
        }

        systemContext deepaas deepaas_view {
            include *
        }
        
        systemContext mlops mlops_view {
            include *
        }

        container deepaas deepaas_container_view {
            include *
            exclude "ai4eosc_platform -> storage" 
        }

        
        container ai4eosc_platform ai4eosc_container_view {
            include *

            exclude "external_container"
            exclude "external_container -> federated_server"

            exclude "eosc_user -> data_repo"
            exclude "eosc_user -> model_repo"
            exclude "eosc_user -> container_repo"

            exclude "ci -> data_validation"
            exclude "ci -> mlops"

            exclude "data_repo -> data_validation"
            exclude "data_repo -> mlops"

            exclude "platform_api -> deployment_workflow" 
            exclude "platform_api -> mlops"

            exclude "deployment_workflow -> oscar"

            exclude "data_validation -> platform_api"

            exclude "model_container -> oscar"
            exclude "model_container -> deepaas"
            exclude "oscar -> model_container"
            exclude "deepaas -> model_container"
        }
        
        container mlops mlops_container_view {
            include *
        }

        container orchestration orchestration_container_view {
            include *
            include cloud_providers
        }

        # Dynamic views

        /* dynamic ai4eosc_platform develop_view { */
        /*     title "[Dynamic view] Develop and register a model" */
        /*     eosc_user -> dashboard "Requests a development environment" */
        /*     dashboard -> iam "Checks user credentials" */
        /*     iam -> dashboard "Returns access token" */
        /*     dashboard -> platform_api "Requests new development enviroment with user access token" */
        /*     platform_api -> coe "Register new Nomad job, using robot account" */
        /*     coe -> resources "Submit Nomad job to Nomad agent on provisioned resources" */
        /*     resources -> dev "Executes Development Environment as container" */

        /*     dev -> storage "Read and store data from" */

        /*     eosc_user -> dev "Develops new model" */
        /*     eosc_user -> data_repo */
        /*     eosc_user -> model_repo */
        /*     eosc_user -> container_repo */
        /*     dashboard -> platform_api "Registers new model" */
        /*     /1* dashboard -> platform_api *1/ */
        /*     /1* platform_api -> dashboard "Provides list of models" *1/ */
        /* } */
        
        /* dynamic ai4eosc_platform manual_retrain_view { */
        /*     title "[Dynamic view] Manually retrain a model" */

        /*     eosc_user -> dashboard "Requests available modules" */
        /*     dashboard -> iam "Checks user credentials" */
        /*     iam -> dashboard "Returns access token" */
        /*     dashboard -> platform_api "Requests new training job" */
        /*     platform_api -> coe "Register new Nomad job, using robot account" */
        /*     coe -> resources "Submit Nomad job to Nomad agent on provisioned resources" */
        /*     resources -> model_container "Executes training job as container" */

        /*     storage -> model_container "Read training data" */
        /*     model_container -> storage "Write training results" */
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
        /*     resources -> model_container "Executes training job as container" */

        /*     model_container -> federated_server "Get updated model, using server credentials" */
        /*     model_container -> federated_server "Send updates to server, using server credentials" */
            
        /*     external_container -> federated_server "Get updated model, using server credentials" */
        /*     external_container -> federated_server "Send updates to server, using server credentials" */

        /*     platform_api -> federated_server "Query federated learning status" */

        /*     storage -> model_container "Read training data" */
        /*     model_container -> storage "Write training results" */
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
        /* /1*     /2* resources -> model_container "Executes training job as container" *2/ *1/ */

        /* /1*     /2* storage -> model_container "Read training data" *2/ *1/ */
        /* /1*     /2* model_container -> storage "Write training results" *2/ *1/ */

        /* /1*     #mlops --new data *1/ */
            
        /* /1*     /2* data_preproc -> data_repo "Retrieves new data" *2/ *1/ */
        /* /1*     #data_repo -> data_preproc "Retrieves data" *1/ */
        /* /1*     /2* data_preproc -> dev "Preprocesses data" *2/ *1/ */
        /* /1*     #dev -> platform_api "Starts training job" *1/ */
        /* /1*     #platform_api -> drift_detection "Receives model performance metrics" *1/ */
     

        /* /1*     # *1/ */
        /* /1*     /2* model_container -> container_repo "Push trained model to registry" *2/ *1/ */
        /* /1*     /2* model_container -> oscar "Loads model into inference service" *2/ *1/ */
        /* /1*     /2* oscar -> model_container "Receives recent prediction requests" *2/ *1/ */
      

            


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

