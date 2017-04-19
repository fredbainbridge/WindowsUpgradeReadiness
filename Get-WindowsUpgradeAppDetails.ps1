# This script get app detail from WU and from CM
# Two txt files are created, one for WU apps and one for CM apps.

Function Get-WUAppDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='What computer name would you like to target?')
        ]
        [string]$ComputerName,
        [string]$ResourceGroupName = 'mms-eus',
        [string]$WorkSpaceName = 'Win10-App-Compat'
    )
    Find-Module AzureRM.OperationalInsights | Install-Module -Scope CurrentUser
    Write-Verbose "Resource Group Name - $ResourceGroupName"
    Write-Verbose "WorkSpaceName - $WorkSpaceName"
    
    Login-AzureRmAccount 

    #Get Computer names we care about.
    
    $query = "Type=UAApp Computer = ""$ComputerName"" |  measure count() by AppName"
    $endDate = get-date -format u
    $startDate = ((get-date).AddDays(-1)).ToString("u")
    $result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $query -Start $startDate -End $endDate -Top 15000
    $values = $result.Value | ConvertFrom-Json
    $apps = @();
    Foreach ($value in $values)
    {
        $apps += $value.AppName
    }
    $apps = $apps | sort
    $OutputFile = "appdata\AppDetails-$ComputerName-WU.txt"
    if(test-path $OutputFile)
    {
        Remove-Item $OutputFile -force
    }
    foreach ($app in $apps)
    {   
        $app | Out-File -FilePath $OutputFile -Append
    }
    
}

Function Get-CMAppDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='What computer name would you like to target?')
        ]
        [string]$ComputerName,
        [string]$SiteServer = "cm01.cm.lab",
        [string]$SiteCode = "LAB"
    )
    $WQL = "select distinct ARP.DisplayName, ARP.Version from  SMS_R_System as Sys inner join SMS_G_System_ADD_REMOVE_PROGRAMS as ARP on ARP.ResourceID = Sys.ResourceId where Sys.Name = ""$ComputerName"""
    $CMapps = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Query $WQL -ComputerName $SiteServer
    $apps = @();
    foreach($app in $CMapps)
    {
        $apps += $app.DisplayName
    }
    $apps = $apps | Sort-Object
    $OutputFile = "appdata\AppDetails-$ComputerName-CM.txt"
    if(test-path $OutputFile)
    {
        Remove-Item $OutputFile -force
    }
    foreach ($app in $apps)
    {   
        write-verbose $app -Verbose
        if($app -notlike "*Security Update*")
        {
            $app | Out-File -FilePath $OutputFile -Append
        }
    }
}

$ComputerNames = Get-Content -Path "ComputerNamesForAppDetails.txt"
#$ComputerNames = 'ABCComputer'
foreach ($computer in $ComputerNames)
{
    $computer = $computer.trim()
    Get-WUAppDetails -ComputerName $computer
    Get-CMAppDetails -ComputerName $computer
}
