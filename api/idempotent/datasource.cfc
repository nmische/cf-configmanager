<cfcomponent extends="CFIDE.adminapi.datasource">
	
	<cffunction name="setMSSQL">
		<cfargument name="vendor" default="sqlserver" type="string" />
		<cfargument name="type" default="ddtek" type="string" />
		<cfargument name="name" required="true" type="string" />
		<cfargument name="host" required="true" type="string" />
		<cfargument name="database" required="true" type="string" />
		<cfargument name="originaldsn" default="" type="string" />
		<cfargument name="port" default="1433" type="string" />
		<cfargument name="driver" default="MSSQLServer" type="string" />
		<cfargument name="class" default="macromedia.jdbc.MacromediaDriver" type="string" />
		<cfargument name="username" default="" type="string" />
		<cfargument name="password" default="" type="string" />
		<cfargument name="encryptpassword" default="true" type="boolean" />
		<cfargument name="description" default="" type="string" />
		<cfargument name="args" type="string" />
		<cfargument name="sendStringParametersAsUnicode" type="boolean" />
		<cfargument name="selectmethod" default="cursor" required="true" type="string" />
		<cfargument name="MaxPooledStatements" type="numeric" />
		<cfargument name="timeout" type="numeric" />
		<cfargument name="interval" type="numeric" />
		<cfargument name="login_timeout" type="numeric" />
		<cfargument name="buffer" type="numeric" />
		<cfargument name="blob_buffer"type="numeric" />
		<cfargument name="enablemaxconnections" type="boolean" />
		<cfargument name="maxconnections" type="numeric" />
		<cfargument name="pooling" type="boolean" />
		<cfargument name="disable" type="boolean" />
		<cfargument name="disable_clob" type="boolean" />
		<cfargument name="disable_blob" type="boolean" />
		<cfargument name="disable_autogenkeys" type="boolean" />
		<cfargument name="select" type="boolean" />
		<cfargument name="create" type="boolean" />
		<cfargument name="grant" type="boolean" />
		<cfargument name="insert" type="boolean" />
		<cfargument name="drop" type="boolean" />
		<cfargument name="revoke" type="boolean" />
		<cfargument name="update" type="boolean" />
		<cfargument name="alter" type="boolean" />
		<cfargument name="storedproc" type="boolean" />
		<cfargument name="delete" type="boolean" />
		<cfargument name="validationQuery" default="" type="string" />
		<cfargument name="qTimeout" type="numeric" />
		<cfargument name="useSpyLog" type="boolean" />
		<cfargument name="spyLogFile" type="string" />
		<cfargument name="validateConnection" type="boolean" />
		<cfargument name="clientHostName" type="boolean" />
		<cfargument name="clientuser" type="boolean" />
		<cfargument name="applicationName" type="boolean" />
		<cfargument name="applicationNamePrefix" type="string" />


		<!--- if the datasource does not exist create it --->
		<cfset var datasources = getDatasources() />
		<cfset var testArgs = "" />
		<cfset var tmpName = "" />
		<cfset var existing = "" />
		<cfset var updated = "" />
		
		<cfif not structKeyExists(datasources,name)>
			<cfset super.setMSSQL(argumentcollection=arguments) />
			<cfset logInfo("Datasource #arguments.name# created.") />
			<cfreturn />
		</cfif>

		<!--- if the datasource does exist test to see if we need to update it --->
		<cfset testArgs = duplicate(arguments) />
		<cfset testArgs.name = tmpName = "#arguments.name#_config_test" />
		<cfset super.setMSSQL(argumentcollection=testArgs) />
		<cfset existing = getDatasources(arguments.name) />
		<cfset updated = getDatasources(tmpName) />
		<cfif datasourcesAreEqual(existing,updated,comparePasswords)>	
			<cfset logInfo("Datasource #arguments.name# not updated.") />		
		<cfelse>
			<cfset super.setMSSQL(argumentcollection=arguments) />
			<cfset logInfo("Datasource #arguments.name# updated.") />
			<cfreturn />
		</cfif>
		<cfset deleteDatasource(tmpName) />

		<cfreturn />

	</cffunction>

	<cffunction name="datasourcesAreEqual">
		<cfargument name="datasource1" />
		<cfargument name="datasource2" />
		<cfargument name="comparePasswords" />

		<cfset var key="" />

		<cfloop collection="#datasource1#" item="key">
			<!--- skip name, password, non simple values, and missing keys --->
			<cfif key eq "name"
			      or key eq "password"
			      or not isSimpleValue(datasource1[key]) 
			      or not structKeyExists(datasource2,key)>
				<cfcontinue />
			</cfif>
			<cfif not isSimpleValue(datasource2[key])
				  or compareNoCase(datasource1[key],datasource2[key]) neq 0 >
				<cfset logInfo("Datasource #arguments.name# update triggered by difference in #key#.") />
				<cfreturn false />
			</cfif>
		</cfloop>

		<cfreturn true />

	</cffunction>

	<cffunction name="logInfo">
		<cfargument name="msg" />
		<cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Information" />
	</cffunction>

	<cffunction name="logError">
		<cfargument name="msg" />
		<cflog text="#Replace(arguments.msg,"""","'","all")#" application="no" file="configmanager" type="Error" />
	</cffunction>

</cfcomponent>