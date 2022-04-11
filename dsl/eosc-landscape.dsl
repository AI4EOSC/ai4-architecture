workspace eosc "EOSC architecture" {
    
    !adrs decisions

    model {

        eosc_user = person "EOSC User"

        eosc = group EOSC {
            aai = softwareSystem "AAI"
            portal = softwareSystem "EOSC Portal"
        }

        aai -> portal "Provides authentication"

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
