<#
.SYNOPSIS

  Generates Web Server Deployment Package for DQA CTBM Image Templates

.DESCRIPTION

  Generates Zip file and MD5 file for WEb Deployment of DQA CTBM Image Templates

  1. Create Zip file Teams Custom Background Images
  2. Create MD5 file of Teams Custom Background Images
.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

  .\Create-DQACTBMImagesPackage.ps1

#>

###########################
#    CTBM Configuration    #
###########################

#Current Script Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#CTBM Configuration File
$CTBMConfig = "$PSScriptRoot\DQACTBM.config"
$CTBMConfig = Get-Content -Raw -Path $CTBMConfig | ConvertFrom-Json

### Template Package Names
$CTBMTemplatePackage = $CTBMConfig.CTBMTemplatePackage.Split(".")
$CTBMTemplatePackageMD5 = $CTBMTemplatePackage[0] + ".md5"
$CTBMTemplatePackage = $CTBMTemplatePackage[0] + ".zip"

###########################
#    Script Execution     #
###########################

#Create Script Package
$Images = "$PSScriptRoot\Images"
& chdir $Images
Compress-Archive -Path * -DestinationPath "$PSScriptRoot\Packages\$CTBMTemplatePackage" -Force

#Create MD5 Hash of Archive
$FileHash = Get-FileHash -Path "$PSScriptRoot\Packages\$CTBMTemplatePackage"
#Write MD5 to Disk
Set-Content -Path "$PSScriptRoot\Packages\$CTBMTemplatePackageMD5" -Value $FileHash.Hash -Force