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
    $uri = "$($ICsession.baseURL)/$($ICSession.id)/configuration/users?select=${properties}"
  }

  $response = Invoke-RestMethod -Uri $uri `
    -Method Get `
    -Headers $headers `
    -WebSession $ICSession.webSession `
    -ResponseHeadersVariable responseheaders `
    -ErrorAction Stop  

  #TODO: Add Content-Range handling for result sets > 200 items
  if (!([String]::IsNullOrEmpty($responseheaders.'Content-Range'))) {
    Write-Verbose "NOTE: API indicated result set is largger than a single API call, results may be truncated"
  }

  return $response.items
} 

