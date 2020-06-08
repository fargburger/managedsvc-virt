<#
    .SYNOPSIS
    Perform dead space reclamation and capture that written percentage before and after the reclaim.
    
    .DESCRIPTION
    Create a report on the current LUNs allocated from the VMAX1832 and the current written percentage.  Then one at a time (2 per session), perform a dead space reclaim. Once that is complete, wait for 6 hours for the backend to complete
    the reclaim and run the report again. It will gather the new percent written and then calculate any differences.

    .PARAMETER vhost
    This parameter will determine which host the dead space reclamation will run from.
    
    .EXAMPLE
    Invoke-UnmapDeadSpace.ps1 -ToAddress bonnie.j.kossmann@ehi.com -vhost sitesxres051.sitcorp.local

    .NOTES
    Author:    Bonnie Kossmann
    Version:   1.0
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[string]$vhost,
[Parameter(Mandatory=$true)]
[string]$ToAddress 
)
Write-Verbose "Connecting to vCenter: $vhost"

Write-Verbose "Setting up credential items"
$username = [Environment]::UserName
$domain = (Get-ADDomain -Current LocalComputer -Verbose:$false).Name
$duser = "corp\$username"
$pass = Get-Content D:\scripts\creds\$username.cred | ConvertTo-SecureString
$mycred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $duser,$pass

# Creating a Remote Session with etc-vb2uni-01 in order to run SYMCLI commands. SYMCLI only resides on an array management server.
Write-Verbose "Creating PSSession with etc-vb2uni-01 to run initial SYMCLI commands."
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "etc-vb2uni-01.corp.erac.com" -Force
$session = New-PSSession etc-vb2uni-01.corp.erac.com -Credential $mycred


# Once the session was opened, the commands must be ran from the SYMCLI installed directory.
Write-Verbose "Changing to the appropriate directory to run SYMCLI commands."
Invoke-Command -Session $session -ScriptBlock { cd 'C:\Program Files\EMC\SYMCLI\bin' }

# When parsing out the output for all of the luns, it is easiest to only report on the luns that will have dead space reclamation which are the standard sized 6TB luns. Selecting only those devices.
Write-Verbose "Listing all LUNs that are allocated to the hosts that are 6TB in size."
$pattern = '50331660'
$luns = Invoke-Command -Session $session -ScriptBlock { symcfg.exe -sid 1832 list -tdev } | Select-String $pattern 

# Building the initial report that will contain all 6TB LUNS, and their current % written. This will create a custom array to hold the first column and the sixth column which equals the LunID and the PercentWritten. 
Write-Verbose "Gathering the initial report for the % written on the luns prior to the dead space running."
$report = foreach ($lun in $luns){
    $a = ($lun -split "\s+")[0]
    $b = ($lun -split "\s+")[5]
    [PSCustomObject]@{
    LunID = $a+ "`t" 
    Percent = $b 
    }
} 

# Exporting the initial report out to outfile. This is at the start of the dead space reclamation.
Write-Verbose "Exporting the first CSV to D:\Scripts\Invoke-UnmapDeadSpace\outputs\LunReport.csv" 
$report | Export-Csv -path "D:\Scripts\Invoke-UnmapDeadSpace\outputs\LunReport.csv" -Encoding ASCII -NoTypeInformation

# Removing the PSSession here so that it does not try to hold on for 6 hours for the next stage of the report to run and update.
Write-Verbose "Cleaning up all PSSessions."
Remove-PSSession -Session $session -Verbose:$false

# Set Path for use later to keep track of luns
Write-Verbose "Setting the filepath for the LUNS."
$filepath = "D:\Scripts\Invoke-UnmapDeadSpace\outputs\LUNS.txt"

# Importing the VMware module for connecting to vCenter and ESXCLI commands.
Write-Verbose "Attempting to import the VMware VimAutomation module."
Import-Module VMware.VimAutomation.Core -Verbose:$false

Write-Verbose "Connecting to $vhost."
Connect-VIServer -server $vhost -Credential $mycred -Verbose:$false

# These operations are long running and will require timeout to be disabled.
Write-Verbose "Setting no timeout for PowerCli in order to execute long running commands."
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds -1 -Confirm:$false

# Test to see if LUNS.txt file exists, and create if it does not.
Write-Verbose "Checking to see if the LUNS.txt file exist and create it if it doesn't."
if(-NOT(Test-Path $filepath)){
        #Grab a list of datastores on the host that start with 'VM' to ensure only getting VMAX devices.
        $datastores = get-datastore -Server $vhost.Name | where{$_.Name -like 'VMAX1832*'} | Select-Object Name 
        $datastores.name | Set-Content $filepath
}

