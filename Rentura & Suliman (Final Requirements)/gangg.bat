@echo off
setlocal EnableDelayedExpansion




set "sortingAlgorithm=fcfs" 
set "sortingAlgoType=sortingAlgoType"
set "groupNumber=1"
set "inputCSVFile=input_file_3.csv"
set "outputCSVFile=output.csv"
set "script_folder=%~dp0"
set "currentTime=%TIME:~0,5%"



if not exist "%inputCSVFile%" (
    echo CSV input file is not found.
    exit /b
)


:dataNaming
echo Job Name,Arrival Time,Burst Time,Finish Time,Turnaround Time,Waiting Time> "%outputCSVFile%"
(for /f "usebackq skip=1 tokens=1-7 delims=," %%A in ("%inputCSVFile%") do (
    call :sortingAlgorithmCalculation "%%A" "%%B" "%%C" "%%D" "%%E" "%%F" "%%G"
))>> "%outputCSVFile%"
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set datetime=%%a
set "fileNameTimeStamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%"
ren "%outputCSVFile%" "%fileNameTimeStamp%_%sortingAlgorithm%_%groupNumber%.csv
schtasks /query /tn "%sortingAlgoType%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Scheduled task already exists.
) else (
    schtasks /create /tn "%sortingAlgoType%" /tr "%script_folder%\%~nx0" /sc daily /st %currentTime% /ri 480 /du 24:00 /f
)
goto :eof



:sortingAlgorithmCalculation
set "algoJobName=%~1"
set "algoArrivalTime=%~2"
set "algoBurstTime=%~3"
if /I "!sortingAlgorithm!"=="fcfs" (
    set "algoFinishTime=%~4" 
) else if /I "!sortingAlgorithm!"=="srtf" (
    set "algoFinishTime=%~6" 
) else if /I "!sortingAlgorithm!"=="sjf" (
    set "algoFinishTime=%~5" 
) else if /I "!sortingAlgorithm!"=="rr" (
    set "algoFinishTime=%~7" 
) else (
    echo Sorting Algorithm is not valid.
    exit /b
)
set /a "algoTurnaroundTime=algoFinishTime - algoArrivalTime"
if !algoTurnaroundTime! lss 0 set /a "algoTurnaroundTime=0"
set /a "algoWaitingTime=algoTurnaroundTime - algoBurstTime"
if !algoWaitingTime! lss 0 set /a "algoWaitingTime=0"
echo !algoJobName!,!algoArrivalTime!,!algoBurstTime!,!algoFinishTime!,!algoTurnaroundTime!,!algoWaitingTime!
goto :eof


call :dataNaming