<#
.SYNOPSIS
Upgrade the Host
.DESCRIPTION
This script is an internal function to upgrade the host.
.NOTES
Author: Anthony Schulte
.PARAMETER CurrentHost
Passing in the Current Host.
.PARAMETER Baselines
Passing in the Baselines.
.EXAMPLE
Update-Hosts -HostParam $CurrentHost -BaselineInfo $baselines
#>
Function Update-Hosts {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $HostParam,
        [Parameter(Mandatory = $True)]
        $BaselineInfo
    )

        Write-ToLogFile -logPath $logfile "Remediating $HostParam"
		Remediate-Inventory -Baseline $BaselineInfo -Entity $HostParam -ClusterDisableHighAvailability:$true -ClusterDisableFaultTolerance:$true -ClusterDisableDistributedPowerManagement:$true -Confirm:$false -erroraction silentlycontinue
        Start-Sleep -Seconds 10
            
}