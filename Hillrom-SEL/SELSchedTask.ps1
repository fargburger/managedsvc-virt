cd 'C:\github-virt-scripts\VMwareScripts\Hillrom-SEL'
Import-module .\SEL-Clear.psm1
Invoke-SELCLR -vCenter h-vcpmlab-msn-3.hmstestlab.local -HostImport "C:\github-virt-scripts\VMwareScripts\Hillrom-SEL\inputs\pmlab-test.txt" -toaddress anthsch@cdw.com