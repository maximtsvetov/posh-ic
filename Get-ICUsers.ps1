<#
# AUTHOR : Pierrick Lozach, extended by Paul McGurn
#>

function Get-ICUsers() {
  <#
.SYNOPSIS
  Gets a list of all users
.DESCRIPTION
  Gets a list of all users
.PARAMETER ICSession
  The Interaction Center Session
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession,
    [Parameter(Mandatory = $false)] [Alias("Fields", "Columns")] $Properties
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  #default URI to pull just base User objects for performance
  $uri = "$($ICsession.baseURL)/$($ICSession.id)/configuration/users"

  #we'll use the supplied properties (can be "*") to get detailed results, if the param was supplied
  if (![String]::IsNullOrEmpty($properties)) {
    Write-Verbose "Called with specific properties, will use 'select' querystring"
    $uri = "$($ICsession.baseURL)/$($ICSession.id)/configuration/users?select=${properties}"
  }

  $response = Invoke-RestMethod -Uri $uri `
    -Method Get `
    -Headers $headers `
    -WebSession $ICSession.webSession `
    -ResponseHeadersVariable responseheaders `
    -ErrorAction Stop  
  Write-Verbose "First API call result size: ${response.items.count}"

  $contentrange = $responseheaders.'Content-Range'

  $results = [System.Collections.ArrayList]@()

  foreach ($i in $response.items) {
    $results.add($i)>$null
  }
  $pcr = parseContentRange($contentrange)

  if ($pcr.total -gt 200) {
    Write-Verbose "Submitting API calls for additional users"
    #we have more API calls to submit
    foreach ($r in $pcr.AdditionalRanges) {
      Write-Verbose "Getting Users in range: ${r}"            

      $additionalrequestheaders = @{
        "Accept-Language"      = $ICSession.language;
        "ININ-ICWS-CSRF-Token" = $ICSession.token;
        "Range"                = "items=" + $r;
      }
      $headerstring = $additionalrequestheaders | ConvertTo-Json -Depth 4
      Write-Verbose "Request Headers: ${headerstring}"

      $additionalresponse = Invoke-RestMethod -Uri $uri `
        -Method Get `
        -Headers $additionalrequestheaders `
        -WebSession $ICSession.webSession `
        -ResponseHeadersVariable responseheaders `
        -ErrorAction Stop  
      $size = $additionalresponse.items.count
      Write-Verbose "Size for ${r} is ${size}"
      $responseheaders = $responseheaders | ConvertTo-Json -Depth 8
      Write-Verbose "Response headers: ${responseheaders}"

      foreach ($i in $additionalresponse.items) {
        $results.add($i)>$null
      }
    }
  }
  return $results


} 
function parseContentRange($contentrange) {
  #ex. items 1-199/1050
  $range = $contentrange.split(" ")[1]
  $total = [Int32]$range.split("/")[1]
  Write-Verbose "Total count of users: ${total}"
  $wholesets = [Math]::Floor($total / 200)
  $lastrangestart = $wholesets * 200
  $result = [PSCustomObject]@{        
    Total = $total
  }
  if ($total -gt 200) {
    Write-Verbose "Ranges are greater than 200"
    $ranges = [System.Collections.ArrayList]@()
    
    #start with second range, as the initial API call will get the first
    for ($i = 1; $i -lt $wholesets; $i++) {
      $rangestart = $i * 200
      $rangeend = $rangestart + 199

      $rangestring = "${rangestart}-${rangeend}"
      $ranges.add($rangestring)>$null        
    }
    #add the last partial range
    $lastrange = "${lastrangestart}-${total}"
    $ranges.add($lastrange)>$null
    $result | Add-Member -NotePropertyName AdditionalRanges -NotePropertyValue $ranges
  }    
  return $result
}

