# +----------------------------------------------------------------------------+
# | Author  : Eugène Dauphin                                                   |
# | File    : Connect.ps1                                                      |
# | Version : 1.1                                                              |
# | Purpose : Connect to an Office 365 Tenant                                  |
# |                                                                            |
# | Synopsis:                                                                  |
# | Usage : .\Connect.ps1 .\FolderNameOfTenant                                 |
# +----------------------------------------------------------------------------+
# | Maintenance History                                                        |
# | -------------------                                                        |
# | Name             Date       Version  Description                           |
# | Eugène Dauphin   18-09-2014 1.0      Initial Version                       |
# | Eugène Dauphin   07-10-2015 1.1      Added PnP PowerShell Cmdlets          |
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
    Connect to an Office 365 Tenant
.PARAMETER Path
    The path to the Folder with the stored credentials.
.EXAMPLE
    .\Connect.ps1 .\FolderNameOfTenant    
.NOTES
    Author: Eugène Dauphin
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$Path
)

$user = Join-Path $Path "\storedUser.txt"
$pass = Join-Path $Path "\storedPassword.txt"

Import-Module MSOnline

#Get Credentials
$powerUser = Get-Content -Path $user
$Password = Get-Content -Path $pass | ConvertTo-SecureString
$O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $powerUser,$Password

#Connect to Exchange Online
Write-Host "Connect-MsolService"
Connect-MsolService -Credential $O365Cred
Write-Host "Session"
$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Cred -Authentication Basic -AllowRedirection
Write-Host "Import-PSSession"
Import-PSSession $O365Session -AllowClobber

#Connect to SharePoint Online
#Make sure you have SharePoint Online Management Shell installed
#http://go.microsoft.com/fwlink/p/?LinkId=255251 
$domains = Get-MsolDomain | Where-Object {$_.Name.EndsWith("onmicrosoft.com")} | Select Name
$firstDomainPart = $domains[0].Name.Split('.')[0]
$adminDomain = "https://"+$firstDomainPart+"-admin.sharepoint.com"
Connect-SPOService -Url $adminDomain -Credential $O365Cred
#Add PnP PowerShell Cmdlets
$spoDomain = "https://"+$firstDomainPart+".sharepoint.com"
Connect-SPOnline -Url $spoDomain -Credentials $O365Cred

#Get Tenant Information
$domain = Get-MsolDomain | Where-Object {$_.IsDefault -eq "True"} | Select Name
$company = Get-MsolCompanyInformation | Select DisplayName
$windowTitle = $company.DisplayName + " Office 365 PowerShell"
$Host.UI.RawUI.WindowTitle = $windowTitle 
Write-Host
Write-Host "Connected to Office 365 tenant" $company.DisplayName -ForeGroundColor Green
Write-Host "Default domain is" $domain.Name -ForeGroundColor Green
Write-Host