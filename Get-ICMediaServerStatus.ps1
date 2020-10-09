<#
# AUTHOR : Paul McGurn
#>
#NOTE: Media Server REST API is not enabled by default.  If this command returns a error 404 or 401, that is likely why.

function Get-ICMediaServerStatus() {
  <#
  .SYNOPSIS
    Returns the media server / command server status for each linked CIC server in an arraylist
  .DESCRIPTION
    Returns the media server / command server status for each linked CIC server in an arraylist
  .PARAMETER Server
    The media server to query
  .PARAMETER User
    The media server username to log on with
  .PARAMETER Password
    The media server password to log on with.  Must be of type System.SecureString for adequate runtime security.
  .EXAMPLE
    $user = 'someuser'
    $password = ConvertTo-SecureString 'Super$strong##' -AsPlainText
    $s = Get-ICMediaServerStatus -Server 'mymediaserver.example.com' -User $user -Password $password
  #>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]  [Alias("Computer", "MediaServer")] $Server,
    [Parameter(Mandatory = $true)] [Alias("username", "id")] $User,
    [Parameter(Mandatory = $true)] [Alias("pass")] [SecureString]$Password
  )

  $cred = New-Object System.Management.Automation.PSCredential $User, $Password
  $uri = "http://" + $server + ":8102/api/v1/commandservers"  #Port 8102 is the default port for this API
  
  #TODO: Configure support for HTTPS
  $response = Invoke-RestMethod -Uri $uri -Method GET -Credential $cred -AllowUnencryptedAuthentication
  $response.commandServers
}