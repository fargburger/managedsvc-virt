<#
.SYNOPSIS
Enter a synopsis of the module
.DESCRIPTION
Enter a description
.NOTES
Author: Enter Your Name
.PARAMETER Credential
Credential to use for connection.
.PARAMETER vCenter
vCenter Address to connect to.
.PARAMETER HostImport
Path of import hosts from text file, if importing files
.EXAMPLE
Invoke-StandardScript -vCenter vcenter.contoso.com -HostImport "c:\Temp\Hosts.txt"
#>
function Invoke-StandardScript {
    [CmdletBinding()]   
    Param(   
        [Parameter(Mandatory = $True)]
        [string]$vCenter,
        [Parameter(Mandatory = $True)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.txt$' )]
        [string]$HostImport,
		[Parameter(Mandatory=$true)]
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
		$FromAddress = "CDW-MansVirt-Scripts@cdw.com"
		$smtpServer = "smtp.cdw.com" #this shouldnt change
		$MastervCentercsv = "C:\CDW-Scripts\Global\inputs\Servers.csv" #this shouldnt change
		$CurrentScriptFilePath = $script:MyInvocation.MyCommand.Path
		$ScriptCSVFilePath = $CurrentScriptFilePath.Substring(0, $CurrentScriptFilePath.LastIndexOf('.'))
		$CurrentScriptFileName = $script:MyInvocation.MyCommand.Name
		$CurrentScriptFilePathDir = Split-Path $script:MyInvocation.MyCommand.Path
		$CurrentScriptFileName = $CurrentScriptFileName.Substring(0, $CurrentScriptFileName.LastIndexOf('.'))
		$CurrentScriptLastModifiedDateTime = (Get-Item $script:MyInvocation.MyCommand.Path).LastWriteTime
		$mainScriptDir = "$((Get-Item $CurrentScriptFilePathDir).parent.fullname)"
		$mainInputDir = "$mainScriptDir\Global\inputs"
		$StartTimer = (Get-Date)
		$Subject = "$CurrentScriptFileName Upgrade Script Report"
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
		Write-ToLogFile -logPath $logfile "Directory set to: $CurrentScriptFilePathDir" -fore darkgray

		#------- ConSole Output Header -------#
		Write-ToLogFile -logPath $logfile "Script Path: $CurrentScriptFilePath" -fore darkgray
		Write-ToLogFile -logPath $logfile "Last Modified: $CurrentScriptLastModifiedDateTime" -fore darkgray
			
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
		#This is where you put the main part of your Script
		
		#Connect to vCenter example
        #Calling the Connect-vCenter script from the Modules private directory
        #When calling another script pass any variable that it will need

        Connect-vCenter -vCenter $vCenter -usernames $user -passwords $pass -logs $logFile
		Write-ToLogFile -logPath $logfile "Connected to vCenter"
		
        
		
        
        #Example of adding the log to the Email message body
        #This is the header for the log being attached
        $message.Body +=  "<font color='blue'><br>Host Upgrade Activity Log<br></font>"
        #attaching the log file
        $message.Body +=  (Get-content $logFile)
		
		#Disconnect the vCenter		
		Disconnect-vCenter
        
        #Should not need to change this
		#------- Import and Attach CSV to email -------#
		if ($toaddress) {
				#attach the log file
				$attachment1 = "$logfile"
				$attach1 = new-object Net.Mail.Attachment($attachment1)
				$message.Attachments.Add($attach1)
				
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
		Write-ToLogFile -logPath $logfile "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"  -fore darkgray
		$FinishDate = Get-Date
		$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Write-Output 'Script Complete'
    
	}
	
}#End Function#


        
           



