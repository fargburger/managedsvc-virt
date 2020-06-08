<#
    .SYNOPSIS
        Invokes storage vMotion in parallel
    
    .DESCRIPTION
        The purpose of this script is to use Invoke-Parallel to kick off simultaneous storage vMotions.
        A list of VMs can be fed into this script as a .txt file, and the number of storage vMotions
        can be controlled with a Throttle parameter.

    .NOTES
        Author:  Jon Needham
    
    .PARAMETER  VMList
        The file location of a .txt file with a list of VMs.

    .PARAMETER  vCenterParam
        The vCenter against which you would like to run this bulk storage vMotion.

    .PARAMETER  TargetDatastoreCluster
        The target datastore cluster you'd like to send the virtual machines.
	
	.PARAMETER  StorageFormat
        The Storage Format of the VMDKs after migrations.  Options include Thin, Thick, EagerZeroedThick.  (Thick is LazyZero Thick)

    .PARAMETER  Throttle
        The number of concurrent storage vMotions you want to run.

    .EXAMPLE
        Invoke-BulkStoragevMotion -VMList ./inputs/vms.txt -vCenterParam sit-bvc-01 -TargetDatastoreCluster SIT_Mgmt -StorageFormat Thick -Throttle 4
#>

Param
(
    [Parameter(Mandatory=$true)]
    [string]$VMList,
    [Parameter(Mandatory=$true)]
    [string]$vCenterParam,
    [Parameter(Mandatory=$true)]
    [string]$TargetDatastoreCluster,
    [Parameter(Mandatory=$true)]
	[string]$StorageFormat,
    [Parameter(Mandatory=$true)]
    [int]$Throttle
)

#------- Email Variables -------#
$FromAddress = "ProdMOScripts@ehi.com"

#------- Script Setup Variables -------#
$StartTimer = (Get-Date)
$ScriptName = "Invoke-BulkStoragevMotion"
$VMListContents = Get-Content $VMList

#------- Snap-in imports -------#
Import-Module VMware.VimAutomation.Core

#------- Sets Script Run Location -------#
Set-Location -Path D:\Scripts\$ScriptName

#------- Setup Session to Vcenter -------#
$username = [Environment]::UserName
$domain = (Get-ADDomain -Current LocalComputer).Name 
$duser = "$domain\$username"
$pass = Get-Content ..\creds\$username.cred | ConvertTo-SecureString
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $duser,$pass

#------- Add Invoke-Parallel function to script -------#
. .\Invoke-Parallel.ps1

#------- Kick off Invoke-Parallel to bulk storage vMotion -------#
#Try to connect to vCenter
Try
{
    Connect-VIServer $vCenterParam -Credential $mycred
}

Catch
{
    $_
}                

#Create an empty master vmlist array
$VMListArray = @()

# Loop through each vm in the .txt file, create an array of vm, viserver, session, and target ds cluster
#Add that newly created array to a master vmlist array
foreach ($VMListObject in $VMListContents)
{
    $VMListArrayObject = "" | Select Name,VIServer,Session,TargetDatastoreCluster,StorageFormat

    $VMListArrayObject.Name = $VMListObject
    $VMListArrayObject.VIServer = $Global:DefaultViServer.Name
    $VMListArrayObject.Session = $Global:DefaultViServer.SessionId
    $VMListArrayObject.TargetDatastoreCluster = $TargetDatastoreCluster
	$VMListArrayObject.StorageFormat = $StorageFormat

    $VMListArray += $VMListArrayObject
}
      
#------- Create an outer script block to use with Invoke-Parallel -------#  
$OuterScriptBlock = [ScriptBlock]{
    Write-Information -MessageData "Dealing with $($_.Name)" -InformationAction Continue
    #Set input parameter to the same
    $InputParam = $_

    #Create a script block string to call later with scriptblock create
    $ScriptBlockStr = @"
Import-Module -Name `"VMware.VimAutomation.Core`"  -ErrorAction Stop -Debug:`$false -Verbose:`$false

Connect-VIserver -Server $($InputParam.VIServer) -Session $($InputParam.Session)

Try
{
     #Get the VM and move it to the target datastore cluster
     Get-VM -Name $($InputParam.Name) -ErrorAction Stop | Move-VM -Datastore $($InputParam.TargetDatastoreCluster) -DiskStorageFormat $($InputParam.StorageFormat) -ErrorVariable MoveErr -ErrorAction Stop
}

Catch
{
    `$MoveErr
}
"@

    # Create script block above with the parameters that get passed in with Invoke-Parallel
    $ScriptBlock = [ScriptBlock]::Create($ScriptBlockStr)
    
    # Create a temp log
    $TempLog = [System.IO.Path]::GetTempFileName()
    
    # Write location of temp log to the console
    Write-Information -MessageData "TempLog: $TempLog `t $($InputParam.Name)" -InformationAction Continue

    # Start a powershell process and pass in the scriptblock we just created (with the variables replaced)
    Start-Process $PSHOME\powershell.exe -ArgumentList "-ExecutionPolicy Bypass -Noprofile", `
        "-Command & {Invoke-Command -ScriptBlock {Start-Transcript -Path $TempLog; $ScriptBlock; Stop-Transcript} } " -Wait

}

#Kick off invoke-parallel and pass in VMListArray to the outer scriptblock (which then gets passed into the inner scriptblock)
$Output = Invoke-Parallel -ScriptBlock $OuterScriptBlock -InputObject $VMListArray -Throttle $Throttle -Debug:$false -verbose:$false -RunspaceTimeout 200

#------- Output script time to host -------#
$EndTimer = (Get-Date)
Write-Information -MessageData "Elapsed Script Time: $(($EndTimer-$StartTimer).totalseconds) seconds" -InformationAction Continue