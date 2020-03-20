<#
# AUTHOR : Pierrick Lozach, Extended by Paul McGurn
#>

function Get-ICUser() {
  <#
.SYNOPSIS
  Gets a user
.DESCRIPTION
  Gets a user
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User
.PARAMETER Fields
  The user fields to include with the returned user object, ex. extension, ntDomainUser, etc.  Comma-separated list of case-sensitive fields.
#>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession,
    [Parameter(Mandatory = $true)] [Alias("User")] [string] $ICUser,
    [Parameter(Mandatory = $false)] [string]$fields
  )

  if (! $PSBoundParameters.ContainsKey('ICUser')) {
    $ICUser = $ICSession.user
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = '';
  $requesturi = "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/${ICUser}?select=*"

  try {
    $response = Invoke-RestMethod -Uri $requesturi -Method Get -Headers $headers -WebSession $ICSession.webSession
  }
  catch {
    # If user not found, ignore the exception
    if (-not ($_.Exception.message -match '404')) {
      Write-Verbose "User not found, exiting silently"
    }
  }
  return $response
}

