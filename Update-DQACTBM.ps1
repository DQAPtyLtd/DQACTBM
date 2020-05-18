<#
.SYNOPSIS

  Downloads and manages DQA CTBM Script and Configuration Pack to Local Machine

.DESCRIPTION

  Downloads DQA CTBM Script and Configuration Pack to Local Machine

  1. Check if MD5 Hash has changed
  2. Bases configuation using DQACTBM.config file
  3. Download Script and Configuration Pack from WebServer
  4. Unpack Script and Configuration Pack

.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

  .\Update-DQACTBM.ps1

#>

###########################
#    CTBM Configuration    #
###########################

#Current Script Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#CTBM Configuration File
$CTBMConfig = "$PSScriptRoot\DQACTBM.config"
$CTBMConfig = Get-Content -Raw -Path $CTBMConfig | ConvertFrom-Json


###########################
#       Functions         #
###########################

#Function to extract zip files
function unzip ($file,$ExtractPath) {
   expand-archive -Path $file -DestinationPath $ExtractPath -Force
}


###########################
#    Script Execution     #
###########################


#  Collect Configuration  #

### Set Base Variable
$UpdateCTBMPackage = $false

### Script Package Names
$CTBMPackage = $CTBMConfig.CTBMPackage.Split(".")
$CTBMPackageMD5 = $CTBMPackage[0] + ".md5"
$CTBMPackage = $CTBMPackage[0] + ".zip"

### Script Package URLs
$CTBMPackageMD5URL = $CTBMConfig.CTBMURL + "$CTBMPackageMD5"
$CTBMPackageURL = $CTBMConfig.CTBMURL + "$CTBMPackage"

#      Version Check      #

### Check if MD5 exists for CTBM Script Package

$localScriptPackMD5 = "$PSScriptRoot\$CTBMPackageMD5"
$localScriptPack = "$PSScriptRoot\$CTBMPackage"

$CheckMD5 = Test-Path -Path $localScriptPackMD5

### Clean installation of Script Pack (No previous download)
If ($CheckMD5 -eq $false) {

   Invoke-WebRequest -Method GET -Uri $CTBMPackageMD5URL -OutFile $localScriptPackMD5 -UseBasicParsing
   Invoke-WebRequest -Method GET -Uri $CTBMPackageURL -OutFile $localScriptPack -UseBasicParsing

   ###Set Flag to let script know to clear previous Outlook Email Signature from User Profile before unpacking new CTBM Script pack
   $UpdateCTBMPackage = $true

} else {

   ###Collect and store local Script pack MD5 hash variable
   $localScriptPackMD5Hash = Get-Content -Raw -Path $localScriptPackMD5
   ###Collect and store remote Script pack MD5 hash variable
   $remoteScriptPackMD5Hash = Invoke-WebRequest -Method GET -Uri $CTBMPackageMD5URL -UseBasicParsing

   ###Compare Hash Values if different overwrite local MD5 and Script Pack ZIP file otherwise do nothing
   $remoteScriptPackMD5Hash = [string]$remoteScriptPackMD5Hash
         If ($localScriptPackMD5Hash -ne $remoteScriptPackMD5Hash)
            {
               Write-Output "Downloading Latest CTBM Script Package and MD5 Hash"
               #Download Latest Script Package MD5 and ZIP files
               Invoke-WebRequest -Method GET -Uri $CTBMPackageMD5URL -OutFile $localScriptPackMD5 -UseBasicParsing
               Invoke-WebRequest -Method GET -Uri $CTBMPackageURL -OutFile $localScriptPack -UseBasicParsing

               #Set Flag to let script know to clear previous Outlook Email Signature from User Profile before unpacking new CTBM Script pack
               $UpdateCTBMPackage = $true

         } else {

            Write-Output "You have the latest CTBM Script Pack"

         }
}


# Unzip CTBM Script Package #

If ($UpdateCTBMPackage -eq $true){


   ### Extract Script Pack to Updater Script Execution Path
   $ExtractScriptPack = Unzip $localScriptPack $PSScriptRoot


}

