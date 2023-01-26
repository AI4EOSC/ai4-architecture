workspace {
    name "OSCAR Architecture"
    model {
        user = person "User"
        OSCAREnviroment = enterprise "OSCAR env"{
            OSCARSystem = softwareSystem "OSCAR"{
                OSCAR = container "OSCAR Manager" 
                Kubernetes = container "Kubernetes API" 
                MinIO = container "MinIO" 
                Knative = container "Knative" 
                FaaSS = container "FaaS Supervisor" 
            }
            ESP = softwareSystem "External Storage Provider"{
                s3 = container "Amazon S3"
                MinIOExternal = container "MinIO"
                oneData = container "Onedata"
                dcache = container "dCache"
            }
    
            MinIO -> OSCAR 
            OSCAR -> MinIO "Create buckets and folders. Configure event and notifications. Download/ Upload Files. Trigger jobs (webhook events)"
            OSCAR -> Kubernetes "Manage services. Register jobs. Retrieve logs"
            Kubernetes -> OSCAR
            OSCAR -> Knative "Execute services syncrhonously (optional)"
            Knative -> FaaSS "Assign to function's pod(s)"
            FaaSS -> Knative 
            Kubernetes -> FaaSS "Create jobs"
            #FaaSS -> ESP "Upload Output"
            FaaSS -> MinIO "Download input. Upload output"
            
            FaaSS -> s3
            FaaSS -> MinIOExternal
            FaaSS -> oneData
            FaaSS -> dcache
            IMSystem = softwareSystem "Infrastructure Manager"{
                IM = container "IM Server"
                FN = container "IM Dashboard"
               
            }
        }    
        FN ->  IM "It uses"
        IMSystem -> OSCAR "Deploy"
        user ->  OSCAR "It uses"
        user ->  FN "It uses"
        
    }


    views {

        container OSCARSystem  {
            include * 
        }
        container ESP  {
            include * 
        }
        container IMSystem  {
            include * 
        }

        theme default
    }
}
