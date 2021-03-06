<#
    .SYNOPSIS
        Input Info
    .DESCRIPTION
        Input Info
    .PARAMETER  options
        Input Info
    .PARAMETER  displayProperty
        Input Info
    .PARAMETER  title
        Input Info
    .PARAMETER  mode
        Input Info
    .PARAMETER  selectionMode
        Input Info
    .EXAMPLE
        Select-ItemFromList -options (Get-Process) -displayProperty ProcessName -mode ListBox -selectMultiple
    .OUTPUTS
        Input Info
#>
Function Pause {
Read-Host "Press Enter to continue..." | Out-Null
}
Function SendEmailAction {
param($message)
Send-MailMessage -From "automation@ehi.com" -To "nathan.storm@ehi.com" -Subject "HostDRSDetect Script Failure" -Body "$message"
}
Function writelog {
	param($message)
    $message = "[$myVmname] - $message" 
	#LogEvent -LocalLogFileName $LocalLogFileName -LocalLogFile $false -WebService $true -WindowsEventViewer $false -logname $LogName -logsource $logsource -MessageType "Notification" -Message $message -ScriptFilePath $CurrentScriptFilePath -ScriptFileLastModified $CurrentScriptLastModifiedDateTime -UrlType "Internal" -AppName $AppName -AppKey $AppKey -ApiKey $ApiKey
}
Function WriteLogYellow {
	param($message)
	Write-host "$message" -fore yellow
	Add-Content $logpath "$message"
}
Function WriteLogDarkGray {
	param($message)
	Write-host "$message" -fore darkgray
	Add-Content $logpath "$message"
}
Function WriteLogGreen {
	param($message)
	Write-host "$message" -fore green
	Add-Content $logpath "$message"
}
Function WriteLogRed {
	param($message)
	Write-host "$message" -fore red
	Add-Content $logpath "$message"
}
Function Header {
write-host "`n[MOScript Power!]" -fore Cyan
Write-host "Script Path: $CurrentScriptFilePath" -fore darkgray
Write-host "Last Modified: $CurrentScriptLastModifiedDateTime" -fore darkgray
}
Function ConnectToVcenter {
	write-host "Connecting to Vcenter $vcenter" -fore yellow -nonewline
	Try {
		Connect-VIServer $vcenter -cred $mycred -WarningAction 0 -ErrorAction Stop | out-null
		Write-host " ...Connected" -fore green
	}
	Catch {
		Write-host " ...Failure" -fore red
	}
}
Function ReportHeader {
param($param)
$message.Body = "<TABLE  BORDER='1' style='width:100%'><font size='8'><center><b>-: $param $date :-</b></center></font></table><br>"
}
Function CalcScriptTime {
param($param)
$message.Body += "<font color='gray'><br><br><i>Script Process Time: $(($EndTimer-$StartTimer).totalseconds) seconds</i></font>"
}

