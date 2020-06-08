<#
.SYNOPSIS
This script will allow the user to Check the version of ILO Running on a server or group of servers
.DESCRIPTION
This script upgrades hosts from the current version to the latest version. 
.NOTES
Author: Anthony Schulte
.PARAMETER iloCreds
Credential to use for connection.
.PARAMETER HostParam
Host to get patched.
.EXAMPLE
Check-ILO -HostParam $CurrentHost -ilocreds $Credential
#>
Function Update-ILO{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$HostParam,
		[Parameter(Mandatory = $false)]
        $logs,
		[Parameter(Mandatory = $false)]
        $mail,
		[ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $ilocred
		)

		
	Write-ToLogFile -logPath $logfile "I am in the ILO Module" -ForegroundColor Green
    #Starting the SSH service on host
    Start-VMHostService -HostService (Get-VMHost $HostParam | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"}) -Confirm:$false | Out-null
    Write-ToLogFile -logPath $logfile "SSH has been started on the host"
	Write-ToLogFile -logPath $logs "SSH Has been Started."
	
    #iLO Firmware binary path. 
    $v3 = 'http://etc-umds-01.corp.erac.com/5updates/IloBinFiles/ilo3_189.bin'
    $v4 = 'http://etc-umds-01.corp.erac.com/5updates/IloBinFiles/ilo4_255.bin'

    #All the ILOs have an r at the end, adding the r#
	if($HostParam -like "*sitcorp*"){
		$dom = '.sitcorp.local'
		$dom1 = '.corp.erac.com'
		$AddR = $HostParam -replace $dom,'r'
		$server = $AddR+$dom1
	}
	elseif($HostParam -like "*corp*"){
		$dom = '.corp.erac.com'
		$AddR = $HostParam -replace $dom,'r'
		$server = $AddR+$dom
	}
	elseif($HostParam -like "*eu*"){
		$dom = '.eu.erac.com'
		$AddR = $HostParam -replace $dom,'r'
		$server = $AddR+$dom
	}
	else{
	Write-ToLogFile -logPath $logfile "No Domain found in $HostParam"
	Write-ToLogFile -logPath $logs "No Domain found in $HostParam"
	}
	
		
	Write-ToLogFile -logPath $logfile "Checking the ILO for $server" -ForegroundColor Blue
	Write-ToLogFile -logPath $logs "Checking the ILO for $server"
	 
    #Create an SSH Session with the remote server through iLO interface

    #Get the Current Firmware version information using Invoke-Webrequest
    [xml]$XMLOutput = Invoke-WebRequest "http://$server/xmldata?item=All"
    $CurrentVersion = $XMLOutput.RIMP.MP

    #iLO Version confirmation for Version 3
    if($CurrentVersion.PN -match 'iLO 3')
    {
        #Validate whether a firmware upgrade is required. You can change the values as per the new binary availability.
        if($CurrentVersion.FWRI -eq '1.89')
        {
        Write-ToLogFile -logPath $logfile "$server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
        Write-ToLogFile -logPath $logs "$server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI
		$mail.Body +=  "<font color='blue'><br>ILO version Information<br></font>"
		$mail.body += "The ILO Firmware is current at 1.89"
		}
        else
        {
        Write-ToLogFile -logPath $logfile "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
        Write-ToLogFile -logPath $logfile "Initiating the Upgrade Process..." -ForegroundColor Green
		Write-ToLogFile -logPath $logs "$server has old firmware, Initiating Upgrade" $CurrentVersion.PN $CurrentVersion.FWRI
		$mail.Body +=  "<font color='blue'><br>ILO version Information<br></font>"
	    $mail.body += "The ILO Firmware is at 1.88 and has just been upgraded to 1.89"
        #Create an SSH Session to initiate firmware upgrade commands
        $SSHSession = New-SSHSession -ComputerName $server -Credential $ilocred -Verbose -AcceptKey -ConnectionTimeout 600
        $Command = Invoke-SSHCommand -Command "cd /map1/firmware1" -SessionId $SSHSession.SessionId -Verbose -TimeOut 300
        $Command.output
        $Command = $null
        $Command = Invoke-SSHCommand -Command "load -source $v3" -SessionId $SSHSession.SessionId -Verbose -TimeOut 300
        $Command.output
        #Remove the SSH Session
        Remove-SSHSession -SessionId $SSHSession.SessionId
        }

    }

    #iLO Version confirmation for Version 4
    if($CurrentVersion.PN -match 'iLO 4')
    {
        #Validate whether a firmware upgrade is required. You can change the values as per the new binary availability.
        if($CurrentVersion.FWRI -eq '2.55')
        {
        Write-ToLogFile -logPath $logfile "$server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
        $mail.Body +=  "<font color='blue'><br>ILO version Information<br></font>"
	    $mail.body += "The ILO Firmware is current at 2.55"
		}

        else
        {
        Write-ToLogFile -logPath $logfile "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
        Write-ToLogFile -logPath $logfile "Initiating the Upgrade Process..." -ForegroundColor Green
		$mail.Body +=  "<font color='blue'><br>ILO version Information<br></font>"
	    $mail.body += "The ILO Firmware is at 2.50 and has just been upgraded to 2.55"
        #Write-ToLogFile -logPath $logs "$server has old firmware, Initiating Upgrade" $CurrentVersion.PN $CurrentVersion.FWRI
		#Create an SSH Session to initiate firmware upgrade commands
        $SSHSession = New-SSHSession -ComputerName $server -Credential $ilocred -Verbose -AcceptKey -ConnectionTimeout 600
        $Command = Invoke-SSHCommand -Command "cd /map1/firmware1" -SessionId $SSHSession.SessionId -Verbose -TimeOut 300
        $Command.output
        $Command = $null
        $Command = Invoke-SSHCommand -Command "load -source $v4" -SessionId $SSHSession.SessionId -Verbose -TimeOut 300
        $Command.output
        #Remove the SSH Session
        Remove-SSHSession -SessionId $SSHSession.SessionId  
        }
    }

    $SSHSession = $null
    $Command = $null
}

