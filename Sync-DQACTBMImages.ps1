<#
.SYNOPSIS

  Synchronises and manages DQA CTBM Image Packs to Local Machine and unpacks them to custom teams background path for the user

.DESCRIPTION

  Downloads DQA CTBM Image Packs and Updates Teams Custom Background Images of current user

  1. Check if MD5 Hash has changed
  2. Bases configuation using DQACTBM.config file
  3. Download Image Pack from WebServer
  4. Unpack Image Pack
  5. Update Teams Custom Backgrounds


.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

  .\Sync-DQACTBMSignature.ps1

#>

###########################
#    CTBM Configuration    #
###########################

#Current Script Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#CTBM Configuration File
$CTBMConfig = "$PSScriptRoot\DQACTBM.config"
$CTBMConfig = Get-Content -Raw -Path $CTBMConfig | ConvertFrom-Json

#Teams Custom Background Path
$ImagePath = "$env:userprofile\AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads"

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

### Template Package Names
$CTBMTemplatePackage = $CTBMConfig.CTBMTemplatePackage.Split(".")
$CTBMTemplatePackageMD5 = $CTBMTemplatePackage[0] + ".md5"
$CTBMTemplatePackage = $CTBMTemplatePackage[0] + ".zip"


### Template Package URLs
$CTBMTemplatePackageMD5URL = $CTBMConfig.CTBMTemplatesURL + "$CTBMTemplatePackageMD5"
$CTBMTemplatePackageURL = $CTBMConfig.CTBMTemplatesURL + "$CTBMTemplatePackage"

#ImagePackPrefix
$ImagePackPrefix = $CTBMConfig.CTBMImagePrefix

#      Version Check      #


### Ensure Template Directory Exists
$templateDestinationFolder = "$PSScriptRoot\Packages"

# Create Program Files Folder
if (-not(test-path $templateDestinationFolder)) {
   try {

       $null = New-Item -type "Directory" -Path $templateDestinationFolder -Force

   }
   catch {
       Write-Output "Failed to create program folder $templateDestinationFolder"
       Exit 911
   }
}

### Check if MD5 exists for CTBM Template Package

$localTemplatePackMD5 = "$templateDestinationFolder\$CTBMTemplatePackageMD5"
$localTemplatePack = "$templateDestinationFolder\$CTBMTemplatePackage"

$CheckMD5 = Test-Path -Path $localTemplatePackMD5

### Clean installation of Template Pack (No previous download)
If ($CheckMD5 -eq $false) {

   Invoke-WebRequest -Method GET -Uri $CTBMTemplatePackageMD5URL -OutFile $localTemplatePackMD5 -UseBasicParsing
   Invoke-WebRequest -Method GET -Uri $CTBMTemplatePackageURL -OutFile $localTemplatePack -UseBasicParsing

   ###Set Flag to let script know to clear previous Custom Teams Background Images from User Profile before unpacking new CTBM Image pack
   $UpdateCTBMTemplate = $true

} else {

   ###Collect and store local Template pack MD5 hash variable
   $localTemplatePackMD5Hash = Get-Content -Raw -Path $localTemplatePackMD5
   ###Collect and store remote Template pack MD5 hash variable
   $remoteTemplatePackMD5Hash = $null
   $remoteTemplatePackMD5Hash = Invoke-WebRequest -Method GET -Uri $CTBMTemplatePackageMD5URL -UseBasicParsing

   ###Compare Hash Values if different overwrite local MD5 and Image Pack ZIP file otherwise do nothing
   $remoteTemplatePackMD5Hash = [string]$remoteTemplatePackMD5Hash
         If ($localTemplatePackMD5Hash -ne $remoteTemplatePackMD5Hash -and $remoteTemplatePackMD5Hash -ne "")
            {
               Write-Output "Downloading Latest CTBM Template Package and MD5 Hash"
               #Download Latest Template Package MD5 and ZIP files
               Invoke-WebRequest -Method GET -Uri $CTBMTemplatePackageMD5URL -OutFile $localTemplatePackMD5 -UseBasicParsing
               Invoke-WebRequest -Method GET -Uri $CTBMTemplatePackageURL -OutFile $localTemplatePack -UseBasicParsing

               #Set Flag to let script know to clear previous Custom Teams Backgrounds from User Profile before unpacking new CTBM Image pack
               $UpdateCTBMTemplate = $true

         } else {

            Write-Output "You have the latest CTBM Image Pack"

         }
}


# Clear Existing CTBM Templates #

If ($UpdateCTBMTemplate -eq $true){

   ### Define CTBM Templates to Delete (ONLY DELETE CTBM Templates)
   $ClearExistingSignaurePath = $ImagePath + "\" + $ImagePackPrefix + "*"

   ### Delete Teams Custom Backgrounds
   Remove-Item -path $ClearExistingSignaurePath -Recurse -force

   ### Extract Template Pack to Outlook Signature Path
   $ExtractTemplatePack = Unzip $localTemplatePack $ImagePath

}