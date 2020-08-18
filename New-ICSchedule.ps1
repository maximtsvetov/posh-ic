<#
# AUTHOR : Paul mcGurn
# TODO: Allow for more precision on date/time/recurrence settings
#>

function New-ICSchedule() 
{
<#
.SYNOPSIS
  Creates a new IC schedule
.DESCRIPTION
  Creates a new IC schedule
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICschedule
  The Interaction Center schedule
.PARAMETER Description
  [Optional] Description for the schedule.  
.PARAMETER isActive
  [Optional] Whether the schedule is active.  Defaults to false.
#>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("Schedule")] [string] $ICSchedule,
    [Parameter(Mandatory=$false)] [string] $Description="",
    [Parameter(Mandatory=$false)] [System.Boolean] $isActive=$false

  )

  $scheduleExists = Get-ICSchedule $ICSession -ICSchedule $ICSchedule
  if (-not ([string]::IsNullOrEmpty($scheduleExists))) {
    Write-Verbose "Schedule already exists, returning existing copy"
    return $scheduleExists
  }

  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }


$ICSchedule = "Paul Test"
$isActive = $false
$Description = "Paul Test"

  $configurationId = New-ICConfigurationId $ICSchedule
  #Add URI and Description to base configuration ID
  $configurationId.Add("displayName", $ICSchedule)
  $configurationId.Add("uri", "/configuration/schedules/" + [System.Web.HttpUtility]::UrlEncode($ICSchedule))


$recurrenceId = New-ICConfigurationId $ICSchedule
$recurrenceId.Add("displayName",$ICSchedule + "Recurrence1")
$recurrenceId.Add("uri", "/configuration/schedules/" + [System.Web.HttpUtility]::UrlEncode($ICSchedule + "Recurrence1"))

$recurrenceHash = [PSCustomObject]@{
  "configurationId" = $recurrenceId
  "endDate" = "2019-01-02"
  "endTime" = "00:00:00"
  "patternType" = 0
  "startDate" = "2019-01-01"
  "startTime" = "00:00:00"
  "isDaySpan" = $false
  "isRelative" = $false
  "month" = 0
  "weeklyEndTime" = "00:00:00"
  "weeklyStartTime" = "00:00:00"
  "isAllDay" = $true
}

$scheduleRecurrences = [System.Collections.ArrayList]@()
$scheduleRecurrences.Add($recurrenceHash);

  $body = ConvertTo-Json([PSCustomObject]@{
   "configurationId" = $configurationId
   "isActive" = $isActive
   "Description" = $Description
   "scheduleRecurrences" = $scheduleRecurrences
  }) -Depth 5

  Write-Verbose $body

  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/schedules" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop  
  return $response
} 

