<#
# AUTHOR : Pierrick Lozach
#>

function Get-ICLicenseAllocations() {
  <#
.SYNOPSIS
  Gets a list of all additional licenses
.DESCRIPTION
  Gets a list of all additional licenses, as shown in the User "Licensing" tab
.PARAMETER ICSession
  The Interaction Center Session
#>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession
  )

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/license-allocations?select=*" -Method Get -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop

  return $response.items
}

