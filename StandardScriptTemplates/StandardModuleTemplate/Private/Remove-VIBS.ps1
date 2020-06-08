<#
.SYNOPSIS
Remove the conflicting VIBs
.DESCRIPTION
This script is an internal function to remove vibs that conflict during the upgrade.
.NOTES
Author: Anthony Schulte
.PARAMETER CurrentHost
Passing in the Current Host.
.EXAMPLE
Remove-VIBS -CurrentHost $CurrentHost
#>
Function Remove-VIBS {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $HostParam,
		[Parameter(Mandatory=$false)]
		$logs
    ) 
    
    
    Foreach ($VMHosts in $HostParam)
    {
        TRY
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
                            
        }#TRY
        CATCH
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
			Write-ToLogFile -logPath $logs "Unable to get vib"
            Write-Warning -Message $Error[0].Exception.Message
        }#CATCH
        TRY
        {
            # Exposes the ESX CLI functionality of the current host
            $ESXCLI = Get-EsxCli -VMHost $VMhosts.name -V2
            # Retrieve Vib with name 'Emulex'
            $ESXCLI.software.vib.list() | Where-Object { $_.Name -eq "scsi-lpfc820" } |
            ForEach-Object {
                $VIB2 = $_
                $Prop2 = [ordered]@{
                    'VMhost' = $VMhosts.Name
                    'Name' = $VIB2.Name
                    }#$Prop2
            Write-ToLogFile -logPath $logs "$(New-Object PSobject -Property $Prop2)"
            }#FOREACH
        }#TRY
        CATCH
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
            Write-ToLogFile -logPath $logs "Unable to get vib"
			Write-Warning -Message $Error[0].Exception.Message
        }#CATCH
        TRY
        {
            # Exposes the ESX CLI functionality of the current host
            $ESXCLI = Get-EsxCli -VMHost $VMhosts.name -V2
            # Retrieve Vib with name 'Qlogic'
            $ESXCLI.software.vib.list() | Where-Object { $_.Name -eq "scsi-qla2xxx" } |
            ForEach-Object {
                $VIB3 = $_
                $Prop3 = [ordered]@{
                    'VMhost' = $VMhosts.Name
                    'Name' = $VIB3.Name	
                }#$Prop3
            Write-ToLogFile -logPath $logs "$(New-Object PSobject -Property $Prop3)"
            }#FOREACH
        }#TRY
        CATCH
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
            Write-ToLogFile -logPath $logs "Error getting vib"
			Write-Warning -Message $Error[0].Exception.Message
			
        }#CATCH
        TRY
        {
            # Exposes the ESX CLI functionality of the current host
            $ESXCLI = Get-EsxCli -VMHost $VMhosts.name -V2
            # Retrieve Vib with name 'EMC'
            $ESXCLI.software.vib.list() | Where-Object { $_.Vendor -eq "EMC" } |
            ForEach-Object {
                $VIB4 = $_
                $Prop4 = [ordered]@{
                    'VMhost' = $VMhosts.Name
                    'Name' = $VIB4.Name	
                    'Vendor' = $VIB4.Vendor
                }#$Prop3
            Write-ToLogFile -logPath $logs "$(New-Object PSobject -Property $Prop4)"
            }#FOREACH
        }#TRY
        CATCH
        {
            Write-Warning -Message "Something wrong happened with $($VMhosts.name)"
            Write-ToLogFile -logPath $logs "Error getting VIBs"
			Write-Warning -Message $Error[0].Exception.Message
        }#CATCH
    }#ForEach

    #Section 2: Removing Vibs
    $vibs = @("cisco-vem-v198-esx","scsi-lpfc820","scsi-qla2xxx","powerpath.cim.esx","powerpath.lib.esx","powerpath.plugin.esx")
    Try{
        $VMhosts = Get-VMHost $HostParam -ErrorAction Stop -ErrorVariable ErrorGetVMhost
        Foreach ($Hosts in $VMhosts) {
        Write-host "Working on Host: $Hosts"
        $cliesx = get-esxcli -VMHost $Hosts.name -V2
    
        Foreach ($vib in ($vibs)) {
			write-host "      searching for vib $vib" -ForegroundColor Cyan
			Write-ToLogFile -logPath $logs "Looking for vib - $vib"
			
			if ($cliesx.software.vib.get.invoke() | where {$_.name -eq "$vib"} -erroraction silentlycontinue )  {
             write-host "      found vib $vib. Deleting" -ForegroundColor Green
             Write-ToLogFile -logPath $logs "Found vib $vib, Removing from $Hosts"
			 $cliesx.software.vib.remove.invoke($null, $true, $false, $true, "$vib") 
			 
			
            } 
            else {
             write-host "      vib $vib not found. continuing..." -ForegroundColor Yellow
             Write-ToLogFile -logPath $logs "vib $vib not found. Continuing...."
				}
            }
			#Reboot Host after Vib Removal
			write-host "The Conflicting vibs have been removed - Host will restart now" -ForegroundColor Blue
			Write-ToLogFile -logPath $logs "Conflicting VIBs have been remove - Restarting Host"
			Restart-VMHost $Hosts -RunAsync -Confirm:$false
			Start-Sleep -s 480
        }
    }
    CATCH{
        Write-Warning -Message "Something wrong happened in the script"
		Write-ToLogFile -logPath $logs "Script failed Vib removal"
        IF ($ErrorGetVMhost) { Write-Warning -Message "Couldn't retrieve VMhosts" }
        Write-Warning -Message $Error[0].Exception.Message
        }			
}
    

    
