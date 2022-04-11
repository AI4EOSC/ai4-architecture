workspace ai4eosc "AI4EOSC architecture" {

    !identifiers hierarchical

    model {
        user = person "AI researcher" "A scientist willing to use the AI4EOSC platform."
        ops = person "Resource provider operators" "A resource provider that wants to contribute resources to the AI4EOSC platform."

        ai4eosc = enterprise AI4EOSC  {

            ai_ops = person "AI4EOSC Platform Operator" "Administration and support of the AI4EOSC platform."

#            ai_exchange = softwareSystem "AI4EOSC exchange" "Provides a marketplace and exhcange of AI models." {
#                api = container "Exchange API"
#
#                provenance_framework = container "Model provenance framework" "" "MLFlow"
#
#                model_repository = container "Model repository" "" "Git" {
#                    tags "repository"
#                }
#
#                model_data_repository = container "Model data" "" "dvc" {
#                    tags "repository"
#                }
#                
#                webpage = container "Web dashboard" "Provides all of the functionality to user via their web browser."{
#                    tags "dashboard"
#                }
#            }

            ai_platform = softwareSystem "AI4EOSC platform" "Allows to build and train AI models." {
                dashboard = container "Web dashboard" "Provides all of the functionality to user via their web browser."{
                    tags "dashboard"
                }

                order = container "Ordering system"

                aai = container "AAI"

                api = container "Training system API" 

                workload_management = container "Workload Management system" "" "Hashicorp Nomad"

                development = container "Interactive development Environment" "" "Jupyter Enterprise Gateway"

                provenance_framework = container "Model exchange and provenance framework" "" "MLFlow"

                model_repository = container "Model repository" "" "Git" {
                    tags "repository"
                }

                model_data_repository = container "Model data" "" "dvc" {
                    tags "repository"
                }

            }

            ai_platform_orchestration = softwareSystem "AI4EOSC platform orchestration" {
                orchestrator = container "Orchestrator" "" "INDIGO PaaS Orchestrator"

                dashboard = container "Dashboard" "" "INDIGO PaaS Dashboard" {
                    tags "dashboard"
                }

                im = container "Infrastructure Manager"

                topologies = container "Topologies repository" "" "TOSCA" {
                    tags "repository"
                }
            }

#            cicd_system = softwareSystem "CI/CD" "Ensures that quality of the IT assets." {
#                cicd = container "CI/CD" "" "Jenkinks + JePL"
#
#                service = container "Service quality" "" "SQaaS"
#
#                fair = container "Data quality" "" "FAIR Evaluator"
#            }
        }
        
        compute_resources = softwareSystem "Compute Resources" "Provides computing resources to the platform." {
            agent = container "Execution agent" "" "Hashicorp Nomad"
            k8s = container "Container Orchestration Engine" "" "Kubernetes"
        }
        
        eosc = group EOSC {
            aai = softwareSystem "AAI"
            portal = softwareSystem "EOSC Portal"
        }

        
#        ai_platform -> ai_exchange "Gets/stores model from"

        user -> ai_platform.dashboard "Browse, update, develop new models, define experiments"
#        user -> ai_exchange.webpage "Browse and download models"
        ai_platform.dashboard -> ai_platform.api "Provide access to"
        ai_platform.dashboard -> ai_platform.development "Provide access to"
#       ai_platform.dashboard -> ai_exchange.api "Retrieves, stores, updates models"
        
        ai_platform.dashboard -> ai_platform.provenance_framework

        ai_platform.aai -> ai_platform.api "AuthN/Z"
        ai_platform.aai -> ai_platform.provenance_framework "AuthN/Z" 
        ai_platform.aai -> ai_platform.development "AuthN/Z"
#        ai_platform.aai -> ai_platform.dashboard

        ai_platform.provenance_framework -> ai_platform.model_repository
        ai_platform.provenance_framework -> ai_platform.model_data_repository

        portal -> ai_platform "Provide access to"
        portal -> ai_platform.order "Create an order"
        ai_ops -> ai_platform.order 

        ai_platform.order -> ai_platform.aai "Authorize"

        aai -> portal "AuthN/Z"

        aai -> ai_platform.aai "Federate EOSC users"
#        aai -> ai_platform.dashboard "AuthN/Z"
#        aai -> ai_platform "AuthN/Z"

        ops -> ai_platform_orchestration.dashboard "Uses"
        ai_platform_orchestration.dashboard -> ai_platform_orchestration.orchestrator "API calls"
        ai_platform_orchestration.orchestrator -> ai_platform_orchestration.im "API calls"
        ai_platform_orchestration.orchestrator -> ai_platform_orchestration.topologies "Reads deployment templates"
        ai_platform_orchestration.im -> compute_resources "Provisions resources"
        ai_platform_orchestration.orchestrator -> compute_resources "Monitors state"
        

        ai_platform.api -> ai_platform.workload_management "Create training job"
        ai_platform.workload_management -> compute_resources.agent "Uses"
        ai_platform.development -> compute_resources.k8s "Uses"


        




    }

    views {
        theme Default
        
#        systemLandscape {
#            include *
#            autoLayout lr
#        }
#
#        systemContext ai_platform {
#            include *
#            autoLayout lr
#        }
#
#        systemContext ai_platform_orchestration {
#            include *
#            autoLayout lr
#        }
#
#        systemContext ai_exchange {
#           include *
#           autoLayout lr
#        }
#
#        systemContext cicd_system {
#           include *
#           autoLayout lr
#        }
#        
#        systemContext compute_resources {
#           include *
#           autoLayout lr
#        }

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
