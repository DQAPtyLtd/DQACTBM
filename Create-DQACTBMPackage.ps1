<#
.SYNOPSIS

  Generates Web Server Deployment Package for DQA CTBM Scripts and Configuration

.DESCRIPTION

  Generates Zip file and MD5 file for WEb Deployment of DQA CTBM Script and Configuration Package

  1. Create Zip file Script Package and Image Package Management Scripts and DQA CTBM Configuration file
  2. Create MD5 file of Script and Configuration Package

.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

  .\Create-DQACTBMPackage.ps1

#>

###########################
#    CTBM Configuration    #
###########################

#Current Script Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition


#CTBM Configuration File
$CTBMConfig = "$PSScriptRoot\DQACTBM.config"
$CTBMConfig = Get-Content -Raw -Path $CTBMConfig | ConvertFrom-Json

### Script Package Names
$CTBMPackage = $CTBMConfig.CTBMPackage.Split(".")
$CTBMPackageMD5 = $CTBMPackage[0] + ".md5"
$CTBMPackage = $CTBMPackage[0] + ".zip"


###########################
#    Script Execution     #
###########################

#Create Script Package
Compress-Archive -LiteralPath "$PSScriptRoot\Update-DQACTBM.ps1", "$PSScriptRoot\Sync-DQACTBMImages.ps1", "$PSScriptRoot\DQACTBM.config", "$PSScriptRoot\run-dqaCTBMupdate.vbs", "$PSScriptRoot\run-dqaCTBMimgupdate.vbs" -DestinationPath "$PSScriptRoot\Packages\$CTBMPackage" -Force

#Create MD5 Hash of Archive
$FileHash = Get-FileHash -Path "$PSScriptRoot\Packages\$CTBMPackage"
#Write MD5 to Disk
Set-Content -Path "$PSScriptRoot\Packages\$CTBMPackageMD5" -Value $FileHash.Hash -Force