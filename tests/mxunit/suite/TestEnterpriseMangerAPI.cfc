<cfcomponent extends="mxunit.framework.TestCase" mxunit:decorators="mxunit.framework.decorators.OrderedTestDecorator">

    <cffunction name="beforeTests">
        <cfscript>
            variables.apiUrl = "http://127.0.0.1:8500/CFIDE/administrator/configmanager/api/entmanager.cfm";
            variables.username = "admin";
            variables.password = "vagrant";
        </cfscript>
    </cffunction>

    <cffunction name="testAuthenticaitonNoCredentials" order="1">
        <cfset var apiResult = "" />
        <cfhttp url="#variables.apiUrl#" method="get" result="apiResult" />
        <cfset assertEquals("401 UNAUTHORIZED",apiResult.statusCode) />
    </cffunction>

    <cffunction name="testAuthenticaitonWithCredentials" order="2">
        <cfset var apiResult = "" />
        <cfhttp url="#variables.apiUrl#" method="get" username="#variables.username#" password="#variables.password#" result="apiResult" />
        <cfset assertEquals("400 BAD REQUEST",apiResult.statusCode) />
    </cffunction>

    <cffunction name="testAddSever1WithoutServerDir" order="3">
        <cfset var apiResult = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addServer"", ""params"" :{ ""serverName"" : ""test1"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
        <cfset assertTrue(DirectoryExists("/opt/coldfusion10/test1")) />

    </cffunction>

    <cffunction name="testAddSever2WithServerDir" order="4">
        <cfset var apiResult = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addServer"", ""params"" :{ ""serverName"" : ""test2"", ""serverDir"" : ""/opt/coldfusion10/test2"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
        <cfset assertTrue(DirectoryExists("/opt/coldfusion10/test2")) />

    </cffunction>

    <cffunction name="testAddRemoteSever1WithRequiredParams" order="5">
        <cfset var apiResult = "" />
        <cfset var instances_xml = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addRemoteServer"", ""params"" :{ ""remoteServerName"" : ""testRemote1"", ""host"" : ""192.168.33.12"", ""jvmRoute"" : ""cfusion"", ""remotePort"" : ""8012"", ""httpPort"" : ""8005"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
        <cffile action="read" file="/opt/coldfusion10/config/instances.xml" variable="instances_xml" />
        <cfset assertTrue(Find("testRemote1",instances_xml) gt 0,"Expected to find 'testRemote1' in instances.xml") />

    </cffunction>

    <cffunction name="testAddCluster1ByName" order="6">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster1""} }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster1']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster1' in cluster.xml") />
        <cfset assertEquals("45564",cluster_node[1].port.XmlText) />

    </cffunction>

    <cffunction name="testAddCluster2ByNameAndStickySessions" order="7">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster2"", ""stickySessions"" : ""false"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster2']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster2' in cluster.xml") />
        <cfset assertEquals("45565",cluster_node[1].port.XmlText) />

    </cffunction>


    <cffunction name="testAddCluster3ByNamePortAndStickySessions" order="8">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster3"", ""multicastPort"" : ""45588"", ""stickySessions"" : ""false"" } }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster3']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster3' in cluster.xml") />
        <cfset assertEquals("45588",cluster_node[1].port.XmlText) />

    </cffunction>

    <cffunction name="testAddCluster4ByNameWithServers" order="9">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />
        <cfset var server_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster4"", ""servers"": ""cfusion,testRemote1""} }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster4' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/../server[normalize-space(text()) = 'cfusion']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'cfusion' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/../server[normalize-space(text()) = 'testRemote1']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'testRemote1' in cluster.xml") />

       
      
    </cffunction>

    <cffunction name="testUpdateCluster4ByNameWithServersAndPort" order="10">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />
        <cfset var server_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster4"", ""servers"": ""cfusion,testRemote1"", ""multicastPort"" : ""45599""} }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster4' in cluster.xml") />
        <cfset assertEquals("45599",cluster_node[1].port.XmlText) />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/../server[normalize-space(text()) = 'cfusion']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'cfusion' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster4']/../server[normalize-space(text()) = 'testRemote1']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'testRemote1' in cluster.xml") />
      
    </cffunction>

    <cffunction name="testAddCluster5ByNameWithServers" order="11">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />
        <cfset var server_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster5"", ""servers"": ""test1,test2""} }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster5' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/../server[normalize-space(text()) = 'test1']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'test1' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/../server[normalize-space(text()) = 'test2']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'test2' in cluster.xml") />
      
    </cffunction>

    <cffunction name="testAddCluster5ByNameWithDifferentServers" order="12">
        <cfset var apiResult = "" />
        <cfset var cluster_xml = "" />
        <cfset var cluster_xml_doc = "" />
        <cfset var cluster_node = "" />
        <cfset var server_node = "" />

        <cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="{ ""action"" : ""addCluster"", ""params"" :{ ""clusterName"" : ""testCluster5"", ""servers"": ""test1,testRemote1""} }"/>
        </cfhttp>

        <cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

        <cffile action="read" file="/opt/coldfusion10/config/cluster.xml" variable="cluster_xml" />
        <cfset cluster_xml_doc = XmlParse(cluster_xml) />
        <cfset cluster_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/..") />
        <cfset assertTrue(ArrayLen(cluster_node) eq 1, "Expected to find 'testCluster5' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/../server[normalize-space(text()) = 'test1']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'test1' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/../server[normalize-space(text()) = 'test2']") />
        <cfset assertTrue(ArrayLen(server_node) eq 0,"Expected not to find 'test2' in cluster.xml") />
        <cfset server_node = XmlSearch(cluster_xml_doc,"//cluster/name[normalize-space(text()) = 'testCluster5']/../server[normalize-space(text()) = 'testRemote1']") />
        <cfset assertTrue(ArrayLen(server_node) eq 1,"Expected to find 'testRemote1' in cluster.xml") />
      
    </cffunction>

    
</cfcomponent>