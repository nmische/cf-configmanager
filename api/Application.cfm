<cfsilent>

<cfapplication name="configmanagerapi" sessionmanagement="false" clientmanagement="false" />

<cfset username="" />
<cfset password="" />

<!--- check credentials --->
<cfset authHeader = GetPageContext().getRequest().getHeader("Authorization") />
<cfif IsDefined("authHeader")>
	<cfset authString = ToString(BinaryDecode(ListLast(authHeader, " "),"Base64")) />
	<cfset username = GetToken(authString,1,":") />
	<cfset password = GetToken(authString,2,":") />
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