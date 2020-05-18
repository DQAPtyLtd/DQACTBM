<#
.SYNOPSIS

  Installs the DQA CTBM Program

.DESCRIPTION

  Installs the DQA CTBM Program

  1. Creates "$env:userprofile\AppData\Roaming\DQACTBM" Directory
  2. Downloads DQA CTBM Package from Confgured URL
  3. Unpacks DQA CTBM Package to current user appdata directory
  4. Creates an hourly scheduled tasks running as current user

.NOTES

  Version:        1.0.0.0
  Author:         Jean-Pierre Simonis - Delivery Quality Assurance (DQA)
  Creation Date:  20200518
  Purpose/Change: Initial Release

.EXAMPLE

  .\Deploy-DQACTBM.ps1


#>

###########################
#    CTBM Configuration    #
###########################

#Teams Custom Background Manager Scheduled Task Names
$ScheduledCTBMTaskName = "DQACTBM-Updater"
$ScheduledCTBMTaskDescription = "DQA Custom Teams Background Manager (App & Configuration)"

#Teams Custom Background Manager Scheduled Task Names
$ScheduledCTBMImagesTaskName = "DQACTBM-Images-Updater"
$ScheduledCTBMImagesTaskDescription = "DQA Custom Teams Background Manager (Custom Background Image Management)"

#Scheduler Interval (minutes)
$ScheduledInterval = 60

#Installation Path
$destinationFolder = "$env:userprofile\AppData\Roaming\DQACTBM"

#Download Locations
$DQACTBMPackageName = "DQACTBM"

$DQACTBMPackage = "https://sampleurl.com/CTBM/$DQACTBMPackageName.zip"
$DQACTBMPackageMD5 = "https://sampleurl.com/CTBM/$DQACTBMPackageName.md5"


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


# Create Program Files Folder
if (-not(test-path $destinationFolder)) {
    try {
        $null = New-Item -type "Directory" -Path $destinationFolder -Force
        $null = New-Item -type "Directory" -Path $destinationFolder\Packages -Force

    }
    catch {
        Write-Output "Failed to create program folder $destinationFolder"
        Exit 911
    }
}

# Download DQA CTBM Script Package

   Invoke-WebRequest -Method GET -Uri $DQACTBMPackageMD5 -OutFile "$destinationFolder\$DQACTBMPackageName.md5" -UseBasicParsing
   Invoke-WebRequest -Method GET -Uri $DQACTBMPackage -OutFile "$destinationFolder\$DQACTBMPackageName.zip" -UseBasicParsing

# Unzip DQA CTBM Script Package

try { $ExtractScriptPack = Unzip "$destinationFolder\$DQACTBMPackageName.zip" $destinationFolder }
catch {
    Write-Output "Failed to extract the DQA CTBM Script Pack to $destinationFolder"
    Exit 912
}

# Remove Existing Scheduled Task if Present
$scheduledTask = Get-ScheduledTask -TaskName $ScheduledCTBMTaskName -erroraction silentlycontinue
If ($scheduledTask) {
    try { Unregister-ScheduledTask -taskname $ScheduledCTBMTaskName -confirm:$false }
    catch {
        Write-Output "Failed to remove the existing Scheduled Task named $ScheduledCTBMTaskName."
        Exit 914
    }
}
$scheduledTask = Get-ScheduledTask -TaskName $ScheduledCTBMImagesTaskName -erroraction silentlycontinue
If ($scheduledTask) {
    try { Unregister-ScheduledTask -taskname $ScheduledCTBMImagesTaskName -confirm:$false }
    catch {
        Write-Output "Failed to remove the existing Scheduled Task named $ScheduledCTBMImagesTaskName."
        Exit 914
    }
}

# Register the New Scheduled Tasks
try {
    Write-Output "Installing DQA Teams Custom Background Manager Scheduled Tasks."
    $scriptpath = "$destinationFolder\run-dqaCTBMupdate.vbs"
    $scriptWorkingDir = "$destinationFolder"
    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes $ScheduledInterval) -once -At (Get-Date) -RandomDelay (New-TimeSpan -Minutes 2)
    $action = New-ScheduledTaskAction -Execute 'wscript.exe' -WorkingDirectory $scriptWorkingDir -Argument "//nologo `"$scriptpath`""
    $settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -Hidden -Compatibility Win8
    $null = Register-ScheduledTask -taskname $ScheduledCTBMTaskName -Action $action -Settings $settings -Trigger $trigger -Description $ScheduledCTBMTaskDescription
    $scriptpath = "$destinationFolder\run-dqaCTBMimgupdate.vbs"
    $action = New-ScheduledTaskAction -Execute 'wscript.exe' -WorkingDirectory $scriptWorkingDir -Argument "//nologo `"$scriptpath`""
    $null = Register-ScheduledTask -taskname $ScheduledCTBMImagesTaskName -Action $action -Settings $settings -Trigger $trigger -Description $ScheduledCTBMImagesTaskDescription

}
catch {
    Write-Output "Failed to register the DQA CTBM Scheduled Task."
    Exit 915
}


# Completion
Write-Output "DQA CTBM client installation complete."

# Execute the Scheduled Tasks
Start-ScheduledTask -TaskName $ScheduledCTBMSignatureTaskName


