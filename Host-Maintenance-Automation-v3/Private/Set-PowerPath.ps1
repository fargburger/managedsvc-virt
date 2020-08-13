<#
.SYNOPSIS
Set Powerpath License for the host after Upgrade
.DESCRIPTION
This script is an internal function to license the hosts powerpath software.
.NOTES
Author: Anthony Schulte
.PARAMETER HostParam
Passing in the Current Host.
.PARAMETER Credential
Passing in the Credentials.
.EXAMPLE
Set-PowerPath -CurrentHost $CurrentHost 
#>
Function Set-PowerPath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$HostParam,
        [Parameter(Mandatory = $False)]
		$logs,
		[Parameter(Mandatory = $True)]
        $domain,
		[Parameter(Mandatory = $True)]
        $usernames,
        [Parameter(Mandatory = $True)]
        $passwords
    )    
    
	
	Write-ToLogFile -logPath $logs "Beginning to Re-register Power Path on $HostParam with $usernames"
	
    #License PP#
    Invoke-Command -ComputerName etc-plic-01 -ScriptBlock {param($var1,$var2,$var3,$var4) rpowermt display dev=all host=$var1 username=$var2\$var3 password=$var4} -ArgumentList $HostParam, $domain, $usernames, $passwords -erroraction SilentlyContinue
	Write-ToLogFile -logPath $logfile "Power Path has been licensed"
    
	#Check That PP Has Been Licensed#
    Invoke-Command -ComputerName etc-plic-01.corp.erac.com -ScriptBlock {rpowermt version host=$Using:HostParam} -ArgumentList $HostParam -erroraction SilentlyContinue
	Write-ToLogFile -logPath $logfile "Completed Power Path registration"
}