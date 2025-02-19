@echo off

call "%~dp0\..\config.bat"

:begin
set /p TestClassName= "Enter test class name :"
if [%TestClassName%]==[] goto:begin
set /p TestRelativePath= "Enter relative to [Source\%ProjectPureName%] directory (use \ symbol for subdirs):"

rem .h / .cpp file names
set TestCppFileName=%TestClassName%.cpp
set TestHFileName=%TestClassName%.h

rem full paths to .h / .cpp files to create
set TestAbsoluteDir=%SourceCodePath%\%ProjectPureName%\%TestRelativePath%
if [%TestRelativePath%]==[] set TestAbsoluteDir=%SourceCodePath%\%ProjectPureName%
set TestCppFilePath=%TestAbsoluteDir%\%TestCppFileName%
set TestHFilePath=%TestAbsoluteDir%\%TestHFileName%

rem Confirmation
echo.
echo =========== Files to be created: ===========
echo %TestCppFilePath%
echo %TestHFilePath%
echo ======================================
echo.
set /p UserConfirmed= "Confirm? [Y/N or (E)xit] :" 
if %UserConfirmed% == N goto:begin
if %UserConfirmed% == n goto:begin
if %UserConfirmed% == E goto:EOF
if %UserConfirmed% == e goto:EOF

rem create dir
if not exist %TestAbsoluteDir% mkdir %TestAbsoluteDir%

rem full paths .h / .cpp template files
set TestCppTemplateFilePath=%ProjectRoot%\devops\tests\templates\Test.cpp.template
set TestHTemplateFilePath=%ProjectRoot%\devops\tests\templates\Test.h.template

rem template file vars
rem path with \
set TempPath=%ProjectPureName%\%TestRelativePath%\%TestClassName%.h
rem replace \ with / for include string
set TEST_INCLUDE_FILE="%TempPath:\=/%"
set "OR=^|"
set "AND=^&"

rem remove old files if exist
del /q %TestCppFilePath%
del /q %TestHFilePath%

rem create actual files
call :createTemplate %TestCppTemplateFilePath% , %TestCppFilePath%
call :createTemplate %TestHTemplateFilePath% , %TestHFilePath%

rem clang-format
call "%~dp0\..\misc\format_all_files.bat"

echo %TEST_INCLUDE_FILE_1%
goto:EOF

rem function to create .h / .cpp from template
:createTemplate
set TemplateName=%~1
set FileToWriteIn=%~2
for /f "tokens=*" %%a in (%TemplateName%) do (
    if %%a == NEW_LINE (
        echo.>>%FileToWriteIn%
    ) else (
        echo %%a
        call echo %%a>>%FileToWriteIn%
    )
)

