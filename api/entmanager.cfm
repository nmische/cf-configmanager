<cfsilent>

<!--- first make sure this is the cfusion instance --->
<cfset runtime = createObject("component", "CFIDE.adminapi.runtime") />
<cfset instance = runtime.getInstanceName() />
<cfif instance neq "cfusion">
    <cfheader statuscode="400" statustext="Bad Request" />
    <cfabort />
</cfif>

<!--- parse the json request --->
<cfset rawData = GetHttpRequestData().content />
<cfif IsBinary(rawData)>
    <cfset rawData = ToString(rawData) />
</cfif>

<cfif IsJSON(rawData)>
    <cfset jsonData = DeserializeJSON(rawData) />
<cfelse>
    <cfheader statuscode="400" statustext="Bad Request" />
    <cfabort />
</cfif>

<cftry>

    <!--- execute the action --->
    <cfset action = jsonData.action />

    <cfswitch expression="#action#">
        
        <cfcase value="addNewInstance">

            <cfset serverName = jsonData.params.serverName />
            <cfif structKeyExists(jsonData.params,"serverDir")>
                <cfset serverDir = jsonData.params.serverDir />
            <cfelse>
                 <cfset serverDir = server.coldfusion.rootdir & "/../" & serverName />
            </cfif>
            
           
            <cfset processServer = CreateObject("java", "com.adobe.coldfusion.entman.ProcessServer").init() />
            <cfset processServer.setConfigDir(server.coldfusion.rootdir & "/../config") />

            <cfif not processServer.isServerExists(serverName)>
                <cfset processServer.setServerName(serverName) />
                <cfset processServer.setServerDir(serverDir) />
                <cfset processServer.addServer() />
                <cfset logInfo("Added new local instance #serverName# at #serverDir#") />
            </cfif>

        </cfcase>

    </cfswitch>

    <cfcatch type="any">
        <cfset logError("Enterprise manager error: #cfcatch.message#") />
        <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
        <cfabort />
    </cfcatch>

</cftry>

<cfheader statuscode="200" statustext="Success" />

</cfsilent>

