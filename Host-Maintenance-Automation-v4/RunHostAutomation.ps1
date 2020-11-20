cd 'C:\github-virt-scripts\VMwareScripts\Host-Maintenance-Automation-v4'
Import-module Host-Automation.psm1
Invoke-patching -vCenter h-vcpmlab-msn-3.hmstestlab.local -HostImport "C:\github-virt-scripts\VMwareScripts\Host-Maintenance-Automation-v4\inputs\pmlab-test.txt" -toaddress anthsch@cdw.com