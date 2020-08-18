<#
# AUTHOR : Paul McGurn
#>

function Get-ICSchedule() {
    <#
.SYNOPSIS
  Gets a list of all schedules
.DESCRIPTION
  Gets a list of all schedules
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER Properties
  Return specific properties instead of all properties
#> # }}}3
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]  [Alias("Session", "Id")] $ICSession,
        [Parameter(Mandatory = $true)]  [Alias("Schedule")] $ICSchedule,
        [Parameter(Mandatory = $false)] [Alias("Fields", "Columns")] $Properties
    )

    $headers = @{
        "Accept-Language"      = $ICSession.language;
        "ININ-ICWS-CSRF-Token" = $ICSession.token;
    }

    #default URI to pull just base User objects for performance
    $uri = "$($ICsession.baseURL)/$($ICSession.id)/configuration/schedules/${ICSchedule}?select=*"

    #we'll use the supplied properties (can be "*") to get detailed results, if the param was supplied
    if (![String]::IsNullOrEmpty($properties)) {
        Write-Verbose "Called with specific properties, will use 'select' querystring"
        $uri = "$($ICsession.baseURL)/$($ICSession.id)/configuration/schedules/$ICSchedule?select=${properties}"
    }

    $response = Invoke-RestMethod -Uri $uri `
        -Method Get `
        -Headers $headers `
        -WebSession $ICSession.webSession `
        -ResponseHeadersVariable responseheaders `
        -ErrorAction Stop  
    
    return $response
} 


