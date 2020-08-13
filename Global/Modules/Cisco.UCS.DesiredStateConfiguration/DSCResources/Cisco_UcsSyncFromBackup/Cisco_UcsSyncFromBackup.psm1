﻿# DSC uses the Get-TargetResource function to fetch the status of the resource instance specified in the parameters for the target machine
function Get-TargetResource 
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param 
    (       
        [parameter(Mandatory = $true)]
		[System.String]
		$UcsConnectionString,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$UcsCredentials,

        [System.Management.Automation.PSCredential]
		$WebProxyCredentials,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Absent",
		
		[parameter(Mandatory = $true)]
		[System.String]$Identifier,
      
        [Parameter(Mandatory)]
        [string]$LiteralPath,

        [bool]$Merge
              
    )
       $result = @{     UcsConnectionString = $UcsConnectionString;
		                UcsCredentials = $null;
                        WebProxyCredentials=$null;
                        Ensure=$Ensure;
                        Identifier = $Identifier; 
                        LiteralPath = $LiteralPath;
                        Merge= $Merge;

                  }

        Write-Verbose("Completed execution of Get() method")
        $result;
} 


# The Set-TargetResource function. 
function Set-TargetResource 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
  param 
    (       
        [parameter(Mandatory = $true)]
		[System.String]
		$UcsConnectionString,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$UcsCredentials,

        [System.Management.Automation.PSCredential]
		$WebProxyCredentials,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Absent",
		
		[parameter(Mandatory = $true)]
		[System.String] $Identifier,

        [Parameter(Mandatory)]
        [string]$LiteralPath,

        [bool]$Merge
              
    )

    Write-Verbose("Started execution of Set() method")
    try
    {
        <# #>
        if($Ensure -eq "Present" )
        {
            Write-Verbose("Connection to target UCS...")
            $handle=  Get-UcsConnection -UcsConnectionString $UcsConnectionString -UcsCredentials $UcsCredentials -WebProxyCredentials $WebProxyCredentials

            if($Merge)
            {
                Write-Verbose("Executing cmdlet: Import-UcsBackup -LiteralPath $LiteralPath -Merge")
                Import-UcsBackup -LiteralPath $LiteralPath -Merge -Ucs $handle
            }
            else
            {
                Write-Verbose("Executing cmdlet: Import-UcsBackup -LiteralPath $LiteralPath")
                Import-UcsBackup -LiteralPath $LiteralPath -Ucs $handle
            }



         }
         elseif($Ensure -eq "Absent" )
        {
            Write-Verbose("Ensure ='Absent'. No further processing required.")
        }
    }
    catch
    {
        Write-Verbose("Error occurred in Set-TargetResoucrce. Disconnecting UCS(s)...")
        if($handle -ne $null)
            {$temp = Disconnect-Ucs -Ucs $handle}

        throw
    }     
    Write-Verbose("Completed execution of Set() method")
} 

function Test-TargetResource
{
[CmdletBinding()]
[OutputType([System.Boolean])]
param 
    (       
        [parameter(Mandatory = $true)]
		[System.String]
		$UcsConnectionString,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$UcsCredentials,

        [System.Management.Automation.PSCredential]
		$WebProxyCredentials,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Absent",
		
		[parameter(Mandatory = $true)]
		[System.String] $Identifier,

        [Parameter(Mandatory)]
        [string]$LiteralPath,

        [bool]$Merge
              
    )
       Write-Verbose("Started execution of Test-TargetResource method")

        $result = $false
         
        Write-Verbose("Completed  execution of Test-TargetResource method")

        return $result 
} 

