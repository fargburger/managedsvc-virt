Set-Alias Compare-UcsCentralMo Compare-UcsCentralManagedObject
Set-Alias Sync-UcsCentralMo Sync-UcsCentralManagedObject
Set-Alias Get-UcsCentralMo Get-UcsCentralManagedObject
Set-Alias Remove-UcsCentralMo Remove-UcsCentralManagedObject
Set-Alias Add-UcsCentralMo Add-UcsCentralManagedObject
Set-Alias Set-UcsCentralMo Set-UcsCentralManagedObject
Set-Alias Acknowledge-UcsCentralFault Confirm-UcsCentralFault
Set-Alias Get-UcsCentralUcsDomain Get-UcsCentralExtpolClient
Set-Alias Associate-UcsCentralServiceProfile Connect-UcsCentralServiceProfile
Set-Alias Disassociate-UcsCentralServiceProfile Disconnect-UcsCentralServiceProfile
##############################################################################
#.SYNOPSIS
# Remove a Fex
#
#.DESCRIPTION
# Remove a Fex
#
##############################################################################
function FnRemoveUcsCentralFex([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState remove -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState remove -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState remove -Force
	}
	else
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState remove 
	}
}
Set-Alias Remove-UcsCentralFex FnRemoveUcsCentralFex
##############################################################################
#.SYNOPSIS
# Decommission a Fex
#
#.DESCRIPTION
# Decommission a Fex
#
##############################################################################
function FnDecommissionUcsCentralFex([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState decommission -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState decommission -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState decommission -Force
	}
	else
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState decommission 
	}
}
Set-Alias Decommission-UcsCentralFex FnDecommissionUcsCentralFex
##############################################################################
#.SYNOPSIS
# Recommission a Fex
#
#.DESCRIPTION
# Recommission a Fex
#
##############################################################################
function FnRecommissionUcsCentralFex([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Force
	}
	else
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled 
	}
}
Set-Alias Recommission-UcsCentralFex FnRecommissionUcsCentralFex
##############################################################################
#.SYNOPSIS
# Acknowledge a Fex
#
#.DESCRIPTION
# Acknowledge a Fex
#
##############################################################################
function FnAcknowledgeUcsCentralFex([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState re-acknowledge -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState re-acknowledge -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState re-acknowledge -Force
	}
	else
	{
		$input | Set-UcsCentralEquipmentFexOperation -AdminState re-acknowledge 
	}
}
Set-Alias Acknowledge-UcsCentralFex FnAcknowledgeUcsCentralFex
##############################################################################
#.SYNOPSIS
# Decommission a ServerUnit
#
#.DESCRIPTION
# Decommission a ServerUnit
#
##############################################################################
function FnDecommissionUcsCentralServerUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission 
	}
}
Set-Alias Decommission-UcsCentralServerUnit FnDecommissionUcsCentralServerUnit
##############################################################################
#.SYNOPSIS
# Recommission a ServerUnit
#
#.DESCRIPTION
# Recommission a ServerUnit
#
##############################################################################
function FnRecommissionUcsCentralServerUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Force
	}
	else
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled 
	}
}
Set-Alias Recommission-UcsCentralServerUnit FnRecommissionUcsCentralServerUnit
##############################################################################
#.SYNOPSIS
# Acknowledge a ServerUnit
#
#.DESCRIPTION
# Acknowledge a ServerUnit
#
##############################################################################
function FnAcknowledgeUcsCentralServerUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover 
	}
}
Set-Alias Acknowledge-UcsCentralServerUnit FnAcknowledgeUcsCentralServerUnit
##############################################################################
#.SYNOPSIS
# Remove a ServerUnit
#
#.DESCRIPTION
# Remove a ServerUnit
#
##############################################################################
function FnRemoveUcsCentralCartridge([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputeCartridgeOperation -Lc remove -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputeCartridgeOperation -Lc remove -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputeCartridgeOperation -Lc remove -Force
	}
	else
	{
		$input | Set-UcsCentralComputeCartridgeOperation -Lc remove 
	}
}
Set-Alias Remove-UcsCentralCartridge FnRemoveUcsCentralCartridge
##############################################################################
#.SYNOPSIS
# Decommission a Chassis
#
#.DESCRIPTION
# Decommission a Chassis
#
##############################################################################
function FnDecommissionUcsCentralChassis([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState decommission -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState decommission -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState decommission -Force
	}
	else
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState decommission 
	}
}
Set-Alias Decommission-UcsCentralChassis FnDecommissionUcsCentralChassis
##############################################################################
#.SYNOPSIS
# Recommission a Chassis
#
#.DESCRIPTION
# Recommission a Chassis
#
##############################################################################
function FnRecommissionUcsCentralChassis([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled -Force
	}
	else
	{
		$input | Set-UcsCentralFabricSwChPhEpOperation -AdminState enabled 
	}
}
Set-Alias Recommission-UcsCentralChassis FnRecommissionUcsCentralChassis
##############################################################################
#.SYNOPSIS
# Acknowledge a Chassis
#
#.DESCRIPTION
# Acknowledge a Chassis
#
##############################################################################
function FnAcknowledgeUcsCentralChassis([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState re-acknowledge -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState re-acknowledge -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState re-acknowledge -Force
	}
	else
	{
		$input | Set-UcsCentralEquipmentChassisOperation -AdminState re-acknowledge 
	}
}
Set-Alias Acknowledge-UcsCentralChassis FnAcknowledgeUcsCentralChassis
##############################################################################
#.SYNOPSIS
# Remove a RackUnit
#
#.DESCRIPTION
# Remove a RackUnit
#
##############################################################################
function FnRemoveUcsCentralRackUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove 
	}
}
Set-Alias Remove-UcsCentralRackUnit FnRemoveUcsCentralRackUnit
##############################################################################
#.SYNOPSIS
# Decommission a RackUnit
#
#.DESCRIPTION
# Decommission a RackUnit
#
##############################################################################
function FnDecommissionUcsCentralRackUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission 
	}
}
Set-Alias Decommission-UcsCentralRackUnit FnDecommissionUcsCentralRackUnit
##############################################################################
#.SYNOPSIS
# Recommission a RackUnit
#
#.DESCRIPTION
# Recommission a RackUnit
#
##############################################################################
function FnRecommissionUcsCentralRackUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Force
	}
	else
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled 
	}
}
Set-Alias Recommission-UcsCentralRackUnit FnRecommissionUcsCentralRackUnit
##############################################################################
#.SYNOPSIS
# Acknowledge a RackUnit
#
#.DESCRIPTION
# Acknowledge a RackUnit
#
##############################################################################
function FnAcknowledgeUcsCentralRackUnit([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover 
	}
}
Set-Alias Acknowledge-UcsCentralRackUnit FnAcknowledgeUcsCentralRackUnit
##############################################################################
#.SYNOPSIS
# Decommission a Blade
#
#.DESCRIPTION
# Decommission a Blade
#
##############################################################################
function FnDecommissionUcsCentralBlade([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc decommission 
	}
}
Set-Alias Decommission-UcsCentralBlade FnDecommissionUcsCentralBlade
##############################################################################
#.SYNOPSIS
# Recommission a Blade
#
#.DESCRIPTION
# Recommission a Blade
#
##############################################################################
function FnRecommissionUcsCentralBlade([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled -Force
	}
	else
	{
		$input | Set-UcsCentralFabricComputePhEpOperation -AdminState enabled 
	}
}
Set-Alias Recommission-UcsCentralBlade FnRecommissionUcsCentralBlade
##############################################################################
#.SYNOPSIS
# Acknowledge a Blade
#
#.DESCRIPTION
# Acknowledge a Blade
#
##############################################################################
function FnAcknowledgeUcsCentralBlade([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc rediscover 
	}
}
Set-Alias Acknowledge-UcsCentralBlade FnAcknowledgeUcsCentralBlade
##############################################################################
#.SYNOPSIS
# Remove a Blade
#
#.DESCRIPTION
# Remove a Blade
#
##############################################################################
function FnRemoveUcsCentralBlade([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove -Force
	}
	else
	{
		$input | Set-UcsCentralComputePhysicalOperation -Lc remove 
	}
}
Set-Alias Remove-UcsCentralBlade FnRemoveUcsCentralBlade
##############################################################################
#.SYNOPSIS
# Acknowledge a Slot
#
#.DESCRIPTION
# Acknowledge a Slot
#
##############################################################################
function FnAcknowledgeUcsCentralSlot([switch]$Xml, [switch]$Force)
{
	if($Xml.IsPresent -and $Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputeSlotEpOperation -AdminState reacknowledge -Xml -Force
	}
	elseif($Xml.IsPresent)
	{
		$input | Set-UcsCentralFabricComputeSlotEpOperation -AdminState reacknowledge -Xml
	}
	elseif($Force.IsPresent)
	{
		$input | Set-UcsCentralFabricComputeSlotEpOperation -AdminState reacknowledge -Force
	}
	else
	{
		$input | Set-UcsCentralFabricComputeSlotEpOperation -AdminState reacknowledge 
	}
}
Set-Alias Acknowledge-UcsCentralSlot FnAcknowledgeUcsCentralSlot
Export-ModuleMember -Function * -Alias *

