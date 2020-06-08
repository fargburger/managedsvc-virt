<#
.SYNOPSIS
This script will allow the user to upgrade an ESXi host or a cluster of hosts with a parallel option
.DESCRIPTION
This script upgrades hosts from the current version to the latest version. 
.NOTES
Author: Anthony Schulte
.PARAMETER Credential
Credential to use for connection.
.PARAMETER vCenter
vCenter Address to connect to.
.PARAMETER HostImport
Path of import hosts from text file.
.EXAMPLE
Invoke-Patching -vCenter vcenter.contoso.com -HostImport "c:\Temp\Hosts.txt"
#>
function Invoke-Patching {
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
        $Credential = Get-Credential
        $user = $Credential.GetNetworkCredential().username
        $pass = $Credential.GetNetworkCredential().password
        $domain = $Credential.GetNetworkCredential().domain
      
			
		#------- Script Setup Variables -------#
		$FromAddress = "PSScripts@cdw.com"
		$smtpServer = "smtp.cdw.com" #this shouldnt change
		$MastervCentercsv = "C:\github-virt-scripts\VMwareScripts\Global\inputs\Servers.csv" #this shouldnt change
		$CurrentScriptFilePath = $script:MyInvocation.MyCommand.Path
		$ScriptCSVFilePath = $CurrentScriptFilePath.Substring(0, $CurrentScriptFilePath.LastIndexOf('.'))
		$CurrentScriptFileName = $script:MyInvocation.MyCommand.Name
		$CurrentScriptFilePathDir = Split-Path $script:MyInvocation.MyCommand.Path
		$CurrentScriptFileName = $CurrentScriptFileName.Substring(0, $CurrentScriptFileName.LastIndexOf('.'))
		$CurrentScriptLastModifiedDateTime = (Get-Item $script:MyInvocation.MyCommand.Path).LastWriteTime
		$mainScriptDir = "$((Get-Item $CurrentScriptFilePathDir).parent.fullname)"
		$mainInputDir = "$mainScriptDir\Global\inputs"
		$StartTimer = (Get-Date)
		$Subject = "$CurrentScriptFileName Patching Script Report"
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
        Connect-vCenter -vCenter $vCenter -usernames $user -passwords $pass -logs $logFile
		Write-ToLogFile -logPath $logfile "Connected to vCenter"
		#Variable for when the alarms need turned off and on
		$alarmMgr = Get-view AlarmManager
		
        # Get today's date
        
        $CurrentDate = Get-Date
        $CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hhmmss')
        Write-ToLogFile -logPath $logfile "You are starting Upgrades at $CurrentDate"
		Write-ToLogFile -logPath $logfile "Starting ESXi Upgrades to 6.5 $CurrentDate"
		
                   
        #Import CSV#
        Write-Verbose -Message 'Importing List of Hosts'    
        try {
            $HostList = get-vmhost (Get-Content $HostImport) -ErrorAction Stop -ErrorVariable ErrorGetVMhost
			Write-ToLogFile -logPath $logfile "The Following servers are being upgraded: $HostList"
            }

        catch {
            Write-Error "Error validating data." 
			Write-ToLogFile -logPath $logfile "Error Validating data"
            }
        }   
        
        Process{
        #Upgrade Each Host in the HostList#
        Try {
            Foreach  ($CurrentHost in $HostList) {

                
                
				Write-ToLogFile -logPath $logfile "Starting $CurrentHost for upgrades"
				
                #Put the Host In Maintenance Mode#
                
                Write-ToLogFile -logPath $logfile "$CurrentHost is being put in Maintenance Mode"
				
				Set-VMHost $CurrentHost -State Maintenance -Evacuate -Confirm:$false | Out-Null
                
				Write-ToLogFile -logPath $logfile "$CurrentHost is now in Maintenance Mode"
				
				#Turn Off Alarms on the host
				$alarmMgr.EnableAlarmActions($Currenthost.Extensiondata.MoRef,$false)
				
				Write-ToLogFile -logPath $logfile "Alarms have been turned off."
				
                               		
                #Get the UpgradeBasline#
                $baselines = Get-Baseline -Entity $CurrentHost -Inherit
                
				Write-ToLogFile -logPath $logfile "The $CurrentHost will be upgraded with $baselines."
				
							
                #Checking Host Compliance for Upgrade
                $ComplianceStatus = Get-Compliance -Entity $CurrentHost
                If ($ComplianceStatus.Status -eq 'NotCompliant') {
                    
					Write-ToLogFile -logPath $logfile "$CurrentHost is Not in Compliance."
                    #Scan The Esxi Host#
                    
                    Write-ToLogFile -logPath $logfile "Scanning for patches $CurrentHost."
					
					Scan-Inventory -Entity $CurrentHost -RunAsync -Confirm:$false
					Start-Sleep -Seconds 120
                    
                    #Remediate the Hosts#
                    
                    Write-ToLogFile -logPath $logfile "$CurrentHost is now being remediated."
					Update-Hosts -HostParam $CurrentHost -BaselineInfo $baselines
					
                    }
                ElseIf ($ComplianceStatus.Status -eq 'Unknown') {
					
                    Write-ToLogFile -logPath $logfile "$CurrentHost is Not in Compliance."
					#Scan The Esxi Host#
                    
					Write-ToLogFile -logPath $logfile "Scanning for patches $CurrentHost."
                    Scan-Inventory -Entity $CurrentHost -RunAsync -Confirm:$false
					Start-Sleep -Seconds 120
                    
                    #Remediate the Hosts#
                    
                    Write-ToLogFile -logPath $logfile "$CurrentHost is now being remediated."
					Update-Hosts -HostParam $CurrentHost -BaselineInfo $baselines
				
				}
				Else{
                    Write-ToLogFile -logPath $logfile "$CurrentHost is compliant - $ComplianceStatus."  
                    }
                             
                                    
				#Exit Maintenance Mode
			    Write-ToLogFile -logPath $logfile "$CurrentHost is exiting maintenance mode."
				
				Get-VMHost -Name $Currenthost | Set-VMHost -State Connected
			    
				Write-ToLogFile -logPath $logfile "$CurrentHost has completed exiting maintenance mode."
                
				#Turn On Alarms on the host
				$alarmMgr.EnableAlarmActions($Currenthost.Extensiondata.MoRef,$true)
				Write-ToLogFile -logPath $logfile "Alarms have been turned back on for $CurrentHost."
				
				
                Write-ToLogFile -logPath $logfile "You have completed Upgrades on $CurrentHost."

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
        
		Write-ToLogFile -logPath $logfile "Hosts have all been upgraded, completed time $(Get-Date)."
		
		#$message.Body +=  "<font color='blue'><br>Host version Information<br></font>"
		
		#Get the Final ESXi Host version and Build Number
		#Foreach ($ho in $HostList) {
		 # $hinfo = Get-VMhost -Name $ho | Select-Object Name, Version, Build |
		#  ForEach-Object{
		#  $hinfo1 = $_
		#  $info = [ordered]@{
		#					'HostName' = $hinfo1.Name
		#					'Version' = $hinfo1.Version
		#					'Build' = $hinfo1.Build
		#					}
		#					
		#		$message.Body += New-Object PSobject -Property $info | ConvertTo-HTML
		#		}  
		#	Get-VMhost -Name $ho | Select-Object Name, Version, Build | Out-File -FilePath $hostlog
		#}
		
		
		#$message.Body +=  "<font color='blue'><br>Host Upgrade Activity Log<br></font>"
		#$message.Body +=  (Get-content $logFile)
		
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
		Write-ToLogFile -logPath $logfile "`nSending email to $ToAddress" -fore yellow -nonewline
		$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
		$smtp.Send($message)
		Write-ToLogFile -logPath $logfile " ...Complete" -fore green
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


        
           



