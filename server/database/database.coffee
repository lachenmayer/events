neo4j = require('neo4j')
async = require('async')

URL = "http://localhost:7474"
db = new neo4j.GraphDatabase(URL)

createNodes = (nodes, created, handler) ->
  if (nodes.length == 0)
    handler()
  else
    db.createNode(nodes[0]).save ->

setupRelations = (err, nodes) ->
  if err
    console.log "Error in creating nodes #{err}"
  else
    console.log "Created the nodes"
    {rootNode, eventNode, peopleNode, datesNode}  = nodes
    async.parallel [
      (callback) -> makeRelationship(rootNode, eventNode, "property", callback)
      (callback) -> makeRelationship(rootNode, peopleNode, "property", callback)
      (callback) -> makeRelationship(rootNode, datesNode, "property", callback)
    ], (err) ->
      if (err)
        console.log "Events-database: error #{err}"
      else
        console.log "Events-database: Database set up"


# Creates the node if it hasn't been defined yet
makeNode = (root, name, callback) ->
  getNode name, (err, node) ->
    if (err)
      db.createNode({ name: name }).save callback
    else
      callback null, node

# Creates a relationship if it hasn't been defined before
makeRelationship = (node1, node2, type, callback) ->
  node1.outgoing type, (err, relationships) ->
    if (err)
      console.log "failed #{err}"
      callback(err, null)
    else
      matches = (rel for rel in relationships when rel.end.id == node2.id)
      if (matches.length > 0)
        callback null, matches[0]
      else
        node1.createRelationshipTo(node2, type)(callback)

# Sets up the initial nodes in the database
setup = ->
  console.log "Events-database: Setting up the database"
  db.getNodeById(0) (err, rootNode) ->
    async.parallel {
      eventNode:  (callback) -> makeNode rootNode, "event", callback
      peopleNode: (callback) -> makeNode rootNode, "person", callback
      datesNode:  (callback) -> makeNode rootNode, "date", callback
      rootNode:   (callback) -> callback(null, rootNode)
    }, setupRelations

# Function that looks for the main nodes being directly liked to the root node
getNode = (fieldName, handler) ->
  query = "START root=Node(0) MATCH (root)-->(m) WHERE m.name = \"#{fieldName}\" RETURN m"
  db.query query, {}, (err, results) ->
    if (err)
      handler(err, null)
    else
      handler(null, results[0].m)

# Handler that prints the found node from the database
outputNode = (err, node) ->
    if (err)
      console.log "Error in fetching the node #{err}"
    else
      console.log node[0].m.data

# Defines the exported variables and functions
exports.db = db
exports.setup = setup
exports.makeNode = makeNode
exports.makeRelationship = makeRelationship
exports.getNode = getNode

# Running the script sets up the database
if (!module.parent)
  setup()