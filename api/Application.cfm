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


<cfset rawData = GetHttpRequestData().content />
<cfif IsBinary(rawData)>
	<cfset rawData = ToString(rawData) />
</cfif>

<cfif IsJSON(rawData)>
	<cfset adminSettings = DeserializeJSON(rawData) />
<cfelse>
	<cfheader statuscode="400" statustext="Bad Request" />
	<cfabort />
</cfif>

<cfloop collection="#adminSettings#" item="objName">
	<cftry>
		<!--- for each key in the adminSettings struct, try to initilize the coresponding admin api component --->
		<cfset adminComponent = createObject("component","cfide.adminapi.#objName#") />
		<cfset adminObj = adminSettings[objName] />
		<!---
		for each key in the admin api component struct, try to invoke the corresponding setter method
		note: keys correspond to setter methods, without the "set" prefix so
		datasource.mySQL == createObject("component","cfide.adminapi.datasource).setMySQL()
		--->
		<cfloop collection="#adminObj#" item="setter">
			<cftry>

				<cfset invocations = adminObj[setter] />

				<cfloop array="#invocations#" index="args">
					<cfinvoke component="#adminComponent#" method="set#setter#" argumentCollection="#args#" />
					<cfset logInfo("Invoked #objName#.set#setter#. Arguments: #serializeJSON(args)#.") />
				</cfloop>

				<cfcatch type="any">
					<cfset logError("Error invoking #objName#.set#setter#. Error Message: #cfcatch.message#. Arguments: #serializeJSON(args)#.") />
				</cfcatch>

			</cftry>

		</cfloop>

		<cfcatch type="any">
			<cfset logError("Error creating #objName#. #cfcatch.message#") />
		</cfcatch>

	</cftry>

</cfloop>

<cfheader statuscode="200" statustext="Success" />

<cffunction name="logInfo">
	<cfargument name="msg" />
	<cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Information" />
</cffunction>

<cffunction name="logError">
	<cfargument name="msg" />
	<cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Error" />
</cffunction>

</cfsilent>