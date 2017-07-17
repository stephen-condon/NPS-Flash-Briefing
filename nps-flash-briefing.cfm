<cftry>

	<cfset api_base="http://developer.nps.gov/api/v0/" />
	<cfset api_headers = { "Authorization":"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" } />

	<cfhttp url="#api_base#newsreleases?sort=-releaseDate&limit=1" method="get" result="parkData" timeout="5">
		<!--- Loop through headers to be passed --->
		<cfloop collection="#api_headers#" item="header_name">
			<cfhttpparam name="#header_name#" type="header" value="#api_headers[header_name]#" />
		</cfloop>
	</cfhttp>

	<cfset newsData = DeserializeJSON(parkData.filecontent).data />
	<cfset briefingArray = ArrayNew(1) />

	<!--- We loop through result set, in case we want to send more than one news release in the future --->
	<cfloop from="1" to="#ArrayLen(newsData)#" step="1" index="i">
		<cfset UTCDate = DateConvert( "Local2UTC", newsData[i].releaseDate ) />
		<cfset briefingArray[i] = StructNew() />
		
		<cfset briefingArray[i]["uid"] = "#CreateUUID()#" />
		<cfset briefingArray[i]["updateDate"] = '#DateFormat(UTCDate, "yyyy-mm-dd")#T#TimeFormat(UTCDate, "HH:mm:ss.l")#Z' />
		<cfset briefingArray[i]["titleText"] = newsData[i].title />
		<cfset briefingArray[i]["mainText"] = newsData[i].abstract />
		<cfset briefingArray[i]["redirectionUrl"] = newsData[i].url />
	</cfloop>

	<cfheader name="Content-Type" value="application/json">
	<!--- Make sure we get the most recent news release --->
	<cfheader name="expires" value="#now()#">
	<cfheader name="pragma" value="no-cache">
	<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	<cfcontent type="application/json; charset=utf-8" variable="#toBinary(toBase64(serializeJSON(briefingArray)))#" />

	<cfcatch>
		<!--- If we error out, log the cfcatch struct for debugging --->
		<cflog text="#SerializeJSON(cfcatch)#" type="information" file="alexa_debug" />
	</cfcatch>
</cftry>