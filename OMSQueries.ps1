Find-Module AzureRM.OperationalInsights | Install-Module
Import-Module AzureRm.OperationalInsights
Get-Module AzureRm.OperationalInsights

Login-AzureRmAccount

$ResourceGroupName = "mms-eus"
$WorkSpaceName = "cmlab"

$query = Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName
$query.value |FL

#Get all bad apps for a device
$ComputerName = 'WIN7-15'
$query = "Computer=$ComputerName Type=UASysReqIssue UpgradeAssessment!=""Seamless upgrade"" UpgradeAssessment!=""No known issues"""
$endDate = get-date -format u
$startDate = ((get-date).AddDays(-1)).ToString("u") 
$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $query -Start $startDate -End $endDate
$values = $result.Value | ConvertFrom-Json
if($values)
{
    Write-Host "Device Not eligible for upgrade.  Blocking issue found"
}
else 
{
    Write-Verbose "No blocking issues found."    
}
