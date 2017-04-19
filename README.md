# WindowsUpgradeReadiness
Sample scripts and presentation for Windows  Upgrade Readiness.

# PowerShell Scripts
Get-OMSApplicationsByStatus.ps1
-------------------------------
This will create a file for each application status containining all the applications for that particular application status.    

Get-WindowsUpgradeAppDetails.ps1
--------------------------------
This will get list of applications in WU and in ConfigMgr.  Used to ensure each data source is accurate.

# Example Queries
Get all issues for applications in your environment
```
Type=UAApp | measure count() by Issue
```

Get all ReadyForWindows Status and count
```
Type=UAApp | measure count() by ReadyForWindows
```

Get apps with a specific issue
```
Type=UAApp Issue="Application is removed during upgrade" RollupLevel=Granular |measure count() by AppName
```

All Computers (5000 of them anyway)
```
Type=UAComputer | select Computer
```
