<#
# AUTHOR : Pierrick Lozach, extended by Paul McGurn
#>

function Remove-ICUser() {
  <#
.SYNOPSIS
  Removes a user
.DESCRIPTION
  Removes a user
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User
#>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory = $true)] [Alias("User")] [string] $ICUser
  )

  # User exists?
  $userExists = Get-ICUser $ICSession -ICUser "${ICUser}"
  if ([string]::IsNullOrEmpty($userExists)) {
    # User does not exist
    Write-Host "User ${ICUser} does not exist, no action taken"
    return
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users/$ICUser" -Method Delete -Headers $headers -WebSession $ICSession.webSession
  return $response
}

