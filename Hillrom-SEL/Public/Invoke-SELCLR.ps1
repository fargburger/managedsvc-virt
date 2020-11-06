<#
.SYNOPSIS
Script to clear the SEL logs of each host in a cluster.
Requires Posh-ssh to be installed from the powershell gallery
Requires Latest PowerCLI to be installed (Module based, not snapin based)
.DESCRIPTION
Clear the SEL logs of each host in a cluster 
.NOTES
Author: Anthony Schulte
.PARAMETER Credential
Credential to use for connection.
.PARAMETER vCenter
vCenter Address to connect to.
.PARAMETER HostImport
Path of import hosts from text file.
.EXAMPLE
Invoke-SELCLR -vCenter vcenter.contoso.com -HostImport "c:\Temp\Hosts.txt" -toaddress anthsch@cdw.com
#>
function Invoke-SELCLR {
    [CmdletBinding()]   
    Param(   
        [Parameter(Mandatory = $True)]
        [string]$vCenter,
        [Parameter(Mandatory = $True)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.txt$' )]
        [string]$HostImport,
		[Parameter(Mandatory=$false)]
		[string]$ToAddress,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )  
    Begin {
        Import-Module -Name VMware.VimAutomation.Core
		
		#$Credential = Get-Credential
        $vcuser = 'administrator@vsphere.local'
        #$pass = $Credential.GetNetworkCredential().password
        #$domain = $Credential.GetNetworkCredential().domain
		
			
		#------- Script Setup Variables -------#
		$FromAddress = "PSScripts@cdw.com"
		$smtpServer = "10.192.46.2" #this changes with the BMN
		#$MastervCentercsv = "C:\github-virt-scripts\VMwareScripts\Global\inputs\Servers.csv" #this shouldnt change
		$CurrentScriptFilePath = $script:MyInvocation.MyCommand.Path
		$ScriptCSVFilePath = $CurrentScriptFilePath.Substring(0, $CurrentScriptFilePath.LastIndexOf('.'))
		$CurrentScriptFileName = $script:MyInvocation.MyCommand.Name
		$CurrentScriptFilePathDir = Split-Path $script:MyInvocation.MyCommand.Path
		$CurrentScriptFileName = $CurrentScriptFileName.Substring(0, $CurrentScriptFileName.LastIndexOf('.'))
		$CurrentScriptLastModifiedDateTime = (Get-Item $script:MyInvocation.MyCommand.Path).LastWriteTime
		$mainScriptDir = "$((Get-Item $CurrentScriptFilePathDir).parent.fullname)"
		$mainInputDir = "$mainScriptDir\Global\inputs"
		$StartTimer = (Get-Date)
		$Subject = "$CurrentScriptFileName Script Report"
		#------- Dot Sources -------#
		. $("$mainInputDir\ArrayToHTML.ps1") #Converts collection to HTML for purpose of emailing
		. $("$mainInputDir\Write-ToLogFile.ps1") #logs to file
		
		
		#Log File
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
		$logFile = "$outputDir\$($CurrentScriptFileName) $(Get-Date -format "yyyy-mm-MM-hh-mm-ss").log"
		$hostlog = "$outputDir\HostsList $(Get-Date -format "yyyy-mm-MM-hh-mm-ss").log"
		#------- Log Header -------#
		Write-ToLogFile -logPath $logFile "#----------- Begin Script -----------#"
		Write-ToLogFile -logPath $logFile " Path: $CurrentScriptFilePath"
		Write-ToLogFile -logPath $logFile " Modified: $CurrentScriptLastModifiedDateTime"
		Write-ToLogFile -logPath $logFile " User: $user" 
		Write-ToLogFile -logPath $logFile " Start: $startTimer"
		Write-ToLogFile -logPath $logFile "#------------------------------------#"
		
		#------- Test Cred file location and load it if found -------#
		if ( $(Try { Test-Path C:\github-virt-scripts\VMwareScripts\Hillrom-SEL\inputs\$vcuser.cred } Catch { $false }) ) {
		Write-ToLogFile -logPath $logfile "Cred file for $vCenter found"
				$vcpass = cat C:\github-virt-scripts\VMwareScripts\Hillrom-SEL\inputs\$vcuser.cred | convertto-securestring
				}
				Else {
				Write-ToLogFile -logPath $logfile "Cred file for $vCenter not found" -fore red
				Send-MailMessage -To $toaddress -From $FromAddress -Subject "Script $CurrentScriptFileName.csv Failed" -Body "Script failed due to: Unable to locate cred file for [ $username ]" -SmtpServer $smtpServer
				Exit
				}
				
				$vccred = new-object -typename System.Management.Automation.PSCredential -argumentlist $vcuser,$vcpass
		
		#------- Sets Script Run Location -------#
		Set-Location -Path $CurrentScriptFilePathDir
		Write-ToLogFile -logPath $logfile "Directory set to: $CurrentScriptFilePathDir" 

		#------- ConSole Output Header -------#
		Write-ToLogFile -logPath $logfile "Script Path: $CurrentScriptFilePath" 
		Write-ToLogFile -logPath $logfile "Last Modified: $CurrentScriptLastModifiedDateTime" 
			
		#------- Build email object -------#
		if ( -Not (Test-Path .\$CurrentScriptFileName.csv)) {
			New-Item .\$CurrentScriptFileName.csv -type file -force | out-null
		}
		Else {
		Remove-Item .\$CurrentScriptFileName.csv -force 
		New-Item .\$CurrentScriptFileName.csv -type file -force | out-null
		}
		$date = get-date
		$date = $date.ToShortDateString()
		if ($toaddress) {
		$message = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress
		$message.Subject = "$Subject"
		$message.IsBodyHTML = $true
		$message.Body = "<font size='6'><center><b>-: $subject - $date :-</b></center></font><hr>" #line to create email header
		}	
		
			
		
		#Begin Main Script
		
		#Connect to vCenter#
        Connect-vCenter -vCenter $vCenter -creden $vccred -logs $logFile
		Write-ToLogFile -logPath $logfile "Connected to vCenter"
				
        # Get today's date
        
        $CurrentDate = Get-Date
        $CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hhmmss')
       		
                   
        #Import CSV#
        Write-Verbose -Message 'Importing List of Hosts'    
        try {
            $HostList = get-vmhost (Get-Content $HostImport) -ErrorAction Stop -ErrorVariable ErrorGetVMhost
			Write-ToLogFile -logPath $logfile "The Following servers have services restarted: $HostList"
            }

        catch {
            Write-Error "Error validating data." 
			Write-ToLogFile -logPath $logfile "Error Validating data"
            }
        }   
        
        Process{
        #Restart SEL for Each host#
        Try {
            Foreach  ($CurrentHost in $HostList) {

                #------- Test Cred file location and load it if found -------#
				$duser = 'root'
				if ( $(Try { Test-Path C:\github-virt-scripts\VMwareScripts\Hillrom-SEL\inputs\$CurrentHost\$duser.cred} Catch { $false }) ) {
				Write-ToLogFile -logPath $logfile "Cred file for $CurrentHost root found"
				$Hostpass = cat C:\github-virt-scripts\VMwareScripts\Hillrom-SEL\inputs\$CurrentHost\$duser.cred | convertto-securestring
				}
				Else {
				Write-ToLogFile -logPath $logfile "Cred file for $CurrentHost root not found" -fore red
				Send-MailMessage -To $toaddress -From $FromAddress -Subject "Script $CurrentScriptFileName.csv Failed" -Body "Script failed due to: Unable to locate cred file for [ $username ]" -SmtpServer $smtpServer
				Exit
				}
				
				$esxilogin = new-object -typename System.Management.Automation.PSCredential -argumentlist $duser,$Hostpass
                
				
				Write-ToLogFile -logPath $logfile "Starting $CurrentHost for SEL Reset"
				
                
                #Add SSH service for host to variable
                $sshService = Get-VmHostService -VMHost $CurrentHost.Name | Where { $_.Key -eq 'TSM-SSH'}
				
				#Start the SSH service for the Host
				Write-ToLogFile -logPath $logfile "Starting $CurrentHost SSH Service"
				Start-VMHostService -HostService $sshService -Confirm:$false
				Write-ToLogFile -logPath $logfile "$CurrentHost SSH Started"
				
				# Connect with ssh and execute the commands
				Write-ToLogFile -logPath $logfile "Logging in via ssh to $CurrentHost"
				New-SSHSession -ComputerName $CurrentHost.Name -AcceptKey -Credential $esxilogin
				Write-ToLogFile -logPath $logfile "Login Successful"
				
				Write-ToLogFile -logPath $logfile "Sending the SSH Commands to $CurrentHost"
				Invoke-SSHCommand -SessionId 0 -Command "localcli hardware ipmi sel clear; nohup /etc/init.d/sfcbd-watchdog restart; nohup /etc/init.d/hostd restart > foo.out 2> foo.err < /dev/null &"
				
				Write-ToLogFile -logPath $logfile "Remote restart Command Completed"
				
				#pause to allow management agents to fire back up
				Start-Sleep -Seconds 75
				Remove-SSHSession -SessionId 0
				
				#Stop the SSH Service for the host
				Stop-VMHostService -HostService $sshService -Confirm:$false
				Write-ToLogFile -logPath $logfile "Stopping $CurrentHost SSH Service"
				
				}#End ForEach
				                        		
                
            #Email Informaton
			if ($toaddress) {
			$message.Body += "<font color='green'><br>Script Section Executed<br></font>"
			}
			Write-ToLogFile -logPath $logfile " - script section executed" 
        }#End Try

        catch {
        		Write-Warning -Message "Something wrong happened in the script on  $($CurrentHost.name)"
				Write-ToLogFile -logPath $logfile "Something wrong happened in the script on  $($CurrentHost.name)"
		        IF ($ErrorGetVMhost) { Write-Warning -Message "Couldn't retrieve VMhosts" }
		        Write-Warning -Message $Error[0].Exception.Message
				Write-ToLogFile -logPath $logfile "Script has failed."
		      }#End Catch
			
					
    }#End Process#
    End{
        
		Write-ToLogFile -logPath $logfile "Hosts have all been reset, completed time $(Get-Date)."
		
				
		$message.Body +=  "<font color='blue'><br>Host Service Restart<br></font>"
		$message.Body +=  (Get-content $logFile)
		
		#Disconnect the vCenter		
		Disconnect-vCenter
    	
		#------- Import and Attach CSV to email -------#
		if ($toaddress) {
				
				$attachment1 = "$hostlog"
				$attachment2 = "$logFile"
				$attach1 = new-object Net.Mail.Attachment($attachment1)
				$attach2 = new-object Net.Mail.Attachment($attachment2)
				$message.Attachments.Add($attach1)
				$message.Attachments.Add($attach2)
			} Else {}
		

		#------- Insert Total Run Time into html email -------#
		$EndTimer = (Get-Date)
		if ($toaddress) {
		$message.Body += "<font color='gray'><br><br><i>Script Process Time: $(($EndTimer-$StartTimer).totalseconds) seconds</i></font>"
		}

		#------- Create and send -------#
		if ($toaddress) {
		Write-ToLogFile -logPath $logfile "`nSending email to $ToAddress" -nonewline
		$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
		$smtp.Send($message)
		Write-ToLogFile -logPath $logfile " ...Complete" 
		}

		#------- Delete CSV -------#
		if ($attachfile){
		$attach.Dispose()
		Remove-Item $attachment -recurse
		} Else {}
		if (Test-Path .\$CurrentScriptFileName.csv) {Remove-Item .\$CurrentScriptFileName.csv -force}

		#------- Output script time to host -------#
		Write-ToLogFile -logPath $logfile "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"  
		#$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Write-Output 'Script Complete'
    
	}
	
}#End Function#


        
           



