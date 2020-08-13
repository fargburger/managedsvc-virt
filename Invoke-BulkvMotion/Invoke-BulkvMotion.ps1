<#
    .SYNOPSIS
        Kick off vMotion on list of VMs
    .DESCRIPTION
        The purpose of this script is to kick off a vMotion for VMs sent via txt file.
    .NOTES
        Author:  Jon Needham
    .PARAMETER vCenter
        The target vCenter for the operation.
    .PARAMETER TargetHost
        The target ESXi host you would like to move the VMs.
    .PARAMETER VMList
        A VMlist .txt file that has a list of VMs.
    .INPUTS
        This script accepts a .txt file with VM names.
    .EXAMPLE
        Invoke-BulkvMotion -vCenter sit-vc-01 -VMList .\inputs\VMList.txt -TargetHost tstesx020.sitcorp.local
#>

#------- Set parameters -------#
Param
(
[Parameter(Mandatory=$true)]
[string]$vCenter,
[Parameter(Mandatory=$true)]
[string]$TargetHost,
[Parameter(Mandatory=$true)]
[string]$VMList
)

#------- Script Setup Variables -------#
$StartTimer = (Get-Date)
$ScriptName = "Invoke-BulkvMotion"

#------- Snap-in imports -------#
Add-PSSnapin VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Cloud

#------- Sets Script Run Location -------#
Set-Location -Path D:\Scripts\$ScriptName

#------- ConSole Output Header -------#
write-host "`n[MOScript Power!]" -fore Cyan

#------- Setup Session to Vcenter -------#
$username = [Environment]::UserName
$domain = (Get-ADDomain -Current LocalComputer).Name 
$duser = "$domain\$username"
$pass = cat ..\creds\$username.cred | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist $duser,$pass

#------- Connect to vCenter and kick off bulk vMotion -------#
Try {
	Connect-VIServer $vcenter -cred $mycred -WarningAction 0 -ErrorAction Stop | out-null
	Write-host " | Connected" -fore green	-nonewline
		
	#Between the lines is what is run against the vCenter
	#The below commands ingest the VM list passed through, then tell vCenter to vMotion
    #all VMs to the specified ESXi host
	#-----------------------------------------------------------------------------------#   
    #Get content of VMList
    $VMListContent = Get-Content $VMList

    #Loop through each VM, grab the VM, and move it to the target host
    Foreach ($VM in $VMListContent)
    {
        Get-VM -Name $VM | Move-VM -Destination $TargetHost
    }
       
    #-----------------------------------------------------------------------------------#
		
	Write-host " | Processing Complete" -fore Cyan
	
}

Catch {
	Write-host " | Failure" -fore red
}

#------- Output script time to host -------#
$EndTimer = (Get-Date)
Write-host "Elapsed Script Time: $(($EndTimer-$StartTimer).totalseconds) seconds"