Write-Verbose "LUNS.txt file exists and will take the first two datastores from the list to execute on."
$datastores = Get-Content -Path $filepath | Sort-Object
$count = $datastores.count

Write-Verbose "Gather list of two datastores, if less then 2, then just grab the two and output $null to a file."
if ($datastores.count -gt 2 ){
        $datastores[2..$count] | Out-File $filepath
        $workingset = $datastores[0..1]
} 
else{
        $workingset = $datastores
        $null | Out-File $filepath
}       

Write-Verbose "Starting to loop through the two datastores that are having the dead space reclaimed from."
foreach ($datastore in $workingset){
$esxcli = Get-EsxCli -VMHost $vhost
           $esxcli.storage.vmfs.unmap(200,$datastore,$null)
           "Datastore completed: $datastore" | Out-File -Append D:\Scripts\Invoke-UnmapDeadSpace\outputs\Luns_Completed.txt 
    }
    
# Disconnect from vCenter to clean up any hanging connections.
Write-Verbose "Removing connections to the host."
Disconnect-VIServer -server $vhost -confirm:$false -Verbose:$false

# Putting in a 1 hour sleep. The process to complete the dead space reclamation takes 1-2 hours. Trying to capture the space reclaimed at the end of that process. 
Write-Verbose "Starting 15 minute sleep."
Start-sleep 900

# Once the sleep is complete, reopen a PSSession to etc-vb2uni-01 and cd to the SYMCLI bin to execute SYMCLI commands from.
Write-Verbose "Connecting to etc-vb2uni-01 and opening a remote session to run SYMCLI commands."
$session = New-PSSession etc-vb2uni-01.corp.erac.com -Credential $mycred
Invoke-Command -Session $session -ScriptBlock { cd 'C:\Program Files\EMC\SYMCLI\bin' }

# When parsing out the output for all of the luns, it is easiest to only report on the luns that will have dead space reclamation which are the standard sized 6TB luns. Selecting only those devices.
Write-Verbose "Listing all LUNs that are allocated to the hosts that are 6TB in size."
$pattern = '50331660'
$luns = Invoke-Command -Session $session -ScriptBlock { symcfg.exe -sid 1832 list -tdev } | Select-String $pattern

# Import the initial report created in order to manipulate it.
Write-Verbose "Importing the original report to add to it."
$reporta = Import-Csv -path D:\Scripts\Invoke-UnmapDeadSpace\outputs\LunReport.csv

# Create a new array to gather the NEW written percentage only after the dead space reclaim has completed on the array.
Write-Verbose "Gathering the new report for the % written on the luns after the dead space has completed."
$reportb = foreach ($lun in $luns){
    $c = ($lun -split "\s+")[5]
    [PSCustomObject]@{
    Percent2 = $c
    }
}

# Create a combined report and merge the columns from $reporta, before the dead space was reclaimed, and $reportb, once the dead space reclamation is complete.
Write-Verbose "Creating combined report."
$reportc = 0..($reporta.Count - 1) | Select-Object @{n="LunID";e={$reporta.LunID[$_]}}, @{n="Percent1";e={$reporta.Percent[$_]}}, @{n="Percent2";e={$reportb.Percent2[$_]}} 

# Creating the final report which will create an array with the calculation of the intial percent written minus the new percent written to determine the percent difference.
Write-Verbose "Taking final report and calculating percent change from original % written."
$FinalReport = foreach ($line in $reportc) {
    $calc = ($line.Percent1 - $line.Percent2) 
    [PSCustomObject]@{
    LunID = $line.LunID
    Percent1 = $line.Percent1
    Percent2 = $line.Percent2
    PercentDiff = $calc 
    }
}

# Export the final report to Excel
Write-Verbose "Exporting report."
$FinalReport | ConvertTo-Html | Out-File -FilePath D:\Scripts\Invoke-UnmapDeadSpace\outputs\PercentWritten.html

# Send email with HTML attachment
Write-Verbose "Sending email of report."
Send-MailMessage -To $ToAddress -From "<etc-vb2uni-01@ehi.com>" -SmtpServer smtp.corp.erac.com -Subject "Dead Space Report" -Attachments D:\Scripts\Invoke-UnmapDeadSpace\outputs\PercentWritten.html

# Remove all hanging PSSessions
Write-Verbose "Cleaning up all PSSessions."
Remove-PSSession -Session $session -Verbose:$false