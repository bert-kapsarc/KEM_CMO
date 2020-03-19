::************************************************
:: GAMS 24.1.3 Run Script
:: KAPSARC Energy Model
::************************************************
:: Version 1, Jun 20, 2017
@echo off
cls

:: Setting up the environment path to include GAMS
path = %PATH%;C:\GAMS\win64\24.1

:: --------- TIME STAMP ---------
@echo off
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set loc_date=%%a%%b%%c)
For /f "tokens=1-3 delims=/:/ " %%a in ('echo %TIME%') do (set loc_time=%%a-%%b-%%c)
set timeStamp=%loc_date%_%loc_time%


:: Creating results directory
IF EXIST build\%timeStamp% rmdir /s/q build\%timeStamp%

mkdir build\%timeStamp%

echo. & echo Running the model
:: Launch GAMS through the console with and assigning the output to the created directory
gams KEM_CEM.gms pf=GAMS_PARM.prm O=build\%timeStamp%\KEM_CEM.lst,^
                LF=build\%timeStamp%\KEM_CEM.log, gdx=build\%timeStamp%\KEM_CEM


echo. & echo Saving the output to build\%timeStamp%\


:: moving the option outputs to the created directory
echo. & echo Cleaning execution files
IF EXIST build\dict.txt^
    move build\dict.txt build\%timeStamp%\dict.txt >nul
IF EXIST build\mcp*^
    for %%f in (build\mcp*) do move build\%%~nf%%~xf build\%timeStamp%\%%~nf%%~xf >nul
IF EXIST mcp*^
    for %%f in (mcp*) do move %%~nf%%~xf build\%timeStamp%\%%~nf%%~xf >nul

:: Cleaning the execution
::IF EXIST *.log^
::    del /s/q *.log
IF EXIST support.jams^
    del /s/q support.jams
IF EXIST 225*^
    for /D %%f in (225*) do rmdir %%f /s/q
