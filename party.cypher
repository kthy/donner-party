////////////////////////////////////////////////////////////////////////
// Donner Party Cypher /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

// --
RETURN "Clear database" AS `Action:`;

CALL apoc.schema.assert({},{},true);
MATCH (n) DETACH DELETE n;

// --
RETURN "Create constraints and indices" AS `Action:`;

CREATE CONSTRAINT uniq_event_csvid ON (e:Event) ASSERT e.csvId IS UNIQUE;

CREATE CONSTRAINT uniq_group_name ON (g:Group) ASSERT g.name IS UNIQUE;

CREATE CONSTRAINT uniq_location_csvid ON (l:Location) ASSERT l.csvId IS UNIQUE;
CREATE INDEX idx_location_ll FOR (l:Location) ON (l.ll);

CREATE CONSTRAINT uniq_person_csvid ON (p:Person) ASSERT p.csvId IS UNIQUE;

CREATE CONSTRAINT uniq_state_abbr ON (s:State) ASSERT s.abbr IS UNIQUE;
CREATE INDEX idx_state_ll FOR (s:State) ON (s.ll);

// --
RETURN "Create State nodes" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///states.csv' AS csvLine
CREATE (:State {
    abbr: csvLine.state
  , name: csvLine.name
  , ll: point({
      latitude: toFloat(csvLine.lat), longitude: toFloat(csvLine.lon)
    })
});

// --
RETURN "Create Location nodes" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///locations.csv' AS csvLine
OPTIONAL MATCH (state:State {abbr: csvLine.state})
CREATE (loc:Location {
    csvId: toInteger(csvLine.id)
  , name: csvLine.name
  , ll: point({
      latitude: toFloat(csvLine.lat), longitude: toFloat(csvLine.lon)
    })
})
CREATE (loc)-[:IS_IN]->(state);

// --
RETURN "Create Event nodes" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///events.csv' AS csvLine
OPTIONAL MATCH (loc:Location {csvId: toInteger(csvLine.locationId)})
CREATE (event:Event {
    csvId: toInteger(csvLine.id)
  , text: csvLine.text
  , date: csvLine.date
})
CREATE (event)-[:IS_IN]->(loc);

// --
RETURN "Create Group nodes" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///groups.csv' AS csvLine
CREATE (:Group { name: csvLine.name });

// --
RETURN "Create Person nodes" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///persons.csv' AS csvLine
OPTIONAL MATCH (g:Group {name: csvLine.group})
CREATE (p:Person {
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
})
CREATE (p)-[:IS_IN]->(g);

// --
RETURN "Create Person -> Event relations" AS `Action:`;

LOAD CSV WITH HEADERS FROM 'file:///persons.csv' AS csvLine
MATCH (p:Person {csvId: toInteger(csvLine.id)})
UNWIND apoc.convert.toIntList(csvLine.eventIds) AS eventId
MATCH (e:Event {csvId: eventId})
CREATE (p)-[:PARTICIPATES_IN]->(e);

// --
RETURN "Create marriage relations" AS `Action:`;

LOAD CSV WITH HEADERS FROM "file:///marriages.csv" AS csvLine
MATCH (fromSpouse:Person {csvId: toInteger(csvLine.fromSpouseId)})
    , (toSpouse:Person {csvId: toInteger(csvLine.toSpouseId)})
CREATE (fromSpouse)-[:MARRIED {ordinality: toInteger(csvLine.ordinality), since: csvLine.since}]->(toSpouse);

// --
RETURN "Create parent-child relations" AS `Action:`;

LOAD CSV WITH HEADERS FROM "file:///children.csv" AS csvLine
MATCH (parent:Person {csvId: toInteger(csvLine.parentId)})
    , (child:Person {csvId: toInteger(csvLine.childId)})
CREATE (child)-[:IS_CHILD_OF]->(parent);

// --
RETURN "Create sibling relations" AS `Action:`;

LOAD CSV WITH HEADERS FROM "file:///siblings.csv" AS csvLine
MATCH (firstSibling:Person {csvId: toInteger(csvLine.firstSiblingId)})
    , (secondSibling:Person {csvId: toInteger(csvLine.secondSiblingId)})
CREATE (firstSibling)-[:IS_SIBLING_OF]->(secondSibling);

// --
RETURN "Remove cruft" AS `Action:`;
DROP CONSTRAINT uniq_event_csvid;
DROP CONSTRAINT uniq_group_name;
DROP CONSTRAINT uniq_location_csvid;
DROP CONSTRAINT uniq_person_csvid;
DROP CONSTRAINT uniq_state_abbr;

MATCH (n) WHERE n:Event OR n:Location OR n:Person
REMOVE n.csvId;