# SIG # Begin signature block
# MIIaRQYJKoZIhvcNAQcCoIIaNjCCGjICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA563WDp5Gy8Uk/
# cUvu2O1nFLkcpTKGh2bPoMi+6YW0kaCCFFYwggQVMIIC/aADAgECAgsEAAAAAAEx
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgE/K4
# yMn0lB1Cjyfl8hPKExfRJPqlGNx0jlR/93gVeWcwDQYJKoZIhvcNAQEBBQAEggEA
# LtwzlZCh1Ts9h3rBgZKbVzkOAc2MmMgXewwu6TTnubtmWDNmgPqUXcOwJELccoUE
# zQ1/euWIO04/CqJDIg7qLgIVEeuUIyjEp5RW9h9phzdfWHDilofAxcHIg0BBJQuV
# rJglQU/LZ6j2ssP23Fg+yzNDYH+hkcakQtAv5H10eUMIbr58u9SYPNWiFgAAs2k+
# S7nW1eHUOLFSKGbxKPVNjSFkeZ09diFERUaNaON8DqEM91TuM8qVlDtmZiF+fEUW
# rjLg9kV406YM8T+clqQM49gNIfSaZeCS3spkVrxEg0nh588jzZ7fNDY+VVpNTmii
# NGTcJ3Y12Prvd61T546hkqGCAsUwggLBBgkqhkiG9w0BCQYxggKyMIICrgIBATBx
# MFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYD
# VQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAhIR
# IbhziF0zYvi8ZByBEkhyJIcwDQYJYIZIAWUDBAIBBQCgggESMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDIyMzIxMzAyMFowLwYJ
# KoZIhvcNAQkEMSIEIFJj99WaAfWr+4TNAwBViO7fnW8lHA4V3Jr9h7dC8dgKMIGm
# BgsqhkiG9w0BCRACDDGBljCBkzCBkDCBjQQU2ei8LBs4rXzjf4FAGaOx8rf5nbEw
# dTBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2IC0g
# RzICEhEhuHOIXTNi+LxkHIESSHIkhzANBgkqhkiG9w0BAQEFAASCAQChFd8bRE3O
# OPYTqW/2VOGck7ff9486D3DjMhc5RVFqK/GpDxEcEUdGZGC9XIq8dwrjyqIJktnm
# Vt3Y33rjqyzY1xr5r/2mDDUIU1QgH1SgJfZjROkahuRk/HbPUjDojJqLxI6SSS+2
# /Yc8a+ZzS5MaweMsSoB+KJEunCOfyIxo2t8Y9s9R7qN96ram9THHGXTbeqIVtQHJ
# c2qKk+IzBF+IcWVtjhpssX29K9GVdj/hPEBK33Z13tP6OROslvKx/iSuebviDiei
# MpypGFUXSJ1lJhoshxEAugrkMiND6OlWE8WANqyBxYLO5835+4PQ/ACm4UGIFs3B
# UdRXIqflsuW5
# SIG # End signature block
