@ECHO OFF
SETLOCAL ENABLEEXTENSIONS

SET datadir="C:\Users\thy\source\repos\donner-graph"
SET neodir="C:\Users\thy\.Neo4jDesktop\neo4jDatabases\database-18ded114-d1bb-42db-95e6-e67282017fb1\installation-4.1.0"
SET neopwd=UZFbY3QIVYeue5uuboDJ

DEL /Q %neodir%\import\*.csv
XCOPY /Q /Y %datadir%\nodes\*.csv %neodir%\import\
XCOPY /Q /Y %datadir%\relations\*.csv %neodir%\import\
TYPE %datadir%\party.cypher | %neodir%\bin\cypher-shell -u neo4j -p %neopwd% --format verbose --debug

IF ERRORLEVEL 1 (
    ECHO ERRORLVL %ERRORLEVEL%
    GOTO END
)

ECHO ALL GOOD
GOTO END

:END
PAUSE
ECHO ON