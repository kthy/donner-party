// Donner Party CQL

CREATE CONSTRAINT uniq_location_id ON (l:Location) ASSERT l.id IS UNIQUE;
CREATE CONSTRAINT uniq_person_id ON (person:Person) ASSERT person.id IS UNIQUE;
CREATE INDEX idx_location_ll FOR (l:Location) ON (l.ll);
CREATE INDEX idx_state_abbr FOR (s:State) ON (s.abbr);

LOAD CSV WITH HEADERS FROM 'file:///location-location-location.csv' AS csvLine
MERGE (state:State {abbr: csvLine.state})
CREATE (loc:Location {
    id: toInteger(csvLine.id)
  , name: csvLine.name
  , ll: point({
      latitude: toFloat(csvLine.lat), longitude: toFloat(csvLine.lon)
    })
})
CREATE (loc)-[:IN]->(state);

LOAD CSV WITH HEADERS FROM 'file:///peanut-gallery.csv' AS csvLine
CREATE (:Person {
    id: toInteger(csvLine.id)
  , lastName: csvLine.lastName
  , firstName: csvLine.firstName
  , maidenName: csvLine.maidenName
  , name: csvLine.firstName + ' ' + csvLine.lastName + (CASE WHEN size(csvLine.maidenName) > 0 THEN ' (née ' + csvLine.maidenName + ')' ELSE '' END)
  , gender: csvLine.gender
  , dateBirth: csvLine.dateBirth
  , dateDeath: csvLine.dateDeath
  , survivor: toBoolean(csvLine.survivor)
});

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///marriages.csv" AS csvLine
MATCH (husband:Person {id: toInteger(csvLine.husbandId)})
    , (wife:Person {id: toInteger(csvLine.wifeId)})
CREATE (husband)-[:IS_MARRIED_TO {since: csvLine.since}]->(wife);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///children.csv" AS csvLine
MATCH (parent:Person {id: toInteger(csvLine.parentId)})
    , (child:Person {id: toInteger(csvLine.childId)})
CREATE (child)-[:IS_CHILD_OF]->(parent);

DROP CONSTRAINT uniq_location_id;
DROP CONSTRAINT uniq_person_id;

MATCH (n)
WHERE n:Person OR n:Location
REMOVE n.id;
