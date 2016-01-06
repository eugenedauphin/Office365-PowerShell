# +----------------------------------------------------------------------------+
# | Author : Eugène Dauphin                                                    |
# | File : StoreCredentials.ps1                                                |
# | Version : 1.1                                                              |
# | Purpose : Store credentials for a tenant                                   |
# |                                                                            |
# | Synopsis:                                                                  |
# | Usage : .\StoreCredentials.ps1 .\FolderNameOfTenant                        |
# +----------------------------------------------------------------------------+
# | Maintenance History                                                        |
# | -------------------                                                        |
# | Name             Date       Version  Description                           |
# | Eugène Dauphin   18-09-2014 1.0      Initial Version                       |
# | Eugène Dauphin   26-08-2015 1.1      Force switch and dir create added     |
# | ---------------------------------------------------------------------------+
# |                                                                            |
# | Disclaimer: All scripts and other PowerShell references on this blog are   |
# | offered "as is" with no warranty.  While these scripts are tested and      |
# | working in my environment, it is recommended that you test these scripts   |
# | in a test environment before using in your production environment.         |
# +----------------------------------------------------------------------------+

<#
.SYNOPSIS
    .
.DESCRIPTION
    Store credentials for a tenant
.PARAMETER Path
    The path to the Folder with the stored credentials.
.PARAMETER Force
    Force overwrite password file.
.EXAMPLE
    .\StoreCredentials.ps1 .\FolderNameOfTenant
.EXAMPLE
    .\StoreCredentials.ps1 .\FolderNameOfTenant -Force
.NOTES
    Author: Eugène Dauphin
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Path,
    [Parameter(Mandatory=$False,Position=2)]
    [switch]$Force
)

$fileNameUser = Join-Path $Path "\storedUser.txt"
$fileNamePass = Join-Path $Path "\storedPassword.txt"

if(-not (Test-Path $Path)){
    Write-Host "Creating new folder $($Path)"
    New-Item -Path $Path -ItemType Directory
}

if(Test-Path $fileNameUser){
	Write-Host "There is already a user file for this client" -Foregroundcolor Yellow
}else{
	Write-Host "Enter the username for the global admin account in Office 365:"
	$secureString = Read-Host
	$secureString | Out-File $fileNameUser
}

if((Test-Path $fileNamePass) -and (-not $Force)){
    Write-Host "There is already a password file for this client" -Foregroundcolor Yellow    
}else{
    Write-Host "Enter the password for the global admin account in Office 365:"
	$secureString = Read-Host -AsSecureString
	$secureString | ConvertFrom-SecureString | Out-File $fileNamePass
}