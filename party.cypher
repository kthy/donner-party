////////////////////////////////////////////////////////////////////////
// Donner Party Cypher /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

// Clear database
CALL apoc.schema.assert({},{},true);
MATCH (n) DETACH DELETE n;

// Create constraints and indices
CREATE CONSTRAINT uniq_location_csvid ON (l:Location) ASSERT l.csvId IS UNIQUE;
CREATE INDEX idx_location_ll FOR (l:Location) ON (l.ll);

CREATE CONSTRAINT uniq_person_csvid ON (p:Person) ASSERT p.csvId IS UNIQUE;

CREATE CONSTRAINT uniq_state_abbr ON (s:State) ASSERT s.abbr IS UNIQUE;
CREATE INDEX idx_state_ll FOR (s:State) ON (s.ll);

// Create State nodes
LOAD CSV WITH HEADERS FROM 'file:///united-states.csv' AS csvLine
CREATE (:State {
    abbr: csvLine.state
  , name: csvLine.name
  , ll: point({
      latitude: toFloat(csvLine.lat), longitude: toFloat(csvLine.lon)
    })
});

// Create Location nodes
LOAD CSV WITH HEADERS FROM 'file:///location-location-location.csv' AS csvLine
CREATE (loc:Location {
    csvId: toInteger(csvLine.id)
  , name: csvLine.name
  , ll: point({
      latitude: toFloat(csvLine.lat), longitude: toFloat(csvLine.lon)
    })
});

// Create Location -> State relations
LOAD CSV WITH HEADERS FROM 'file:///location-location-location.csv' AS csvLine
MATCH (loc:Location {csvId: toInteger(csvLine.id)})
MATCH (state:State {abbr: csvLine.state})
CREATE (loc)-[:IN]->(state);

// Create Person nodes
LOAD CSV WITH HEADERS FROM 'file:///peanut-gallery.csv' AS csvLine
CREATE (:Person {
    csvId: toInteger(csvLine.id)
  , lastName: csvLine.lastName
  , firstName: csvLine.firstName
  , maidenName: csvLine.maidenName
  , suffix: csvLine.suffix
  , name: csvLine.firstName + ' ' +
          csvLine.lastName +
          (CASE WHEN size(csvLine.suffix) > 0
                THEN ' ' + csvLine.suffix
                ELSE '' END) +
          (CASE WHEN size(csvLine.maidenName) > 0
                THEN ' (née ' + csvLine.maidenName + ')'
                ELSE '' END)
  , gender: csvLine.gender
  , dateBirth: csvLine.dateBirth
  , dateDeath: csvLine.dateDeath
  , survivor: coalesce(toBoolean(csvLine.survivor), FALSE)
});

// Create marriage relations
LOAD CSV WITH HEADERS FROM "file:///marriages.csv" AS csvLine
MATCH (fromSpouse:Person {csvId: toInteger(csvLine.fromSpouseId)})
    , (toSpouse:Person {csvId: toInteger(csvLine.toSpouseId)})
CREATE (fromSpouse)-[:MARRIED {ordinality: toInteger(csvLine.ordinality), since: csvLine.since}]->(toSpouse);

// Create parent-child relations
LOAD CSV WITH HEADERS FROM "file:///children.csv" AS csvLine
MATCH (parent:Person {csvId: toInteger(csvLine.parentId)})
    , (child:Person {csvId: toInteger(csvLine.childId)})
CREATE (child)-[:IS_CHILD_OF]->(parent);

// Create sibling relations
LOAD CSV WITH HEADERS FROM "file:///siblings.csv" AS csvLine
MATCH (firstSibling:Person {csvId: toInteger(csvLine.firstSiblingId)})
    , (secondSibling:Person {csvId: toInteger(csvLine.secondSiblingId)})
CREATE (firstSibling)-[:IS_SIBLING_OF]->(secondSibling);

// Remove cruft
DROP CONSTRAINT uniq_location_csvid;
DROP CONSTRAINT uniq_person_csvid;

MATCH (n)
WHERE n:Person OR n:Location
REMOVE n.csvId;