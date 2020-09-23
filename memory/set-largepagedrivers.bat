:: ADD GAMING-RELATED DRIVERS TO LARGEPAGEDRIVERS LIST IN MEMORY MANAGEMENT
:: https://github.com/wintweaks/windows-optimization

@echo off
setlocal ENABLEDELAYEDEXPANSION

:: CHECK FOR ADMIN PRIVILEGES
dism >nul 2>&1 || (echo This script must be Run as Administrator. && pause && exit /b 1)

:: LIST OF ALL DRIVERS THAT SHOULD BE ADDED TO LARGEPAGEDRIVERS
set WHITELIST=ACPI AcpiDev AcpiPmi AFD AMDPCIDev amdgpio2 amdgpio3 AmdPPM amdpsp amdsata amdsbs amdxata asmtxhci BasicDisplay BasicRender dc1-controll Disk DXGKrnl e1iexpress e1rexpress genericusbfn hwpolicy IntcAzAudAdd kbdclass kbdhid MMCSS monitor mouclass mouhid mountmgr mt7612US MTConfig NDIS nvdimm nvlddmkm pci PktMon Psched rt640x64 RTCore64 RzCommon RzDev_0244 Tcpip usbehci usbhub USBHUB3 USBXHCI Wdf01000 xboxgip xinputhid

:: DUMP DRIVERQUERY OUTPUT TO A TEMPORARY FILE
driverquery > %TEMP%\driverquery.txt 

:: ITERATE THROUGH THE WHITELIST
for %%i in (%WHITELIST%) do (
	:: IF THE WHITELISTED DRIVER IS FOUND IN THE DRIVERQUERY FILE, ADD IT TO DRIVERLIST
	findstr /i /b /r /c:"%%i[ ]" "%TEMP%\driverquery.txt" >nul 2>&1
	if !errorlevel!==0 (
		if "!DRIVERLIST!"=="" (
			set DRIVERLIST=%%i
		) else (
			set DRIVERLIST=!DRIVERLIST!\0%%i
		)
	)
)

:: UPDATE THE REGISTRY
reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v "LargePageDrivers" /t REG_MULTI_SZ /d "%DRIVERLIST%\0" /f

:: CLEANUP
del "%TEMP%\driverquery.txt"

exit /b 0
