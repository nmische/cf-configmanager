<cfinclude template="../header.cfm">

<cfscript>

debugger = createObject("component", "cfide.adminapi.debugging");

logfolder = debugger.getLogProperty("logdirectory");

function tailFile(filename) {
	try {
		var line = "";
		var lines = "";
		var theFile = createObject("java","java.io.File").init(filename);
		var raFile = createObject("java","java.io.RandomAccessFile").init(theFile,"r");
		var pos = theFile.length();
		var c = "";
		var total = 10;
		
		if(arrayLen(arguments) gte 2) total = arguments[2];
		raFile.seek(pos-1);

		while( (listLen(line,chr(10)) <= total) && pos > -1) {
			c = raFile.read();
			//if(c != -1) writeOutput("#c#=" & chr(c) & "<br/>");
			if(c != -1) line &= chr(c);
			raFile.seek(pos--);	
		}

		line = reverse(line);
		lines = listToArray(line, chr(10));
		arrayDeleteAt(lines,1);

		raFile.close();

		return lines;
	
	} catch (any e) {		
		return [];
	};
}

events = tailFile("#logfolder#/configmanager.log",20);
</cfscript>


<h2 class="pageHeader">Configuration Manager</h2>

<br>
This page lists recent changes made by remote Admin API calls. The full log can be found at <cfoutput>#logfolder#/configmanager.log</cfoutput>. 
<br>
<br>

<table width="100%" cellspacing="0" cellpadding="5" border="0">
	
	<tr>
		<td class="cellBlueTopAndBottom" bgcolor="#E2E6E7">
			<b> Recent API Calls </b>
		</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellspacing="0" cellpadding="2" border="0">				
				<tr>
					<th class="cellBlueTopAndBottom" width="50" nowrap="" bgcolor="#F3F7F7" scope="col">
						<strong> Log Entry </strong>
					</th>
				</tr>
				<cfloop from="#ArrayLen(events)#" index="i" to="1" step="-1">
				<tr bgcolor="ffffff">
					<td class="cell3BlueSides">
					<cfoutput>#events[i]#</cfoutput>
					</td>
				</tr>
				</cfloop>
				
			</table>
		</t>
	</tr>
	
</table>

<cfinclude template="../footer.cfm">