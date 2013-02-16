<cfsilent>

<cfapplication name="configmanagerapi" sessionmanagement="false" clientmanagement="false" />

<cfset username="" />
<cfset password="" />

<cfset req = GetHttpRequestData() />

<!--- check credentials --->
<cfif StructKeyExists(req.headers, "Authorization") >
  <cfset authHeader = req.headers["Authorization"] />
</cfif>

<cfif IsDefined("authHeader")>
	<cfset authString = ToString(BinaryDecode(ListLast(authHeader, " "),"Base64")) />
	<cfset username = ListFirst(authString,":") />
	<cfset password = ListRest(authString,":") />
</cfif>
<cfset admin = CreateObject("component","cfide.adminapi.administrator") />

<cfif not admin.login(adminPassword=password,adminUserId=username)>
	<cfheader statuscode="401" statustext="UNAUTHORIZED" />
	<cfheader name="WWW-Authenticate" value="Basic realm=""ColdFusion Admin Configuration Management""" />
	<cfabort />
</cfif>

<cffunction name="logInfo">
    <cfargument name="msg" />
    <cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Information" />
</cffunction>

<cffunction name="logError">
    <cfargument name="msg" />
    <cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Error" />
</cffunction>

</cfsilent>