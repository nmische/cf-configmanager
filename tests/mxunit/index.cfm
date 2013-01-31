<cfsetting showdebugoutput="false" requesttimeout="300" />

<cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#expandPath('./suite')#"
          componentPath="cf-configmanager.tests.mxunit.suite"
          recurse="true"
          returnvariable="results" />
 
<cfoutput> #results.getResultsOutput('extjs')# </cfoutput>