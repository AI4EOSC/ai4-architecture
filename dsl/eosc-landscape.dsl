workspace eosc "EOSC architecture" {
    
    !adrs decisions

    model {

        eosc_user = person "EOSC User" "An EU researcher willing to exploit EOSC resources and services."

        eosc = group EOSC {
            aai = softwareSystem "AAI" "Provides Authentication, Authorization and Identity management for EOSC users."
            portal = softwareSystem "EOSC Portal" "Provides access to EOSC resources and services for users."
        }

        aai -> portal "Provides authentication for"

        eosc_user -> portal "Browse resources"
    }

    views {
        theme Default
        
        systemLandscape eosc {
            include *
            autoLayout lr
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
