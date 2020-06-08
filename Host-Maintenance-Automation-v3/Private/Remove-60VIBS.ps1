<#
.SYNOPSIS
Remove the conflicting VIBs for upgrading hosts to 6.0
.DESCRIPTION
This script is an internal function to remove vibs that conflict during the upgrade.
.NOTES
Author: Anthony Schulte
.PARAMETER HostParam
Passing in the Current Host.
.PARAMETER logs
Passing in the current log file.
.EXAMPLE
Remove-60VIBS -CurrentHost $CurrentHost -logs $log
#>
Function Remove-60VIBS {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $HostParam,
		[Parameter(Mandatory=$false)]
		$logs
    ) 
    
    
    Foreach ($VMHosts in $HostParam)
    {
        try
        {
            # Exposes the ESX CLI functionality of the current host
            $ESXCLI = Get-EsxCli -VMHost $VMhosts.name -V2
            # Retrieve Vib with name 'Cisco'
            $ESXCLI.software.vib.list() | Where-Object { $_.Name -eq "cisco-vem-v198-esx" } |
            ForEach-Object {
                $VIB1 = $_
                $Prop1 = [ordered]@{
                    'VMhost' = $VMhosts.Name
                    'Name' = $VIB1.Name
                    }#$Prop1
            Write-ToLogFile -logPath $logs "$(New-Object PSobject -Property $Prop1)"
            }#FOREACH	
                            
        }#try
        catch
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
			Write-ToLogFile -logPath $logs "Unable to get vib"
            Write-Warning -Message $Error[0].Exception.Message
        }#catch
         try
        {
            # Exposes the ESX CLI functionality of the current host
            $ESXCLI = Get-EsxCli -VMHost $VMhosts.name -V2
            # Retrieve Vib with name 'EMC'
            $ESXCLI.software.vib.list() | Where-Object { $_.Vendor -eq "EMC" } |
            ForEach-Object {
                $VIB2 = $_
                $Prop2 = [ordered]@{
                    'VMhost' = $VMhosts.Name
                    'Name' = $VIB2.Name	
                    'Vendor' = $VIB2.Vendor
                }#$Prop2
            Write-ToLogFile -logPath $logs "$(New-Object PSobject -Property $Prop2)"
            }#FOREACH
        }#try
        catch
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
            Write-ToLogFile -logPath $logs "Error getting VIBs"
			Write-Warning -Message $Error[0].Exception.Message
        }#catch
    }#ForEach

    #Section 2: Removing Vibs
    $vibs = @("cisco-vem-v198-esx","powerpath.cim.esx","powerpath.lib.esx","powerpath.plugin.esx")
    try{
        $VMhosts = Get-VMHost $HostParam -ErrorAction Stop -ErrorVariable ErrorGetVMhost
        Foreach ($Hosts in $VMhosts) {
        Write-ToLogFile -logPath $logs "Working on Host: $Hosts"
        $cliesx = get-esxcli -VMHost $Hosts.name -V2
    
        Foreach ($vib in ($vibs)) {
			
			Write-ToLogFile -logPath $logs "Looking for vib - $vib"
			
			if ($cliesx.software.vib.get.invoke() | where {$_.name -eq "$vib"} -erroraction silentlycontinue )  {
             Write-ToLogFile -logPath $logs "Found vib $vib, Removing from $Hosts"
			 $cliesx.software.vib.remove.invoke($null, $true, $false, $true, "$vib") 
			 
			
            } 
            else {
             
             Write-ToLogFile -logPath $logs "vib $vib not found. Continuing...."
				}
            }
			#Reboot Host after Vib Removal
			
			Write-ToLogFile -logPath $logs "Conflicting VIBs have been remove - Restarting Host"
			Restart-VMHost $Hosts -RunAsync -Confirm:$false
			Start-Sleep -s 480
        }
    }
    catch{
        Write-Warning -Message "Something wrong happened in the script"
		Write-ToLogFile -logPath $logs "Script failed Vib removal"
        IF ($ErrorGetVMhost) { Write-Warning -Message "Couldn't retrieve VMhosts" }
        Write-Warning -Message $Error[0].Exception.Message
        }			
}
    

    
