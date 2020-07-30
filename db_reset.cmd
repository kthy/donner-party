@ECHO OFF
SETLOCAL ENABLEEXTENSIONS

SET neodir="C:\Users\thy\.Neo4jDesktop\neo4jDatabases\database-18ded114-d1bb-42db-95e6-e67282017fb1\installation-4.1.0"
SET neopwd=UZFbY3QIVYeue5uuboDJ

REM @ECHO DROP CONSTRAINT uniq_person_id;DROP CONSTRAINT uniq_location_id;DROP INDEX idx_location_ll;DROP INDEX idx_state_abbr;MATCH (n) DETACH DELETE n;CALL db.constraints;CALL db.indexes; | %neodir%\bin\cypher-shell -u neo4j -p %neopwd% --format verbose --debug
@ECHO DROP INDEX idx_location_ll;DROP INDEX idx_state_abbr;MATCH (n) DETACH DELETE n;CALL db.constraints;CALL db.indexes; | %neodir%\bin\cypher-shell -u neo4j -p %neopwd% --format verbose --debug

IF ERRORLEVEL 1 (
    ECHO ERRORLVL %ERRORLEVEL%
    GOTO END
)

ECHO ALL GOOD
GOTO END

:END
PAUSE
ECHO ON