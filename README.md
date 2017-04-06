# WindowsUpgradeReadiness
Sample scripts and presentation for Windows  Upgrade Readiness.

# Example Queries
Get all issues for applications in your environment
```
Type=UAApp | measure count() by Issue
```

Get apps with a specific issue
```
Type=UAApp Issue="Application is removed during upgrade" RollupLevel=Granular |measure count() by AppName
```

All Computers (5000 of them anyway)
```
Type=UAComputer | select Computer
```
