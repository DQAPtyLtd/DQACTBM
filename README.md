DQA Custom Teams Background Manager
===========================

A solution designed to centrally deploy client-side Outlook Email Signatures and
update the signature block dynamically from Azure Active Directory attributes.

Solution Files and Purpose
--------------------------

-   **Generate-DQACTBMConfig.ps1** – Generates DQACTBM.config in JSON format used
    in client script package to provide client-side configuration

-   **Create-DQACTBMPackage.ps1** – Generates DQACTBM.zip for client-side script
    deployment

-   **Create-DQACTBMImagesPackage.ps1** – Generates DQACTBMImages.zip for
    client-side custom teams background images

-   **Update-DQACTBM.ps1** – Client-Side PowerShell Script that is packaged into
    DQACTBM.zip that is configured as a scheduled task to manage script and
    configuration updates

-   **Sync-DQACTBMImages.ps1** – Client-Side PowerShell Script that is
    packaged into DQACTBM.zip that is configured as a scheduled task to manage
    updates to the users custom teams background images

-   **run-dqaCTBMupdate.vbs** – VBScript wrapper that executes the
    Update-DQACTBM.ps1 powershell script so that it doesnt popup interactively

-   **run-dqaCTBMimgupdate.vbs** – VBScript wrapper that executes the
    Sync-DQACTBMSignature.ps1 powershell script so that it doesnt popup interactively

-   **Deploy-DQACTBM.ps1** – PowerShell script designed to be deployed via Intune
    that installs the DQA CTBM solution (designed to be in the end-user’s context
    not as system)

-   **DQACTBM.config** – Client-Side master configuration file


-   **DQACTBM.zip** – Script and Configuration Client Deployment Package (Name
    configurable via DQACTBM.config)

    -   Contains: Update-DQACTBM.ps1, Sync-DQACTBMImages.ps1, DQACTBM.config,
        run-dqaCTBMupdate.vbs, run-dqaCTBMimgupdate.vbs

-   **DQACTBM.md5** – file that contains MD5 hash signature for DQACTBM.zip it is
    used to compare with locally cached md5 file on the client computer if
    different the zip file is downloaded and scripts and configuration are
    updated on the client PC

-   **DQACTBMImages.zip** – Custom Teams Background Images Client Deployment
    Package (Name configurable via DQACTBM.config)

-   **DQACTBMImages.md5** – file that contains MD5 hash signature for
    DQACTBMImages.zip it is used to compare with locally cached md5 file on
    the client computer if different the zip file is downloaded and the email
    templates are updated on the client PC

Solution Folders and Purpose
----------------------------

### Solution Side

-   **Root Folder** – Holds all executable scripts and configuration files

-   **/Images** – Location to place images for client packaging

-   **/Packages** – Location that Client Deployment Packages are built into

### Client-Side

-   **Root Folder/Installation Folder –** Defaults to **%appdata%\\DQACTBM also**
    holds all executable scripts and configuration files

-   **/Packages** - Location to place downloaded Email Signature Client
    Deployment Packages

Installation
------------

### Requirements

-   Web Server accessible by end users for hosting of Client Deployment Packages

-   Azure Active Directory

-   Microsoft Intune

-   Windows 10


### Hosting

This solution requires a webserver accessible to your end users to host four (4)
files

-   **DQACTBM.zip** (Configurable) – Scripts and Client-Side Configuration

-   **DQACTBM.md5** – File Hash Signature of DQACTBM.zip used for update
    management

-   **DQACTBMImages.zip** (Configurable) – Outlook Signature Block Templates

-   **DQACTBMImages.md5** – File Hash Signature of DQACTBMSignatures.zip used
    for update management


### Generate solution configuration

1.  Open **Generate-DQACTBMConfig.ps1** in a PowerShell Editor like Visual Studio
    Code

2.  Modify the solution configuration

| Description                                                                                                      | Configuration Item  | Valid Values                                                                                                                                                                                                                                                |
|------------------------------------------------------------------------------------------------------------------|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DQA CTBM Custom Teams Backgrounds Package name                                                                    | CTBMTemplatePackage  | Free Text (Desired name of zip file eg. DQACTBMImages.zip)                                                                                                                                                                                               |
| DQA CTBM Image Prefix                                                                                   | CTBMImagePrefix  | Free Text (Prefix is used to identity images deployed by this tool when you create your custom teams backgrounds ensure your configured prefix matches the what is configured for image name eg. DQACTBM-\<your imagename\> refer to sample content) |
| DQA CTBM Script and Configuration Package name                                                                    | CTBMPackage          | Free Text (Desired name of zip file eg. DQACTBM.zip)                                                                                                                                                                                                         |
| DQA CTBM Script and Configuration Package base url                                                                | CTBMURL              | Free Text (base url of script package file eg. <https://sampleurl.com/CTBM/>)                                                                                                                                                                                |
| DQA CTBM Custom Teams Background Image Package base url **Note:** url does not have to different to CTBM Script Package | CTBMTemplatesURL     | Free Text (base url of template package file eg. <https://sampleurl.com/teamsbackgrounds/>)                                                                                                                                                                       |

3.  Once PowerShell configuration saved execute this script

4.  You will now have **DQACTBM.config** file in the same directory as the
    generate-dqaCTBMconfig.ps1

### Create Custom Teams Background Deployment Packages

1.  Copy your Custom Teams Background Images to the Images folder of this cloned
    solution

2.  Ensure the image names have the defined prefix in the **DQACTBM.config** file eg. **DQACTBM-Image.png**

### Create Deployment Packages

1.  Execute the **Create-DQACTBMPackage.ps1** script

2.  You will now have a **DQACTBM.zip** and **DQACTBM.md5** in the packages folder
    (**Note:** The file names will be based on what is configured in the
    DQACTBM.config file)

3.  Execute the **Create-DQACTBMImagesPackage.ps1** script

4.  You will now have a **DQACTBMImages.zip** and **DQACTBMImages.md5** in
    the packages folder (**Note:** The file names will be based on what is
    configured in the DQACTBM.config file)

5.  Upload the zip and md5 files to the locations specified in the
    **DQACTBM.config** file

### Client Deployment

1.  Open **Deploy-DQACTBM.ps1** in a PowerShell Editor like Visual Studio Code

2.  Modify the solution configuration under CTBM **Configuration** section of this
    script to match the settings configured in the **DQACTBM.config** file

3.  From the Azure Portal use Intune to deploy the **Deploy-DQACTBM.ps1** script
    file

    1.  Under **Intune** from the **Device Configuration** Blade

    2.  Open the **Scripts** Blade

    3.  Click **+ Add**

    4.  Supply a Name eg. Deploy DQQA Email Signature Manager

    5.  Upload/Select the **Deploy-DQACTBM.ps1** from your computer

    6.  Ensure **Run this script using the logged on credentials** is set to
        **yes**

    7.  Assign a deployment group

Updating the Configuration/Script Package
-----------------------------------------

1.  Follow the instructions for **generating solution configuration** and/or
    make any required changes to solution scripts

2.  Follow Steps **1** and **2** and **5** from the **Create Deployment
    Packages** instructions

Updating the Custom Teams Backgrounds Deployment Package
------------------------------------

1.  Follow the instructions for **Create Custom Teams Background Deployment Packages**

2.  Follow Steps **3** and **4** and **5** from the **Create Deployment
    Packages** instructions
