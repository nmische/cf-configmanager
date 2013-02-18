<cfsilent>

<!--- first make sure this is the cfusion instance --->
<cfset runtime = createObject("component", "CFIDE.adminapi.runtime") />
<cfset instance = runtime.getInstanceName() />
<cfif instance neq "cfusion">
    <cfheader statuscode="400" statustext="Bad Request" />
    <cfabort />
</cfif>

<cftry>

    <cflock name="CF_CONFIGMANAGER_ENTMANGER" type="exclusive" timeout="60" throwontimeout="true">
        
    <!--- execute the action --->
    <cfset action = jsonData.action />

    <cfswitch expression="#action#">
        
        <cfcase value="addServer">

            <!--- required params --->
            <cfset serverName = jsonData.params.serverName />

            <!--- optional params --->
            <cfparam name="jsonData.params.serverDir" type="string" default="#Replace(server.coldfusion.rootdir,'/cfusion','/#serverName#')#" />
            <cfset serverDir = jsonData.params.serverDir />
         
           
            <cfset processServer = CreateObject("java", "com.adobe.coldfusion.entman.ProcessServer").init() />
            <cfset processServer.setConfigDir(server.coldfusion.rootdir & "/../config") />

            <cfif not processServer.isServerExists(serverName)>
                <cfset processServer.setServerName( JavaCast("String",serverName) ) />
                <cfset processServer.setServerDir( JavaCast("String",serverDir) ) />
                <cfset processServer.addServer() />
                <cfset logInfo("Added new local instance #serverName# at #serverDir#") />
            </cfif>

        </cfcase>

        <cfcase value="addRemoteServer">

            <!--- required params --->
            <cfset remoteServerName = jsonData.params.remoteServerName />
            <cfset host = jsonData.params.host />
            <cfset jvmRoute = jsonData.params.jvmRoute />
            <cfset remotePort = jsonData.params.remotePort />
            <cfset httpPort = jsonData.params.httpPort />

            <!--- optional params --->
            <cfparam name="jsonData.params.adminPort" type="integer" default="0" />
            <cfset adminPort = jsonData.params.adminPort />
            <cfparam name="jsonData.params.adminUsername" type="string" default="" />
            <cfset adminUsername = jsonData.params.adminUsername />
            <cfparam name="jsonData.params.adminPassword" type="string" default="" />
            <cfset adminPassword = jsonData.params.adminPassword />
            <cfparam name="jsonData.params.lbFactor" type="integer" default="1" />
            <cfset lbFactor = jsonData.params.lbFactor />
            <cfparam name="jsonData.params.https" type="boolean" default="false" />
            <cfset https = jsonData.params.https />

            <cfif adminPort eq 0>
                <cfset adminPort eq "" />
            </cfif>   
           
            <cfset processServer = CreateObject("java", "com.adobe.coldfusion.entman.ProcessServer").init() />
            <cfset processServer.setConfigDir(server.coldfusion.rootdir & "/../config") />

            <cfif not processServer.isServerExists(remoteServerName)>
                <cfset processServer.addRemoteServer( JavaCast("String",remoteServerName), 
                                                      JavaCast("String",host), 
                                                      JavaCast("String",jvmRoute), 
                                                      JavaCast("String",remotePort), 
                                                      JavaCast("String",httpPort), 
                                                      JavaCast("String",adminPort), 
                                                      JavaCast("String",adminUsername), 
                                                      JavaCast("String",adminPassword), 
                                                      JavaCast("String",lbFactor), 
                                                      JavaCast("String",https) ) />
                <cfset logInfo("Added new remote instance #remoteServerName#") />
            </cfif>

        </cfcase>

        <cfcase value="addCluster">

            <cfdump var="#jsonData#" output="console" />

            <!--- required params --->
            <cfset clusterName = jsonData.params.clusterName />

            <!--- optional params --->
            <cfparam name="jsonData.params.servers" type="string" default="" />
            <cfset servers = ListToArray(jsonData.params.servers) />
            <cfparam name="jsonData.params.multicastPort" type="integer" default="0" />
            <cfset multicastPort = jsonData.params.multicastPort />
            <cfparam name="jsonData.params.stickySessions" type="string" default="true" />
            <cfset stickySessions = jsonData.params.stickySessions />
         
           
            <cfset clusterManager = CreateObject("java", "com.adobe.coldfusion.entman.ClusterManager").init() />
            <cfset clusterManager.setConfigDir(server.coldfusion.rootdir & "/../config") />

            <cfset clusterList = clusterManager.doList() /> 

            <cfset isExistingCluster = StructKeyExists(clusterList,clusterName) />
            <cfset isNewCluster = !isExistingCluster />
                
            <!--- create the cluster if necessary --->
            <cfif isNewCluster >
                <cfset clusterManager.addCluster( JavaCast("String",clusterName) ) />
                <cfif multicastPort gt 0>
                    <cfset clusterManager.setMultiCastPort( JavaCast("String",clusterName), 
                                                            JavaCast("String",multicastPort) ) />                    
                </cfif>
                <cfset logInfo("Added new cluster #clusterName#.") />
            </cfif>             
           
            <!--- it seems if we change the mutlicast port on an existing cluster we have to drop and recreate the cluster --->
            <cfif (isExistingCluster) and (multicastPort gt 0) and (multicastPort neq clusterManager.getMulticastPort(clusterName)) >                    
                <cfset clusterManager.removeCluster( JavaCast("String",clusterName) ) />           
                <cfset clusterManager.addCluster( JavaCast("String",clusterName) ) />                   
                <cfset clusterManager.setMultiCastPort( JavaCast("String",clusterName), 
                                                        JavaCast("String",multicastPort) ) />
                <cfset logInfo("Modified multicast port for #clusterName#. Multicast port is now #multicastPort#.") />
            </cfif>

            <cfset clusterList = clusterManager.doList() /> 

            <!--- set the sticky sessions if necessary--->

            <cfif stickySessions neq clusterManager.getStickySession(clusterName) >
                <cfset clusterManager.setStickySession( JavaCast("String",clusterName), JavaCast("String",stickySessions) ) /> 
            </cfif>

            <!--- now calculate servers to remove --->            
            <cfif StructKeyExists(clusterList,clusterName) and ArrayLen(clusterList[clusterName])>
                <cfloop array="#clusterList[clusterName]#" index="serverToRemove">
                    <cfif not ArrayContains(servers,serverToRemove)>
                        <cfset clusterManager.removeCluster( JavaCast("String",clusterName), 
                                                             JavaCast("String",Trim(serverToRemove)), 
                                                             JavaCast("boolean",0) ) />
                        <cfset logInfo("Removed server #serverToRemove# from cluster #clusterName#.") />
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- now calculate servers to add --->
            <cfif ArrayLen(servers)>
                <cfloop array="#servers#" index="serverToAdd">
                    <cfif not StructKeyExists(clusterList,clusterName) or not ArrayContains(clusterList[clusterName],serverToAdd)>
                        <cfset clusterManager.addCluster( JavaCast("String",clusterName), 
                                                          JavaCast("String",Trim(serverToAdd)) ) />
                        <cfset logInfo("Added server #serverToAdd# to cluster #clusterName#.") />
                    </cfif>  
                </cfloop>                          
            </cfif>           

        </cfcase>

    </cfswitch>

    </cflock>

    <cfcatch type="any">
        <cfset logError("Enterprise manager error: #cfcatch.message#") />
        <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
        <cfabort />
    </cfcatch>

</cftry>

<cfheader statuscode="200" statustext="Success" />

</cfsilent>

