::----------------------------------------------------------
::     HidroSaphire Script - ASUS RGB Light Changer
::----------------------------------------------------------
@echo off

::----SET VARIABLES-----------------------------------------
	SET version=v1.1
	SET NameFolder="Hidro ASUS Light Changer2"
	SET ProfilePath=%AppData%\%NameFolder%
	SET arg1=%~1
	SET verboseMode=0

::----TITLE OF WINDOWS--------------------------------------
	TITLE HidroSaphrie - ASUS RGB Light Changer %version%

	ECHO [36m
	ECHO                        *********************************************
	ECHO                       *    HidroSaphire - ASUS RGB Light Changer    *
	ECHO                      *************************************************
	ECHO [0m
	ECHO [36mVersion %version%
	ECHO [0m
	REM Check if Admin
	NET session >nul 2>&1
 		IF %errorLevel% == 0 (
			REM null
		) else (
			ECHO [33m[ATTENZIONE][0m - Non hai Privilegi di Amministratore
			ECHO Lo script non riuscira' a riavviare il servizio Lighting Service
			ECHO [0m
   		)
	REM Check if launched in Verbose Mode
	IF "%arg1%" EQU "-v" (
		GOTO :ImpossibleSetVariableInsideIf
	) ELSE (
		GOTO :InitialPoint
	)

:ImpossibleSetVariableInsideIf
	SET /a verboseMode=1
	ECHO [31m- [Activated Verbose Mode] -[0m
	ECHO [0m





::----STARTING POINT----------------------------------------
:InitialPoint
	IF NOT EXIST %ProfilePath% MKDIR %ProfilePath%
	dir /b /s /a %ProfilePath% | findstr .>nul || (
		ECHO Nessun profilo RGB disponibile
		ECHO [0m
		GOTO :FirstProfileChoice
	)

ECHO Elenco Profili RGB disponibili
SetLocal EnableDelayedexpansion
::----Search for files and populate array-------------------
@FOR /f "delims=" %%f IN ('dir %ProfilePath% /b /A-D') DO (
	SET /a "idx+=1"
	SET "FileName[!idx!]=%%~nxf"
 	SET "FilePath[!idx!]=%%~dpFf"
)


::----Display array elements--------------------------------
:DisplayArrayElements
for /L %%i in (1,1,%idx%) do (
	ECHO [%%i] "!FileName[%%i]!"
)
ECHO [0] "Carica nuovo profilo RGB"



::----Menu--------------------------------------------------
:MainMenuChoice
	ECHO [0m
	SET /p profileID=Inserisci il numero di un profilo RGB:
	IF /I "%profileID%" EQU "0" ( GOTO :LoadNewProfile 
	) ELSE IF "!FileName[%profileID%]!" == "" (
		ECHO [31m[ERRORE][0m - Nessun profilo RGB salvato sullo slot [%profileID%]
		GOTO :MainMenuChoice
	)
	
	ECHO [0m
	ECHO Profilo RGB [%profileID%] "[32m!FileName[%profileID%]![0m" selezionato con successo
	ECHO [0m
	ECHO 1) Imposta profilo
	ECHO 2) Rinomina profilo
	ECHO 3) Cancella profilo
	ECHO 4) Menu' iniziale
	ECHO 0) Esci

:SelectedProfileChoice
	set /P action=
	IF /I "%action%" EQU "1" ( GOTO :SetProfile 
	) ELSE IF /I "%action%" EQU "2" ( GOTO :RenameProfile 
	) ELSE IF /I "%action%" EQU "3" ( GOTO :DeleteProfile 
	) ELSE IF /I "%action%" EQU "4" (
		SET /a "idx"=0 
		test&cls
		GOTO :InitialPoint
	) ELSE IF /I "%action%" EQU "0" ( GOTO :ExitProcedure 
	) ELSE (
		GOTO :SelectedProfileChoice
	)






::-------------------------FUNCTION LOAD PROFILE------------
:LoadNewProfile
	ECHO Inserire il nome del nuovo profilo RGB [33m
	SET /P newfilename=
	ECHO [0m
	IF EXIST %ProfilePath%\"%newfilename%".xml (
		ECHO [33m[ATTENZIONE][0m - Esiste già un profilo RGB chiamato "[32m"%newfilename%".xml[0m"
	)
	IF EXIST C:\"Program Files (x86)"\LightingService\script\LastScript.xml (
		COPY /-y C:\"Program Files (x86)"\LightingService\script\LastScript.xml %ProfilePath%\"%newfilename%".xml
		ECHO [32m[OK][0m - File Copiato
		ECHO [0m
		GOTO :CleanEnvironment		
	) ELSE (
		ECHO [33m[ATTENZIONE][0m - Nessun profilo RGB esistente
		ECHO [0m
		ECHO Assicurarsi di aver installato "Armoury Crate" e che esista almeno 
		ECHO un file "LastScript.xml" nel path "C:\Program Files (x86)\LightingService\script\"
		Timeout /t 20
		GOTO :CleanEnvironment
	)


::-------------------------FUNCTION SET PROFILE-------------
:SetProfile

	
	ECHO [33m[1/6] Spengo il servizio LightingService - Non chiudere questa finestra![0m
	IF /I %verboseMode% == 1 (
		SC stop LightingService
		Timeout /t 1
	) ELSE (
		SC stop LightingService >NUL
		Timeout /t 1 >NUL	
	)

	ECHO [33m[2/6] Cancello LastScript.xml originale[0m
	IF /I %verboseMode% == 1 (
		DEL C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		Timeout /t 1
	) ELSE (
		DEL C:\"Program Files (x86)"\LightingService\script\LastScript.xml >NUL
		Timeout /t 1 >NUL	
	)
	
	ECHO [33m[3/6] Copio il profilo RGB nella directory di LightingService[0m
	IF /I %verboseMode% == 1 (
		COPY %AppData%\\"Hidro ASUS Light Changer"\"!FileName[%profileID%]!" C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		Timeout /t 1
	) ELSE (
		COPY %AppData%\\"Hidro ASUS Light Changer"\"!FileName[%profileID%]!" C:\"Program Files (x86)"\LightingService\script\LastScript.xml >NUL
		Timeout /t 1 >NUL	
	)

	ECHO [33m[4/6] Setto in sola lettura il profilo RGB !FileName[%profileID%]![0m
	IF /I %verboseMode% == 1 (
		ATTRIB +R C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		ATTRIB C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		Timeout /t 1
	) ELSE (
		ATTRIB +R C:\"Program Files (x86)"\LightingService\script\LastScript.xml  >NUL
		Timeout /t 1  >NUL
	)

	ECHO [33m[5/6] Riavvio il servizio LightingService![0m
	IF /I %verboseMode% == 1 (
		SC start LightingService
		Timeout /t 5
	) ELSE (
		SC start LightingService >NUL
		Timeout /t 5 >NUL
	)

	ECHO [33m[6/6] Rimuovo la sola lettura per il file "[32mLastScript.xml[0m" 
	IF /I %verboseMode% == 1 (
		ATTRIB -R C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		ATTRIB C:\"Program Files (x86)"\LightingService\script\LastScript.xml
		Timeout /t 1
	) ELSE (
		ATTRIB -R C:\"Program Files (x86)"\LightingService\script\LastScript.xml  >NUL
		Timeout /t 1  >NUL
	)

	ECHO [33m[DONE] Profilo RGB "[32m!FileName[%profileID%]![33m" applicato[0m
	Timeout /t 2

	GOTO :CleanEnvironment


::-------------------------FUNCTION RENAME PROFILE----------
:RenameProfile
	ECHO [0m
	ECHO Inserire il nuovo nome del profilo RGB [33m
	SET /P newfilename=
	ECHO [0m
	REN %ProfilePath%\"!FileName[%profileID%]!" "%newfilename%".xml	
	GOTO :CleanEnvironment


::-------------------------FUNCTION DELETE PROFILE----------
:DeleteProfile
	ECHO [0m
	ECHO Sicuro di voler [31mcancellare[0m il file "[32m!FileName[%profileID%]![0m" [Y/N]? 
	SET /P deleteYesNo=
	IF /I "%deleteYesNo%" EQU "N" ( GOTO :CleanEnvironment
	) ELSE IF /I "%deleteYesNo%" EQU "n" ( GOTO :CleanEnvironment
	) ELSE IF /I "%deleteYesNo%" EQU "Y" (
		DEL %ProfilePath%\"!FileName[%profileID%]!" 
		GOTO :CleanEnvironment
	) ELSE IF /I "%deleteYesNo%" EQU "y" (
		DEL %ProfilePath%\"!FileName[%profileID%]!" 
		GOTO :CleanEnvironment
	) ELSE (
		GOTO :DeleteProfile 
	)	


::-------------------------FUNCTION FIST PROFILE CHOICE-----
:FirstProfileChoice
	SET /P a=Vuoi caricare il tuo primo profilo RGB [Y/N]? 
	IF /I "%a%" EQU "Y" ( GOTO :LoadNewProfile
	) ELSE IF /I "%a%" EQU "N" ( GOTO :ExitProcedure 
	) ELSE IF /I "%a%" EQU "y" ( GOTO :LoadNewProfile
	) ELSE IF /I "%a%" EQU "n" ( GOTO :ExitProcedure 
	) ELSE (
		GOTO :FirstProfileChoice
	)


::-------------------------FUNCTION CLEAN ENVIRONMENT-------
:CleanEnvironment
	SET /a "idx"=0 
	test&cls
	GOTO :InitialPoint


::-------------------------END------------------------------
:ExitProcedure
	EXIT
