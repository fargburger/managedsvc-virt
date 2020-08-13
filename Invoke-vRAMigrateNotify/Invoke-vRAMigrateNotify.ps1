<#
.SYNOPSIS
Invoke Notifications of VMs being in a ready state during migration
.DESCRIPTION
The purpose of this script is to notify identified resources during a VCD to vRA migration
.NOTES
Author: Kevin McClure
.PARAMETER InvokerAddress
The email address to be CCed on all email results. Not required.
.PARAMETER BCCAddress
The email address to be BCCed on all email results. Not required
.PARAMETER FromAddress
The from address to be used for all email results
.PARAMETER InputCSV
The path and file of the CSV file being imported from
.EXAMPLE
Invoke-vRAMigrateNotify -InvokerAddress "Kevin.McClure@ehi.com" -FromAddress "vRARocks@ehi.com" -BCCAddress "Laurie.Prozorowski@ehi.com" -InputCSV C:\Test.csv
#>

Param
(
    [Parameter(Mandatory=$True)]
    [string]$InputCSV,
    [string]$FromAddress,
    [Parameter(Mandatory=$False)]
    [string]$InvokerAddress,
    [string]$BCCAddress

)

#Constants for EHI migration
$vCenter = "etc-bvc-02.corp.erac.com"
$global:TargetCluster = "Prod_RES03"

#Setup constant variables
$global:ArrayImport = @() 
$global:DynamicTargetArray = New-Object System.Collections.ArrayList
$global:DynamicSuccessArray = New-Object System.Collections.ArrayList

#EHI email variable constants#
$Global:smtpServer = "smtp.corp.erac.com" #this shouldnt change

#Sets Script File Locations#
$myDir = $PSScriptRoot
Set-Location -Path $MyDir
$Global:outputSuccess = $MyDir + "\output\VraSuccess" + $global:Group + ".csv"
$Global:outputWorking = $MyDir + "\output\VraWorking" + $global:Group + ".csv"

#------- Import Modules necessary for VMware -------#
Import-Module VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Cloud
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -InvalidCertificateAction Ignore -Scope Session -Confirm:$False | Out-Null

