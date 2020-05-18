<#
.SYNOPSIS

  Generates Configuration for DQA CTBM

.DESCRIPTION

  Installs the DQA CTBM Program

  1. Generates DQACTBM.config in JSON format the same directory where this script is executed
  2. Bases configuation on values configured in this script


.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

# Update configuration values within the script then execute below
  .\Generate-DQACTBMConfig.ps1


#>

###########################
#    CTBM Configuration    #
###########################

 #JSON Output path
    #Current Script Location
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

    $outFilePath = "$PSScriptRoot\DQACTBM.config"

 #JSON Body response (Update values below to customise your DQA CTBM Deployment)
    $configureEmailSignatureManagerParameters= @{
        CTBMTemplatePackage = "DQACTBMImages.zip"
        CTBMImagePrefix = "DQA-"
        CTBMPackage = "DQACTBM.zip"
        CTBMURL = "https://sampleurl.com/CTBM/"
        CTBMTemplatesURL = "https://sampleurl.com/teamsbkgrds/"

    }

###########################
#    Script Execution     #
###########################

#Prepare Response
$configureEmailSignatureManagerParameters = ConvertTo-Json $configureEmailSignatureManagerParameters

#Write to Disk
Set-Content -Path $outFilePath -Value $configureEmailSignatureManagerParameters

#Show Output to Screen
Write-Output $configureEmailSignatureManagerParameters