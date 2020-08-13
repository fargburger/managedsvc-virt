<#
.SYNOPSIS
Control script to run Vester against a vCenter and generate a report. Must have config file already present.

.DESCRIPTION
The purpose of this script is to enable a single step for automation of Vester with report generation.

.EXAMPLE
.\Invoke-EHIVester.ps1 -vCenterParam sit-vc-01.sitcorp.local -OutputPath D:\Vester -ConfigFile D:\Vester\Configs\Config-sit-vc-01.json
#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True)]
    [string]$vCenterParam,
    [Parameter(Mandatory=$False)]
    [switch]$Remediate,
    [Parameter(Mandatory=$False)]
    [switch]$ExportToReports,
    [Parameter(Mandatory=$True)]
    [string]$OutputPath,
    [Parameter(Mandatory=$True)]
    [string]$ConfigFile
)

#----------Setup variables--------#
$ScriptName = "Invoke-EHIVester"
$ReportDate = (Get-Date).ToString("MM-dd-yyyy")
$MyDir = $PSScriptRoot
$vc = $vCenterParam
$config=$configfile.split('\')[-1]
$config1=$config.split('.')[0]
$script:prefix = $config1 -replace 'Config-',''
$VesterCSVOut = "Check-" + $script:prefix + ".csv"
#For current ETC jumpbox each VMware module needed must be explictly imported.
Import-Module VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.vds
Import-Module VMware.VimAutomation.storage
Import-Module VMware.VimAutomation.Common
Disconnect-VIServer * -Confirm:$false

#------- Setup Session to Vcenter -------#
$username = [Environment]::UserName
$domain = (Get-ADDomain -Current LocalComputer).Name 
$duser = "$domain\$username"
$pass = Get-Content D:\Scripts\creds\$username.cred | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist $duser,$pass

Function Invoke-Conversion ()

{    
    Set-Location D:\Scripts\Convert-XMLtoHTML
    .\Convert-XMLtoHTML.ps1 -InputFile $script:InputXML -OutputPath $OutputPath   
    Remove-Item $script:InputXML -recurse
}

Function Start-Vester ()
{
    Import-Module EHI-Vester
    If ($Remediate)
    {
        $script:InputXML = $OutputPath+"\Remediated-" + $script:prefix + "-" + $ReportDate + ".xml"
        Invoke-Vester -XMLOutputFile $script:InputXML -Remediate -Config $ConfigFile
        $script:OutputHTML = $OutputPath+"\Remediated-" + $script:prefix + "-" + $ReportDate + ".html"
    }
    Else
    {
        $script:InputXML = $OutputPath+"\Check-" + $script:prefix + "-" + $ReportDate + ".xml"
        Invoke-Vester -XMLOutputFile $script:InputXML -Config $ConfigFile
        $script:OutputHTML = $OutputPath+"\Check-" + $script:prefix + "-" + $ReportDate + ".html"
        $script:OutputCSV  = $OutputPath+"\Check-" + $script:prefix + "-" + $ReportDate + ".csv"        
    }
    Invoke-Conversion    
}

Function Connect-vCenter ()
{
    $vcenter = $vCenterParam
    $script:vc = $vcenter
    Connect-VIServer $vcenter -cred $mycred -WarningAction 0 -ErrorAction Continue
    Write-Verbose "Connected to $vcenter"        
}
Connect-vCenter
Start-Vester

Disconnect-VIServer $vcenterParam -confirm:$false   | Out-Null 
Set-Location $MyDir
If ($ExportToReports)
{
    Write-Verbose "Create e-id credentials to dump file to VS100 share"
    $ID = "e"
    $username2 = [Environment]::UserName
    $username2 = $username2 -replace '^[aA]',"$ID"
    $domain2 = "na"
    $duser2 = "$domain2\$username2"
    $pass2 = Get-Content ..\creds\$username2.cred | convertto-securestring
    $mycred2 = New-Object -typename System.Management.Automation.PSCredential -argumentlist $duser2,$pass2
    #Export Report to Report directory if specified
    New-PSDrive -Name Y -PSProvider FileSystem -root "\\VS100\Internal_Cloud_Solutions\Reports" -Credential $mycred2
    Write-Host $script:vc -Fore Blue
    If ($script:vc -like "*sit*")
    {
        #Move-Item $script:InputXML Y:\SIT-Vester\
        Move-Item $script:OutputHTML Y:\SIT-Vester\ -Force
        if (!$Remediate){
            Move-Item $script:OutputCSV Y:\SIT-Vester\ -Force
        }
        Remove-PSDrive Y
    }
    Else
    {
        #Move-Item $script:InputXML Y:\Vester\
        Move-Item $script:OutputHTML Y:\Vester\ -Force
        if (!$Remediate){
            Move-Item $script:OutputCSV Y:\Vester\ -Force
        }
        Remove-PSDrive Y
    }

    Function Invoke-Trending ()
    {
        If (!$Remediate){
                if ($vCenterParam -eq "etc-vcrts-01"){
                    $script:prefix -match "^.*(?<=--)(.*(?<=c))"
                    $conf = $Matches[1]
                    Set-Location D:\Scripts\Invoke-VesterTrending
                    .\Invoke-VesterTrending.ps1 -vCenterParam $vCenterParam -ConfigFile $conf
                }
                else {
                    Set-Location D:\Scripts\Invoke-VesterTrending
                    .\Invoke-VesterTrending.ps1 -vCenterParam $vCenterParam   
                }
        }
    }
    Invoke-Trending
}