# SIG # Begin signature block
# MIIaRQYJKoZIhvcNAQcCoIIaNjCCGjICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBiQuwdSctlvXp1
# T9xZ7MjwpbI4p6vcOEjnwMMpTidKYaCCFFYwggQVMIIC/aADAgECAgsEAAAAAAEx
# icZQBDANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3Qg
# Q0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
# bjAeFw0xMTA4MDIxMDAwMDBaFw0yOTAzMjkxMDAwMDBaMFsxCzAJBgNVBAYTAkJF
# MRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWdu
# IFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAqpuOw6sRUSUBtpaU4k/YwQj2RiPZRcWVl1urGr/SbFfJ
# MwYfoA/GPH5TSHq/nYeer+7DjEfhQuzj46FKbAwXxKbBuc1b8R5EiY7+C94hWBPu
# TcjFZwscsrPxNHaRossHbTfFoEcmAhWkkJGpeZ7X61edK3wi2BTX8QceeCI2a3d5
# r6/5f45O4bUIMf3q7UtxYowj8QM5j0R5tnYDV56tLwhG3NKMvPSOdM7IaGlRdhGL
# D10kWxlUPSbMQI2CJxtZIH1Z9pOAjvgqOP1roEBlH1d2zFuOBE8sqNuEUBNPxtyL
# ufjdaUyI65x7MCb8eli7WbwUcpKBV7d2ydiACoBuCQIDAQABo4HoMIHlMA4GA1Ud
# DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSSIadKlV1k
# sJu0HuYAN0fmnUErTDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYm
# aHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wNgYDVR0fBC8w
# LTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxzaWduLm5ldC9yb290LXIzLmNybDAf
# BgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove4t0bvDANBgkqhkiG9w0BAQsFAAOC
# AQEABFaCSnzQzsm/NmbRvjWek2yX6AbOMRhZ+WxBX4AuwEIluBjH/NSxN8RooM8o
# agN0S2OXhXdhO9cv4/W9M6KSfREfnops7yyw9GKNNnPRFjbxvF7stICYePzSdnno
# 4SGU4B/EouGqZ9uznHPlQCLPOc7b5neVp7uyy/YZhp2fyNSYBbJxb051rvE9ZGo7
# Xk5GpipdCJLxo/MddL9iDSOMXCo4ldLA1c3PiNofKLW6gWlkKrWmotVzr9xG2wSu
# kdduxZi61EfEVnSAR3hYjL7vK/3sbL/RlPe/UOB74JD9IBh4GCJdCC6MHKCX8x2Z
# faOdkdMGRE4EbnocIOM28LZQuTCCBLkwggOhoAMCAQICEhEhuHOIXTNi+LxkHIES
# SHIkhzANBgkqhkiG9w0BAQsFADBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xv
# YmFsU2lnbiBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcg
# Q0EgLSBTSEEyNTYgLSBHMjAeFw0xNTAyMDMwMDAwMDBaFw0yNjAzMDMwMDAwMDBa
# MGkxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8gR2xvYmFsU2lnbiBQdGUgTHRk
# MTkwNwYDVQQDEzBHbG9iYWxTaWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2RlIGFk
# dmFuY2VkIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZeGGh
# lq4S/6P/J/ZEYHtqVi1n41+fMZIqSO35BYQObU4iVsrYmZeOacqfew8IyCoraNEo
# YSuf5Cbuurj3sOxeahviWLW0vR0J7c3oPdRm/74iIm02Js8ReJfpVQAow+k3Tr0Z
# 5ReESLIcIa3sc9LzqKfpX+g1zoUTpyKbrILp/vFfxBJasfcMQObSoOBNaNDtDAwQ
# HY8FX2RV+bsoRwYM2AY/N8MmNiWMew8niFw4MaUB9l5k3oPAFFzg59JezI3qI4AZ
# KrNiLmDHqmfWs0DuUn9WDO/ZBdeVIF2FFUDPXpGVUZ5GGheRvsHAB3WyS/c2usVU
# bF+KG/sNKGHIifAVAgMBAAGjggFnMIIBYzAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0g
# BEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xv
# YmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNVHSUBAf8EDDAK
# BggrBgEFBQcDCDBGBgNVHR8EPzA9MDugOaA3hjVodHRwOi8vY3JsLmdsb2JhbHNp
# Z24uY29tL2dzL2dzdGltZXN0YW1waW5nc2hhMmcyLmNybDBYBggrBgEFBQcBAQRM
# MEowSAYIKwYBBQUHMAKGPGh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2Fj
# ZXJ0L2dzdGltZXN0YW1waW5nc2hhMmcyLmNydDAdBgNVHQ4EFgQU1Ie4jeblQDyd
# WgZjxkWE2d27HMMwHwYDVR0jBBgwFoAUkiGnSpVdZLCbtB7mADdH5p1BK0wwDQYJ
# KoZIhvcNAQELBQADggEBABl/K/M7RjhgxLilrQytJQPFwJRF7nOrvIEFlpen8IKx
# uBrfuY7NbZstKqpcqlam9tKGX+cKYJqYGENWJGyVSE/axmrdhifaw7Gi63tmRegs
# Mr1+bshk9y7+kBVyOkyrdOH1ePZN48HUO17Ocjqp9CaenBcZ/KgCadH8rGNcx+zf
# r1SwI+gK1fwYRCKNFC0UL+iH7EkN1MiJVl7aEAvtQ7XHpr6vv/Z4DY2ozChbbNHR
# zx3MMIDwt+FDoj0XvB2cejDq1uDM+SMMUTtGczM14lilJ+r7NkUAHuVllRnSj+ll
# ynCGIcWTz4JYte8O1746LK+g8s9/tuBzeOIbclgDNf8wggVuMIIEVqADAgECAhA3
# UxxOtWqWf+F+OQWQoHdjMA0GCSqGSIb3DQEBCwUAMIG0MQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0
# IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52
# ZXJpc2lnbi5jb20vcnBhIChjKTEwMS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAz
# IENvZGUgU2lnbmluZyAyMDEwIENBMB4XDTEzMTExMTAwMDAwMFoXDTE2MTExMDIz
# NTk1OVowgbExCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMREwDwYD
# VQQHEwhTYW4gSm9zZTEcMBoGA1UEChQTQ2lzY28gU3lzdGVtcywgSW5jLjE+MDwG
# A1UECxM1RGlnaXRhbCBJRCBDbGFzcyAzIC0gTWljcm9zb2Z0IFNvZnR3YXJlIFZh
# bGlkYXRpb24gdjIxHDAaBgNVBAMUE0Npc2NvIFN5c3RlbXMsIEluYy4wggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC8mIqh3FnoW7qpmeZpsgSZ1jzPwWQk
# hkG8Hy1nxg+XFbZZUx3xCjDX4jBAHT1qWWJOsWkmXYKxMDX9AKCO0YLT1fpLU0/m
# hDOtcOlN4RbbKlRjFFifuCKaYL/aSK83QEATvtDeboiSUoRSAMAo1HMYKHzb7tDS
# QzhmrG0riTrFPHirWZkKg/6tN0DlMA09/2IUt+uveN47CececBrQfBwdS79UeW0B
# +4FrG3lWktqgiRSfJgLzZxiLec6OXdPDgu00V1wD/g5T3QS9h93fyeVXjPm7cAd6
# pcrk5EEYCqTXZrvIIJaFdv1WzOogAA8546hV5uAOzfCxIkEduYqZKz4PAgMBAAGj
# ggF7MIIBdzAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDBABgNVHR8EOTA3MDWg
# M6Axhi9odHRwOi8vY3NjMy0yMDEwLWNybC52ZXJpc2lnbi5jb20vQ1NDMy0yMDEw
# LmNybDBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcDMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# cQYIKwYBBQUHAQEEZTBjMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2ln
# bi5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly9jc2MzLTIwMTAtYWlhLnZlcmlzaWdu
# LmNvbS9DU0MzLTIwMTAuY2VyMB8GA1UdIwQYMBaAFM+Zqep7JvRLyY6P1/AFJu/j
# 0qedMBEGCWCGSAGG+EIBAQQEAwIEEDAWBgorBgEEAYI3AgEbBAgwBgEBAAEB/zAN
# BgkqhkiG9w0BAQsFAAOCAQEA4I46WvUx4SruyvB9fLxOsAsEd1IbLgmAdutj5yFS
# bVEkKwnmwjZOGEJpPP3Pwoe01su4FTaK0WCgWAZ0OKDuDS8w1Z0O4+B7MeYtX9cI
# mdd49wBbZFjyGHJiH2A94ygxk6k9fvh3B2xvEOfT5z8BSMTdh6pkgDpinXoEikrR
# 5iyBhhLoh227x7rbIz5JVKwN/X4WQERf28n4DWsiqZ7i2RU9ElaPoZdi0HKCgIwf
# ZZnptwzX6BUcIPNGKWpP4MwQEXlwiac98vcGOlpCKy2h7TpRhCWvZ+SVeBEpENff
# /85CCuwpkBG3TKr0r1xjTDlEu82PLIij3hsVFQzCtRswxDCCBgowggTyoAMCAQIC
# EFIA5aolVvwahu2WydRLM8cwDQYJKoZIhvcNAQEFBQAwgcoxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1
# c3QgTmV0d29yazE6MDgGA1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBG
# b3IgYXV0aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3Mg
# MyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MB4X
# DTEwMDIwODAwMDAwMFoXDTIwMDIwNzIzNTk1OVowgbQxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3Qg
# TmV0d29yazE7MDkGA1UECxMyVGVybXMgb2YgdXNlIGF0IGh0dHBzOi8vd3d3LnZl
# cmlzaWduLmNvbS9ycGEgKGMpMTAxLjAsBgNVBAMTJVZlcmlTaWduIENsYXNzIDMg
# Q29kZSBTaWduaW5nIDIwMTAgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQD1I0tepdeKuzLp1Ff37+THJn6tGZj+qJ19lPY2axDXdYEwfwRof8srdR7N
# HQiM32mUpzejnHuA4Jnh7jdNX847FO6G1ND1JzW8JQs4p4xjnRejCKWrsPvNamKC
# TNUh2hvZ8eOEO4oqT4VbkAFPyad2EH8nA3y+rn59wd35BbwbSJxp58CkPDxBAD7f
# luXF5JRx1lUBxwAmSkA8taEmqQynbYCOkCV7z78/HOsvlvrlh3fGtVayejtUMFMb
# 32I0/x7R9FqTKIXlTBdOflv9pJOZf9/N76R17+8V9kfn+Bly2C40Gqa0p0x+vbtP
# DD1X8TDWpjaO1oB21xkupc1+NC2JAgMBAAGjggH+MIIB+jASBgNVHRMBAf8ECDAG
# AQH/AgEAMHAGA1UdIARpMGcwZQYLYIZIAYb4RQEHFwMwVjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL2NwczAqBggrBgEFBQcCAjAeGhxodHRw
# czovL3d3dy52ZXJpc2lnbi5jb20vcnBhMA4GA1UdDwEB/wQEAwIBBjBtBggrBgEF
# BQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9naWYwITAfMAcGBSsOAwIaBBSP5dMa
# hqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8vbG9nby52ZXJpc2lnbi5jb20vdnNs
# b2dvLmdpZjA0BgNVHR8ELTArMCmgJ6AlhiNodHRwOi8vY3JsLnZlcmlzaWduLmNv
# bS9wY2EzLWc1LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLnZlcmlzaWduLmNvbTAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
# AwMwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFZlcmlTaWduTVBLSS0yLTgwHQYD
# VR0OBBYEFM+Zqep7JvRLyY6P1/AFJu/j0qedMB8GA1UdIwQYMBaAFH/TZafC3ey7
# 8DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBBQUAA4IBAQBWIuY0pMRhy0i5Aa1WqGQP
# 2YyRxLvMDOWteqAif99HOEotbNF/cRp87HCpsfBP5A8MU/oVXv50mEkkhYEmHJEU
# R7BMY4y7oTTUxkXoDYUmcwPQqYxkbdxxkuZFBWAVWVE5/FgUa/7UpO15awgMQXLn
# NyIGCb4j6T9Emh7pYZ3MsZBc/D3SjaxCPWU21LQ9QCiPmxDPIybMSyDLkB9djEw0
# yjzY5TfWb6UgvTTrJtmuDefFmvehtCGRM2+G6Fi7JXx0Dlj+dRtjP84xfJuPG5ae
# xVN2hFucrZH6rO2Tul3IIVPCglNjrxINUIcRGz1UUpaKLJw9khoImgUux5OlSJHT
# MYIFRTCCBUECAQEwgckwgbQxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2ln
# biwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE7MDkGA1UE
# CxMyVGVybXMgb2YgdXNlIGF0IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEg
# KGMpMTAxLjAsBgNVBAMTJVZlcmlTaWduIENsYXNzIDMgQ29kZSBTaWduaW5nIDIw
# MTAgQ0ECEDdTHE61apZ/4X45BZCgd2MwDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgXnc7
# lyij20PeSklonWXdIEeOmvkdTeysLTJ4/4l9HvgwDQYJKoZIhvcNAQEBBQAEggEA
# DR4z2Ogc2HJBkyYpDB6K+E9WrY6Y5ySPYrsfXLGKuF+PSFuFMqgIFXIq9V/lQT21
# xpnsLyhHP5ld1vw0v9tkxsn7EOmGqKt8QAgt2XC1vbO4yN1t8UvNC2+XXWBoAeDR
# B1xcHzXIP6omW4TZdlOqEkrBgu2yzu+JtAaLY7eL59hml1JtRVZxnU7vjUacGewU
# 3rsAdFQeRfcHzSqEo4BV4K9dTLYFH0gdKmpXgzVNL0H4g6VnCH9XM26QgIroX5G1
# EqeftFnTkji7Mzh3CbMaddzlFEzrOVqskvMzn2znuT6DUQkBFSLG4xydyaSzRnSM
# 2YJ7RtHaGwAisqDEQ76a+KGCAsUwggLBBgkqhkiG9w0BCQYxggKyMIICrgIBATBx
# MFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYD
# VQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAhIR
# IbhziF0zYvi8ZByBEkhyJIcwDQYJYIZIAWUDBAIBBQCgggESMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDIyMzIxMzI0MlowLwYJ
# KoZIhvcNAQkEMSIEIGUl7m6roOQH4Xr9PQUcEJPHgjYox61tNthRB/ReUCE7MIGm
# BgsqhkiG9w0BCRACDDGBljCBkzCBkDCBjQQU2ei8LBs4rXzjf4FAGaOx8rf5nbEw
# dTBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2IC0g
# RzICEhEhuHOIXTNi+LxkHIESSHIkhzANBgkqhkiG9w0BAQEFAASCAQBUKhkf9Giz
# jtSVejdFqe0goYDrgmN2slWYuf9dLfsgUBqpgYqf8hOeFPwcMn2PK1rqF3k7OKgI
# xVzSOg9GN09WnphHCmTI8NOiCKMwTtiOeniKsN0OeC2kGOCgiyqT3wHXSM9/gvVJ
# C2DPjD2udFsn6Lq/Cq/cwA7xEeosX0IMA3AIDxmKcvv90zIXGIV+JIFS2X0LTljs
# h9P5EfUUnvO948xsvTqfgadMxZI6+k3UxTmaWp7PqM6S8BdX9cnwKnuUdVFMoDqK
# XEzYVl2wWrQIwWwpXs2Nk2hXbwul2GTuH9as7EEuiy8R1dUMuwGwRCkWC80Sg5TF
# Q6SmEM0KcJw4
# SIG # End signature block
