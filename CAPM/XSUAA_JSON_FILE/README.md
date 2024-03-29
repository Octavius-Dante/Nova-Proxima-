## XSUAA

</br>
</br>   
</br>   

- [x] Create a New backing service instance for XSUAA 
- [x] While creating this instance we need to pass our Role Configuration (JSON) = xs-security.json
- [x] Documentation for making xs-security file
</br> https://help.sap.com/viewer/4505d0bdaf4948449b7f7379d24d0f0d/2.0.03/en-US/6d3ed64092f748cbac691abc5fe52985.html

- [x] We need to bind our app with this backing service
- [x] If we use Java, we need to add a security module (Spring) to restrict access to end points
</br> https://github.com/SAP/cloud-security-xsuaa-integration
- [x]Deploy and Test our app


</br>   
</br>   
   
   ```json
{
    "xsappname": "07springodata",
    "tenant-mode": "dedicated",
    "scopes": [
        {
            "name": "$XSAPPNAME.UserDisplay",
            "description": "To Display vendor data"
        },
        {
            "name": "$XSAPPNAME.UserEdit",
            "description": "To Create new vendor data"
        }
    ],
    "role-templates": [
        {
            "name": "Viewer",
            "description": "View, Vendor Details",
            "scope-references": [
                "$XSAPPNAME.UserDisplay"
            ]
        },
        {
            "name": "Editor",
            "description": "Edit and Create new Vendor Details",
            "scope-references": [
                "$XSAPPNAME.UserEdit"
            ]
        }
    ],
    "authorities": [
        "$ACCEPT_GRANTED_AUTHORITIES"
    ],
    "aouth2-configuration": {
        "token-validity": 9000,
        "redirect-uris": [
            "https://api.cf.us10-001.hana.ondemand.com/"
        ]
    },
    "xsenableasyncservice": "true"
}
   ```
   
</br>   
</br>      
