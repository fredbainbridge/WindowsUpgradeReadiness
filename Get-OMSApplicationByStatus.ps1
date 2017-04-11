#get all applications by status.

Function Get-WUApplicationStatus {
    [CmdletBinding()]
    param(
        [string]$ResourceGroupName = 'mms-eus',
        [string]$WorkSpaceName = 'cmlab'
    )

    
    $query = "Type=UAApp | measure count() by Issue"
    Write-Verbose "Starting Query $query"
    $endDate = get-date -format u
    $startDate = ((get-date).AddDays(-1)).ToString("u") 
    $result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $query -Start $startDate -End $endDate -Top 5000
    $values = $result.Value | ConvertFrom-Json
    Write-Output $values.Issue
}

Function Get-WUApplication
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='What computer name would you like to target?')
        ]
        [string]$Issue,
        [string]$ResourceGroupName = 'mms-eus',
        [string]$WorkSpaceName = 'cmlab'
    )

    $query = "Type=UAApp Issue=""$Issue"" RollupLevel=Granular "
    Write-Verbose "Starting Query $query"
    $endDate = get-date -format u
    $startDate = ((get-date).AddDays(-1)).ToString("u") 
    $result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $query -Start $startDate -End $endDate -Top 5000
    $values = $result.Value | ConvertFrom-Json
    $apps = @();
    if($values.Count -eq 5000)
    {
        $count = 5000
        $stillGoing = $true
        foreach ($app in $values.AppName)
        {
            $apps += $app
        }

        while($stillGoing)
        {
            $bigQuery = $query + "| skip $count"
            $result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $Bigquery -Start $startDate -End $endDate -Top 15000
            $values = $result.Value | ConvertFrom-Json
            foreach ($app in $values.AppName)
            {
                $apps += $app
            }
            if($values.Count -eq 5000)
            {
                $count = $count + 5000
            }
            else 
            {
                $stillGoing = $false
            }   
        }    
    }
    else 
    {
        foreach ($app in $values.AppName)
        {
            $apps += $app
        }
    }
    write-output $apps
}

Find-Module AzureRM.OperationalInsights | Install-Module -Scope CurrentUser
Login-AzureRmAccount
$AllIssue = Get-WUApplicationStatus -Verbose 
foreach($issue in $AllIssue)
{
    Get-WUApplication -Issue $issue -Verbose | Out-File -FilePath "$Issue.txt"  
}