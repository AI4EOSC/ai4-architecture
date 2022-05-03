workspace extends ../eosc-landscape.dsl {
    
    name "DEEP-Hybrid-DataCloud"
    description "DEEP-Hybrid-DataCloud legacy architecture"

    model {

        user = person "AI Scientist" "EOSC user willing to use an AI platform to develop an AI application."

        deep = enterprise "DEEP-Hybrid-DataCloud" {
            catalog = softwareSystem "DEEP Open Catatalog" "Allows users to store and retrieve AI models and related assets." {
                marketplace = container "DEEP marketplace" "" "Pelican" "dashboard"

                catalog_repo = container "DEEP Catalog" "" "GitHub" "repository"

                jenkins = container "CI/CD" "" "Jenkins"

                container_repo = container "Container registry" "" "DockerHub" "repository" 
            }

            training = softwareSystem "DEEP Training Facility" "Allows users to develop, build and train an AI application." {
                dashboard = container "DEEP Dashboard" "" "aiohttp" "dashboard"
                paas_dashboard = container "PaaS Dashboard" "" "Flask" "dashboard"
                a4c = container "Topology Composer" "" "Alien4Cloud" "dashboard"

                paas_orchestrator = container "PaaS Orchestrator" "" "INDIGO PaaS Orchestrator"
                im = container "Infrastructure Manager"

                coe = container "Container Orchestration Engine" "" "Mesos"

                tosca_repo = container "Topologies repository" "" "TOSCA" "repository"

                iam = container "Identity and Access Management" "" "INDIGO IAM"

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

        deploymentEnvironment "Production" {
            ifca_instance = deploymentGroup "IFCA Mesos Instance"
            iisas_instance = deploymentGroup "IISAS Mesos Instance"

            deploymentNode "GitHub" {
                deploymentNode "marketplace.deep-hybrid-datacloud.eu" "" "GitHub Pages" {
                    containerInstance marketplace
                }

                containerInstance catalog_repo
                containerInstance tosca_repo
            }

            deploymentNode "Container registry" "" "Docker registry" {
                DockerHub = containerInstance container_repo 
            }
            

            deploymentNode "IFCA-CSIC" {
                deploymentNode "IFCA Cloud" "" "OpenStack" {
                    deploymentNode "train.deep-hybrid-datacloud.eu" "" "nginx" {
                        containerInstance dashboard
                    }
                    deploymentNode "mesos.cloud.ifca.es"  {
                        containerInstance coe 
                        containerInstance serverless_coe
                    }
                    deploymentNode "vm*.cloud.ifca.es" "" "" "" 100 {
                        deploymentNode "Mesos Agent" {
                            deploymentNode "Docker" {
                                containerInstance model_container 
                                containerInstance deepaas_container 
                            }
                        }
                    }
                    deploymentNode "jenkins.indigo-datacloud.eu" {
                        containerInstance jenkins
                    }
                    deploymentNode "deepaas.deep-hybrid-datacloud.eu" "" "OpenWhisk" {
                        containerInstance openwhisk
                        containerInstance deep_connector
                    }
                }
            }

            deploymentNode "IISAS" {
                deploymentNode "mesos.ui.sav.sk"  {
                    iisas_mesos = containerInstance coe iisas_instance
                }
                deploymentNode "vm*" "" "" "" 10 {
                    deploymentNode "Mesos Agent" {
                        deploymentNode "Docker" {
                            iisas_container = containerInstance model_container iisas_instance
                        }
                    }
                }

            }
            
            deploymentNode "LIP" {
                deploymentNode "a4c.deep-hybrid-datacloud.eu"  {
                    containerInstance a4c
                }
            }

            deploymentNode "INFN-CNAF" {
                deploymentNode "iam.deep-hybrid-datacloud.eu" "" "nginx" {
                    containerInstance iam
                }
            }

            deploymentNode "INFN-BARI" {
                deploymentNode "deep-paas.cloud.ba.infn.it" "" "nginx" {
                    containerInstance paas_dashboard
                    containerInstance paas_orchestrator
                    containerInstance im
                }
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

        container deepaas {
            include *
        }
        
        component model_container {
            include *
        }
        
        deployment * "Production" {
            include *
#            autoLayout
        }
        deployment catalog "Production" {
            include *
        }

        deployment training "Production" {
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
