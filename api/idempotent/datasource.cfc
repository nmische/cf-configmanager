<cfcomponent extends="CFIDE.adminapi.datasource">
	
	<cffunction name="setMSSQL">

		<cfset var savedConfigHash = getConfigHash(arguments.name) />
		<cfset var newConfigHash = hashArgs(arguments) />
		<cfset var datasources = getDatasources() />

		<!--- 
		if the datasource doesn't exist or if what we have cached 
		on disk doesn't match what we have passed in we need to do an update
		--->
		<cfif not structKeyExists(datasources,name)>
			<cfset super.setMSSQL(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# created.") />
		<cfelseif compare(savedConfigHash,newConfigHash) neq 0>
			<cfset super.setMSSQL(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# updated.") />
		<cfelse>		
			<cfset logInfo("Datasource #arguments.name# not updated.") />	
		</cfif>

		<cfreturn />

	</cffunction>

	<cffunction name="setMySQL5">

		<cfset var savedConfigHash = getConfigHash(arguments.name) />
		<cfset var newConfigHash = hashArgs(arguments) />
		<cfset var datasources = getDatasources() />

		<!--- 
		if the datasource doesn't exist or if what we have cached 
		on disk doesn't match what we have passed in we need to do an update
		--->
		<cfif not structKeyExists(datasources,name)>
			<cfset super.setMySQL5(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# created.") />
		<cfelseif compare(savedConfigHash,newConfigHash) neq 0>
			<cfset super.setMySQL5(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# updated.") />
		<cfelse>		
			<cfset logInfo("Datasource #arguments.name# not updated.") />	
		</cfif>

		<cfreturn />

	</cffunction>

	<cffunction name="setMySQL_DD">

		<cfset var savedConfigHash = getConfigHash(arguments.name) />
		<cfset var newConfigHash = hashArgs(arguments) />
		<cfset var datasources = getDatasources() />

		<!--- 
		if the datasource doesn't exist or if what we have cached 
		on disk doesn't match what we have passed in we need to do an update
		--->
		<cfif not structKeyExists(datasources,name)>
			<cfset super.setMySQL_DD(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# created.") />
		<cfelseif compare(savedConfigHash,newConfigHash) neq 0>
			<cfset super.setMySQL_DD(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# updated.") />
		<cfelse>		
			<cfset logInfo("Datasource #arguments.name# not updated.") />	
		</cfif>

		<cfreturn />

	</cffunction>

	<cffunction name="setOracle">

		<cfset var savedConfigHash = getConfigHash(arguments.name) />
		<cfset var newConfigHash = hashArgs(arguments) />
		<cfset var datasources = getDatasources() />

		<!--- 
		if the datasource doesn't exist or if what we have cached 
		on disk doesn't match what we have passed in we need to do an update
		--->
		<cfif not structKeyExists(datasources,name)>
			<cfset super.setOracle(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# created.") />
		<cfelseif compare(savedConfigHash,newConfigHash) neq 0>
			<cfset super.setOracle(argumentcollection=arguments) />
			<cfset putConfigHash(arguments.name,newConfigHash) />
			<cfset logInfo("Datasource #arguments.name# updated.") />
		<cfelse>		
			<cfset logInfo("Datasource #arguments.name# not updated.") />	
		</cfif>

		<cfreturn />

	</cffunction>

	<cffunction name="hashArgs">
		<cfargument name="args" required="true" type="struct" />
		<cfset var serializedArgs = serializeArgs(arguments.args) />
		<cfreturn hash(serializedArgs) />
	</cffunction>

	<cffunction name="serializeArgs">
		<cfargument name="args" required="true" type="struct" />
		<cfset var serializedArgs = [] />
		<cfset var key = "" />
		<cfset var keys = structKeyArray(arguments.args) />
		<cfset var sorted = arraySort(keys,"textnocase") />
		<cfloop array="#keys#" index="key">
			<cfset arrayAppend(serializedArgs,ucase(key)) />
			<cfset arrayAppend(serializedArgs,toString(arguments.args[key])) />
		</cfloop>
		<cfreturn arrayToList(serializedArgs,":") />
	</cffunction>

	<cffunction name="getConfigHash">
		<cfargument name="name" required="true" type="string" />
		<cfset var cacheFilePath = "#getDirectoryFromPath(getCurrentTemplatePath())#cache/datasource/#name#" />
		<cfset var configHash = "" />
		<cfif fileExists(cacheFilePath)>
			<cffile action="read" file="#cacheFilePath#" variable="configHash" />
			<cfreturn trim(configHash) />
		</cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="putConfigHash">
		<cfargument name="name" required="true" type="string" />
		<cfargument name="configHash" required="true" type="string" />
		<cfset var cacheDirectory = "#getDirectoryFromPath(getCurrentTemplatePath())#cache/datasource" />
		<cfset var cacheFilePath = "#cacheDirectory#/#name#" />
		<cfif not directoryExists(cacheDirectory)>
			<cfdirectory action="create" directory="#cacheDirectory#" mode="777" />
		</cfif>
		<cffile action="write" file="#cacheFilePath#" output="#configHash#" mode="644" addnewline="false" />
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