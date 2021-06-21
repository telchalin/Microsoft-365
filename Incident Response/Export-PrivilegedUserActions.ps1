﻿<##################################################################################################
#
.SYNOPSIS
    1. This script exports several data points from the Azure AD Incident Response PowerShell module
    2. You can set the Output Path using the variable $OutputPath, or just run the script and it will prompt
    3. Specify the primary $DomainName associated with the tenant in order to run the script, or it will prompt
    4. You must have the AzureADIncidentResponse PowerShell module installed in order to use this script, i.e.:

        Install-Module AzureADIncidentResponse


.NOTES
    FileName:    Export-PrivilegedUserActions.ps1
    Author:      Alex Fields 
    Created:     June 2021
	Revised:     June 2021
    
#>
###################################################################################################

Import-Module AzureAD
Import-Module AzureADIncidentResponse

#############################################################
## Gather the parameters and set the working directory
## You may set the parameters in the script or enter by prompt

$DomainName = ""
$OutputPath = ""


## If the DomainName variable is undefined, prompt for input
if ($DomainName -eq "") {
Write-Host
$DomainName = Read-Host 'Enter the primary domain name associated with the tenant'
}


## If the OutputPath variable is undefined, prompt for input
if (!$OutputPath) {
Write-Host
$OutputPath = Read-Host 'Enter the output path, e.g. C:\IROutput'
}

## If the output path does not exist, then create it
$CheckOutputPath = Get-Item $OutputPath
if (!$CheckOutputPath) {
mkdir $OutputPath
}

## Change directory to the OutputPath 
cd $OutputPath

#############################################################
## Connect to Azure AD
$TenantID = Get-AzureADIRTenantId -DomainName $DomainName
Connect-AzureADIR -TenantId $TenantID 

#############################################################

$PrivUsers = Get-AzureADIRPrivilegedRoleAssignment -TenantId $TenantID | Where-Object RoleMemberObjectType -EQ User

foreach ($User in $PrivUsers) {

    $DisplayToID = Get-AzureADIRDisplayNameToObjectId -DisplayName $User.RoleMemberName -ObjectType User

    $RoleMemberEmail = $User.RoleMemberMail

    $AuditDetail = Get-AzureADIRAuditActivity -TenantId $TenantID -InitiatedByUser $DisplayToID.ObjectId

        if (!$AuditDetail) {
        Write-Host
        } else {

        $AuditDetail | Export-Csv $OutputPath\$RoleMemberEmail-ActivityDetail.csv

        }

}

