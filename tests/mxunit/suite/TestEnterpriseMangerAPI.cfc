<cfcomponent extends="mxunit.framework.TestCase">

    <cffunction name="beforeTests">
        <cfscript>
            variables.apiUrl = "http://127.0.0.1:8500/CFIDE/administrator/configmanager/api/entmanager.cfm";
            variables.username = "admin";
            variables.password = "vagrant";
        </cfscript>
    </cffunction>

    <cffunction name="testAuthenticaitonNoCredentials">
        <cfset var apiResult = "" />
        <cfhttp url="#variables.apiUrl#" method="get" result="apiResult" />
        <cfset assertEquals("401 UNAUTHORIZED",apiResult.statusCode) />
    </cffunction>

    <cffunction name="testAuthenticaitonWithCredentials">
        <cfset var apiResult = "" />
        <cfhttp url="#variables.apiUrl#" method="get" username="#variables.username#" password="#variables.password#" result="apiResult" />
        <cfset assertEquals("400 BAD REQUEST",apiResult.statusCode) />
    </cffunction>

    <cffunction name="testAddNewInstanceWithoutServerDir">
        <cfset var apiResult = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addNewInstance"", ""params"" :{ ""serverName"" : ""test1"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
        <cfset assertTrue(DirectoryExists("/opt/coldfusion10/test1")) />

    </cffunction>

    
</cfcomponent>