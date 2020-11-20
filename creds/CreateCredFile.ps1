$accountname = read-host "What is your account name?"
Write-host "Password: " -nonewline
read-host -assecurestring | convertfrom-securestring | out-file C:\github-virt-scripts\VMwareScripts\creds\$accountname.cred
Write-Host "Complete" -ForegroundColor Darkgray