#------- Setup Session to Vcenter -------#
$username = [Environment]::UserName
$domain = (Get-ADDomain -Current LocalComputer).Name 
$duser = "$domain\$username"
$pass = Get-Content D:\Scripts\creds\$username.cred | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist $duser,$pass
write-host "Connecting to Vcenter $vcenter" -fore yellow
#Connect to VCenter 
Connect-VIServer $vcenter -cred $mycred -WarningAction 0 -ErrorAction Stop | out-null
Write-host " | Connected" -fore green    -nonewline

    #Get the CSV input and convert to a static array
    Function Get-CSVImport ()
    {
        #Try catch block to validate the input path of the CSV
        try {
            Test-Path -Path $InputCSV -ErrorAction Stop 
            $global:ArrayImport = Import-CSV $InputCSV 
        }
        catch {
            Write-Host "CSV Path is not valid. Please provide a correct CSV input path" -ForegroundColor Red
        }
    #$global:ArrayImport
    
    }#End Functino Get-CSVImport

    #Function to build and send email to tester
    Function Invoke-EmailtoTester ()
    {
        If ($global:Product -ne "")
        {$Table = $global:DynamicSuccessArray | Where-Object {$_.Product -eq $global:Product}}
        Else
        {$Table = $global:DynamicSuccessArray | Where-Object {$_.VMName -eq $global:VMName}}
        #Set Subject for notification
        $Subject = "IPC Refresh Phase $global:phase / Product:$global:Product - Maintenance Complete"
        #Build HTML for email body
        $Header=@"
<style>
body { background-color:#FFFFFF;
font-family:Helvetica;
font-size:11pt; }
td, th { border:1px solid black;
border-collapse:collapse; }
th { color:#262626;
background-color:#99ccff; }
table, tr, td, th { padding: 2px; margin: 0px }
table { width:95%;margin-left:5px; margin-bottom:20px;}
tr:nth-child(odd) {background-color:#b3daff;}
tr:nth-child(even) {background-color:#e6f3ff;}
</style>
<br>
"@        
        
$Pre="<p>The IPC Refresh Maintenance for <strong>Phase $global:phase / Product Name: $global:Product&nbsp;</strong>is now <u>complete</u>.&nbsp; A system reboot has occurred and you can verify that the software on your virtual machine(s) are operating as you expect.</p>
"

$Post="<p>During the maintenance, if issues are encountered please reach out via the Skype session on the meeting invite.</p><p>Following the migration, if issues are encountered, please page&nbsp;the&nbsp;Virtual Engineer on call by sending an email to:&nbsp;#Virtual Infrastructure OnCall &lt;<a href='mailto:#VIOC@ehi.com'>#VIOC@ehi.com</a>&gt;.</p>
<p><strong>Reminder:</strong> &nbsp;<strong>SNAPSHOT BACKUPS&nbsp;</strong>will be suspended for the duration of the maintenance (<strong>Friday, June 16</strong><strong><sup>th</sup></strong><strong>&nbsp;</strong>&ndash;<strong>&nbsp;&nbsp;9am&nbsp;</strong>on<strong>&nbsp;Monday, July 31.</strong><strong><sup>st</sup></strong><strong>)&nbsp; </strong>If you need to create a snapshot on your virtual machine, please submit a &nbsp;<a href='https://ehi.service-now.com/ehi_portal/order_infrastructure.do'><strong>Snapshot Request</strong></a>&nbsp;then go to &lsquo;Cloud Solutions Requests&nbsp;a&nbsp;Virtual Machine Snapshots&rsquo; within RequestIT.&nbsp;&nbsp;</p>
<p>Thank you for your partnership.</p><p>&nbsp;</p><p>IPC Refresh Team</p>"

$Table | Select-Object @{Expression={$_.VMName};Label="VM Name"},@{Expression={$_.Product};Label="Product Name"} | ConvertTo-HTML -Head $Header -PreContent $Pre -PostContent $Post | Out-File $myDir\output\report.html

$EmailBody = Get-Content "$myDir\Output\Report.html" -Raw

    #Set values for email command
    $messageFrom = $FromAddress
    If ($global:ToAddress -match ';')
    {[string[]]$messageTo = $global:ToAddress.Split(';')}
    else
    {$messageTo = $global:ToAddress}
    $messageSubject = $Subject
	$messageCC = @("Laurie.Prozorowski@ehi.com","Joan.Lumpkins@ehi.com",$InvokerAddress)
      
    #------- Create and send email based on conditions of Parameters -------#
    write-host "$global:VMName met all conditions, Sending email to tester $global:ToAddress" -fore Yellow -nonewline
    #Check Conditions for optional flags
    If ($InvokerAddress -and $BCCAddress)
    {
    Send-MailMessage -To $messageTo -From $messageFrom -CC $messageCC -BodyAsHtml $EmailBody -Subject $messageSubject -BCC $BCCAddress -SmtpServer $Global:smtpServer     
    }#End if for both optional conditions
    ElseIf ($InvokerAddress)
    {
    Send-MailMessage -To $messageTo -From $messageFrom -CC $messageCC -BodyAsHtml $EmailBody -Subject $messageSubject -SmtpServer $Global:smtpServer 
    }#End if for only CC
    ElseIf ($BCCAddress)
    {
    Send-MailMessage -To $messageTo -From $messageFrom -BCC $BCCAddress -BodyAsHtml $EmailBody -Subject $messageSubject -SmtpServer $Global:smtpServer     
    }#End if for only BCC
    Else
    {
    Send-MailMessage -To $messageTo -From $messageFrom -BodyAsHtml $EmailBody -Subject $messageSubject -SmtpServer $Global:smtpServer     
    }#Else for no optional flags
}#End 

    #Function to Convert the imported CSV array into a global array with the fields needed for notification
    Function Convert-VMList ()
    {
        $obj = @()
        #Created Empty Array for population of desired fields
        try {
                #Loop through each VMName and pull values that are needed.
                ForEach ($vmt in $global:ArrayImport)
                {
                $obj= ""|Select-Object VMName,ContactEmail,Product,Phase
                $obj.VMName = $vmt.'VM Name'
                $global:phase = $vmt.Phase
                #$obj.Group = $vmt.Group
                $obj.ContactEmail = $vmt.'Contact Email Address'
                $obj.Product = $vmt.Product
                $global:DynamicTargetArray.Add($obj)
                }#End import ForEach
        }
        catch {
            
        }
    
    }#End Convert-VMList Function

    #Function to Test for the 2 conditions, manipulate dynamic arrays, and call actions
    Function Test-VRMCondition ()
    {        
            #Repopulate looparray new for each loop with values in the dynamic array
            $LoopArray = $global:DynamicTargetArray
            #Clear VMsuccess variable each time
            $vmsuccess = $null
            $vmsuccess = @() 
            ForEach ($vrat in $loopArray) 
            {
             $VMName = $vrat.VMName
			 $Exists = get-vm -name $VMName -ErrorAction SilentlyContinue 
			 If ($Exists)
			 {
             $cluster = Get-VM $VMName  | Get-Cluster | Select-Object Name 
             $ToolsStatus =  Get-VM $VMName | Select-Object Name,@{N="ToolsStatus";E={$_.ExtensionData.Guest.ToolsStatus}} 
            
                If ($cluster.name -eq $global:TargetCluster -And ($ToolsStatus.ToolsStatus -eq "toolsOK" -Or $ToolsStatus.ToolsStatus -eq "toolsOld"))
                {
                #Successful desired state. Add to array for processing
                $vmsuccess += $vrat
                }
                Else
                {
                #Nothing needed for unsuccessful condition
                }#End If condition check
			 }#ENd If to check for VM existence	
            }#End ForEach checking all VMs 
            #Loop through the newly created array of successful condition VMs to trigger desired actions
            ForEach ($vms in $vmsuccess)
            {
            $global:VMName = $vms.VMName
            $global:Product = $null
            $global:Product = $vms.Product
            $global:ToAddress = $vms.ContactEmail
            #Add successful VMs to dynamic success array
            $global:DynamicSuccessArray.Add($vms)
            #Remove successful VMs from dynamic initial array
            $global:DynamicTargetArray.Remove($vms) 
            #Check for the presence of an email address and if the VM is the last with that Product name
            If (($global:DynamicTargetArray.Product -contains $vms.Product) -and ($vms.Product -ne ""))
            {
                write-Host "Product $global:Product still contains VMs to be migrated in this group. Notification delayed" -ForegroundColor Cyan
            }
            ElseIf ($vms.ContactEmail -ne $null)
                {
                Write-Host "Email address present "  $vms.ContactEmail  ". Email triggered" -ForegroundColor Cyan
                Invoke-EmailtoTester
                }#End If email check
            }#End ForEach loop for successful VMs
            #Export Working array to CSV for review
            $global:DynamicTargetArray |Export-CSV -Path $Global:outputWorking -NoTypeInformation 
            #Export Success array to CSV for review
            $global:Countleft = $global:DynamicTargetArray.Count 
            $global:DynamicSuccessArray |Export-CSV -Path $Global:outputSuccess -NoTypeInformation  
            Write-Host "`n$global:countleft VMs left for migration" -ForegroundColor Green
            Write-Host "sleeping for 10 seconds" -ForegroundColor Magenta      
            #Sleep for 10 seconds before starting the loop again
            Start-Sleep -Seconds 10
    }#End Function Test-VRMCondition

    #Function to Loop through Dynamic Array until the first entry is empty   
    Function Invoke-TestVRALoop ()
    {
        $count = $global:DynamicTargetArray.Count 
        write-host "Looping through $count VMs to check for conditions" -ForegroundColor Green
        While ($global:DynamicTargetArray.Count -gt "0")
        {
            Test-VRMCondition
        }
       
    }#End Function Invoke-TestVRALoop

#Call Functions in necessary order
Get-CSVImport
Convert-VMList
Invoke-TestVRALoop