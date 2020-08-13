<#
.SYNOPSIS
Compares Vester CSV outputs for failure trending

.DESCRIPTION
The purpose of this script is to input the last X number of Vester reports and trend against them.  
This will allow us to receive an email report if there are Vester tests that are continually needing to be remediated and determine 
why we continue to have configuration drift for a particular test.

.NOTES
Author: Lance Iverson

.PARAMETER vCenterParam
The vCenter in which you want to run Vester trending against

.PARAMETER ConfigFile
This is used only when running against RTS which has multiple config files

.EXAMPLE
Convert-XMLtoHTML -InputFile D:\VesterOutput\Post.xml -OutputPath D:\VesterOutput\

#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True)]
    [string]$vCenterParam,
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile
)


#----------Setup variables--------#
$ScriptName = "Invoke-VesterTrending"
$ReportDate = (Get-Date).ToString("MM-dd-yyyy")
$MyDir = $PSScriptRoot

#Setup PSDrive to the reports directory on the vs100
$username2 = "e208sk"
$domain2 = "na"
$duser2 = "$domain2\$username2"
$pass2 = Get-Content ..\creds\$username2.cred | convertto-securestring
$mycred2 = New-Object -typename System.Management.Automation.PSCredential -argumentlist $duser2,$pass2
New-PSDrive -Name Y -PSProvider FileSystem -root "\\VS100\Internal_Cloud_Solutions\Reports" -Credential $mycred2

#Setup HTML Style
$Style = @"
<title></title>
<h1></h1>
<style>
body { background-color:#FFFFFF;
font-family:Arial;
font-size:10pt; }
td, th { border:1px solid black;
border-collapse:collapse; }
th { color:black;
background-color:#3498DB; }
table, tr, td, th { padding: 2px; margin: 0px }
table { width:95%;margin-left:5px; margin-bottom:20px;}
.bad {color: Red ; back-ground-color: Red}
.good {color: #92D050 }
.warning {color: #FFFF00 }
.critical {color: #FF0000 }
.notice {color: #A6A6A6 }
.other {color: #000000 }
tr:nth-child(odd) {background-color:#AED6F1;}
tr:nth-child(even) {background-color:white;}
</style>
<br>
"@


#Importing files based on vCenter
If($vCenterParam -like "*sit*")
    {
        Set-Location y:\sit-vester
    }
Else
    {
        Set-Location y:\vester
    }
$ConfigFile
if ($ConfigFile){
    $OldReports = Get-ChildItem | Where-Object {$_.Name -like "Check-$vCenterParam*$ConfigFile*.csv"} | Sort-Object -Property Name -Descending    
}
else {
    $OldReports = Get-ChildItem | Where-Object {$_.Name -like "Check-$vCenterParam*.csv"} | Sort-Object -Property Name -Descending
}
$OldReports
$CurrentWeek = Import-Csv $OldReports[0]
$Failures = $CurrentWeek | Where-Object {$_.Result -eq "Failure"} | Select-Object Name, Type, Test, Category
$script:FailureReport = @()

Function Invoke-Week3
{
    $Week3 = Import-Csv $OldReports[3] | Where-Object {$_.Result -eq "Failure"}
    If ($Failure.Test -in $Week3.Test)
        {
            Write-Host "Week3 Invoked"
            $script:FailureReport += $Failure
        }
    Else
        {
            Write-Host "3 weeks of failures not found"
        }
}


Function Invoke-Week2
{
    Write-Host "Week 2 Invoked"
    $Week2 = Import-Csv $OldReports[2] | Where-Object {$_.Result -eq "Failure"}
    If ($Failure.Test -in $Week2.Test) 
        {
            Write-Host "Invoking Week3"
            Invoke-Week3
        }
    Else
        {
            Write-Host "Has only failed twice"
        }

}


Function Invoke-VesterTrending
{

#Walking through previous CSV files to find failure trends
If ($Failures)
    {
        $Week1 = Import-Csv $OldReports[1] | Where-Object {$_.Result -eq "Failure"}
        Foreach ($Failure in $Failures)
            {
                If ($Failure.Test -in $Week1.Test)
                    {
                        Write-Host "Invoking-Week2"
                        Invoke-Week2
                    }
                Else
                {
                    Write-Host "First time failure"
                }
            }
                
    }
Else
    {
        Write-Host "No Failures"
    }

#Insert report explanation verbiage into email body
If ($script:FailureReport)
    {
$FailureReportHTML = @"
<p>Greetings,</p>
<p>The purpose of this report is to bring awareness to Vester tests that are continually needing to be remediated. The Vester tests that are shown below or in the attached html document, are tests that have failed their checks for three weeks in a row.</p>
<p>Further investigation may be required.</p>
<p>Thanks,</p>
<p>x86 Operational Engineering</p>
"@

        Set-Location D:\Scripts\Invoke-VesterTrending
        $Body1 = $script:FailureReport | ConvertTo-Html -Fragment -PreContent "<h2>Reoccurring Vester Test Failures - $vCenterParam</h2>" | Out-String   
        $FailureReportHTML += ConvertTo-Html -Body $Style -PostContent $Body1 | Out-String
        $FailureReportHTML > .\Output\VesterTrend.html
        Send-MailMessage -Body $FailureReportHTML -BodyAsHtml -Attachments .\Output\VesterTrend.html -To cspe@ehi.com -From ProdMOScripts@ehi.com -SmtpServer smtp.corp.erac.com -Subject "Vester Trending Report"
        Remove-Item .\Output\VesterTrend.html
    }
Set-Location $MyDir
Remove-PSDrive Y
Set-Location ..\Invoke-EHIVester
}

Invoke-VesterTrending

