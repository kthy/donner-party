# There's No Party Like A Donner Party

![You have died of dysentery](https://i.imgur.com/L6o0abQ.jpg)

A hobby project to explore the relationships of [the ill-fated Donner Party](https://en.wikipedia.org/wiki/Donner_Party)
through the medium of a graph.

## Why?

To learn myself how to use [Neo4j](https://neo4j.com/).

## Structure

All data are in the CSV files. The single CQL file pulls them all in and creates
nodes and links.

For more information on loading CSV files into Neo4j, see
[Importing CSV Data into Neo4j](https://neo4j.com/developer/guide-import-csv/).

## Schema

### Nodes

* `Person`
* `Group`
* `Location`
* `State`
* `Event`

### Relationships

* `(Location)-[:IS_IN]->(State)`
* `(Person)-[:MARRIED {ordinality: int}]->(Person)`
* `(Person)-[:IS_SIBLING_OF]->(Person)`
* `(Person)-[:IS_CHILD_OF]->(Person)`
* `(Person)-[:IS_IN]->(Group)`
* `(Person)-[:BORN_IN]->(Location)`
* `(Person)-[:DIED_AT]->(Location)`
* `(Event)-[:IS_IN]->(Location)`

## Database

Scripts are tested on a Neo4j v4.1 instance with
`cypher.lenient_create_relationship=true`.

## Sources

* [New Light on the Donner Party](https://user.xmission.com/~octa/DonnerParty/index.html) by Kristin Johnson, librarian at Salt Lake Community College and historian for the Donner Party Archaeology Project.
* [Wikipedia](https://en.wikipedia.org/wiki/Donner_Party) of course.
