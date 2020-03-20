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
    [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users?select=*" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  
  return $response
} 

