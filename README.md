ColdFusion Configuration Manager
================================

The ColdFusion Configuration Manager provides remote access to setter functions in the [ColdFusion Administrator API](http://help.adobe.com/en_US/ColdFusion/9.0/Admin/WSc3ff6d0ea77859461172e0811cbf364104-7fcf.html) via a very simple wrapper API.

Installation
------------

Download the configmanager.zip file and extract to a folder named `configmanager` under the ColdFusion Administrator directory. You can optionally create a link to the extension by adding the following to the Administrator's `custommenu.xml`.

    <submenu label="Configuration Manager">
        <menuitem href="configmanager/index.cfm" target="content">Recent Changes</menuitem>
    </submenu>

For more information see the [Custom Extensions](http://help.adobe.com/en_US/ColdFusion/9.0/Admin/WSc3ff6d0ea77859461172e0811cbf3638e6-7fbf.html) section of the ColdFusion Administrator documentation.

Usage
-----

To set a configuration value simply post a JSON document to /CFIDE/administrator/configmanager/api/index.cfm including administrator credentials via basic authentication. The JSON document should identify the administrator api component, method, and method invocation arguments. For example, to call the `runtime.cfc`'s `setCacheProperty` method with and argument collection of `{ propertyName="TrustedCache", propertyValue=true }` you would post the following JSON.

    { 
        "runtime" : { 
            "cacheProperty" : [ 
                {"propertyName" : "TrustedCache", "propertyValue" : true } 
            ]
        }
    }

The top level key, `runtime` in the above example, identifies the administrator api component. The second level key, `cacheProperty` in the above example, identifies the setter method to call on the administrator api component. This key contains an array of invocation arguments that will be passed to the method, so you can invoke a method several times if necessary. For example, the follow JSON document will invoke the `runtime.setCacheProperty` method four times, setting four distinct property values.

    { 
        "runtime" : { 
            "cacheProperty" : [ 
                {"propertyName" : "TrustedCache", "propertyValue" : true },
                {"propertyName" : "InRequestTemplateCache", "propertyValue" : true },
                {"propertyName" : "ComponentCache", "propertyValue" : true },
                {"propertyName" : "CacheRealPath", "propertyValue" : true } 
            ]
        }
    }

You can also call multiple admin components as in the following example.

    { 
        "runtime" : { 
            "cacheProperty" : [ 
                {"propertyName" : "TrustedCache", "propertyValue" : true } 
            ]
        },
        "extensions" : {
            "mapping" : [
                {"mapName" : "\/test", "mapPath" : "C:\/test" }
            ]
        }
    }

*NOTE:* The remote API relies on basic authenication, and as such should be accessed via HTTPS. 

