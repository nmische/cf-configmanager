<cfsilent>

<cflock name="CF_CONFIGMANAGER_CONFIG" type="exclusive" timeout="60" throwontimeout="true">

<cfloop collection="#jsonData#" item="objName">
    <cftry>
        <!--- for each key in the adminSettings struct, try to initilize the coresponding admin api component --->

        <cfif fileExists(expandPath("./idempotent/#lcase(objName)#.cfc"))>
            <cfset adminComponent = createObject("component","idempotent.#objName#") />
        <cfelseif listFirst(server.coldfusion.productversion) gte 10 and objName eq "servermanager">
            <!--- CF10 broke servermanager out into a bunch of components under _servermanager.  Create the intended component --->
            <cfset adminComponent = createObject("component","CFIDE.adminapi._servermanager.servermanager") />
        <cfelse>
            <cfset adminComponent = createObject("component","CFIDE.adminapi.#objName#") />
        </cfif>
        
        <cfset adminObj = jsonData[objName] />
        <!---
        for each key in the admin api component struct, try to invoke the corresponding setter method
        note: keys correspond to setter methods, without the "set" prefix so
        datasource.mySQL == createObject("component","cfide.adminapi.datasource).setMySQL()
        --->
        <cfloop collection="#adminObj#" item="setter">
            <cftry>

                <cfset invocations = adminObj[setter] />

                <!--- handle the very special case of calling one of the cf10 servermanager methods that takes a single argument: an array of helper objects --->
                <!--- eg: remote struct setMappings ( required CFIDE.adminapi._servermanager.mappingswrapper[] mappings ) --->
                <cfset meta = getMetadata(adminComponent) />
                <cfif listFirst(server.coldfusion.productversion) gte 10 and objName eq "servermanager" >
                    <!--- find out what this component wants to hear --->
                    <cfset meta = getMetadata(adminComponent) />
                    <cfset functionMeta = {} />
                    <cfloop array="#meta.functions#" index="fn">
                        <cfif fn.name eq "set#setter#">
                            <cfset functionMeta = fn />
                            <cfbreak />
                        </cfif>
                    </cfloop>

                    <!--- if this method takes a single array-of-objects argument, convert that arg to array of objects --->
                    <cfif !structIsEmpty(functionMeta)
                            and arrayLen(functionMeta.parameters) eq 1
                            and functionMeta.parameters[1].type contains "[]"
                            and functionMeta.parameters[1].type contains "CFIDE.adminapi" >

                        <!--- ok it's supposed to be an array of CFIDE objects; convert --->
                        <cfset argumentTypeName = replace(functionMeta.parameters[1].type, "[]", "") />

                        <!--- convertedArgs will be our array of objects --->
                        <cfset convertedArgs = [] />
                        <!--- the invocations array is actually the array of objects used for the argument[], in this special case --->
                        <cfloop array="#invocations#" index="arg">
                            <cfset obj = createObject("component", argumentTypeName) />
                            <!--- for each struct element, set the object's corresponding property --->
                            <cfloop collection="#arg#" item="argName">
                                <cfset obj[argName] = arg[argName] />
                            </cfloop>
                            <cfset arrayAppend(convertedArgs, obj) />
                        </cfloop>
                        <!--- create an argumentCollection with the array parameter's name --->
                        <cfset argCollection = {#fn.parameters[1].name#=convertedArgs} />
                        <cfinvoke component="#adminComponent#" method="set#setter#" argumentCollection="#argCollection#" />

                        <!--- we're done here; iterate to next adminobj setter --->
                        <cfset logInfo("Invoked #objName#.set#setter#. Arguments[]: #serializeJSON(invocations)#.") />
                        <cfcontinue />
                    </cfif>

                </cfif>
                <cfif listContainsNoCase("clearComponentCache,clearTrustedCache", setter)>
                    <cfloop array="#invocations#" index="args">
                        <cfinvoke component="#adminComponent#" method="#setter#" argumentCollection="#args#" />
                        <cfset logInfo("Invoked #objName#.#setter#. Arguments: #serializeJSON(args)#.") />
                    </cfloop>
                <cfelse>
                    <cfloop array="#invocations#" index="args">
                        <cfinvoke component="#adminComponent#" method="set#setter#" argumentCollection="#args#" />
                        <cfset logInfo("Invoked #objName#.set#setter#. Arguments: #serializeJSON(args)#.") />
                    </cfloop>
                </cfif>

            <cfcatch type="any">
                <cfset logError("Error invoking #objName#.set#setter#. Error Message: #cfcatch.message#. Arguments: #serializeJSON(args)#.") />
                <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
                <cfabort />
            </cfcatch>

            </cftry>

        </cfloop>

        <cfcatch type="any">
            <cfset logError("Error creating #objName#. #cfcatch.message#") />
            <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
            <cfabort />
        </cfcatch>

    </cftry>

</cfloop>

</cflock>

<cfheader statuscode="200" statustext="Success" />

</cfsilent>