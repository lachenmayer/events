neo4j = require('neo4j')
async = require('async')

URL = "http://localhost:7474"
db = new neo4j.GraphDatabase(URL)
ROOT_NODE_ID = 0

# The list of tables to be created by the database
TABLES = [
  "EVENT"       # Table with publicly visible events
  "USERS"       # Table with users
  "DATE"        # Table with events organized by dates
  "SCRAPEDDATA" # Table with all of the scraped events
  "GROUP"       # Table with groups/societies
  "TAGS"        # Table with all the tags
  "ICAL"        # Table with ical urls
  "JOBS"        # Table with scheduled jobs
]

serializeData = (data) ->
  values = for key, value of data
    "#{key}: \"#{value}\""
  values.join(", ")

returnDataWithId = (value) ->
  value.data['id'] = value.id
  return value.data

returnListWithId = (values) ->
  return (returnDataWithId(value) for value in values)

handler = (callback, handlerWithNoErrors) -> (err, data) ->
  if err
    callback err, null
  else
    handlerWithNoErrors data

handleWithError = (callback, errorMessage, handlerWithNoErrors) -> (err, data) ->
  console.log "Err: #{err}\nData: #{data}"
  if err
    console.log "Error: #{errorMessage}\n#{err}"
    callback err, null
  else
    handlerWithNoErrors data

# Filters the result of a callback
# If an error occurs then propagates the error
# Otherwise maps the result using the f function
returnValue = (err, data, f, callback) ->
  handler(callback, (data) -> callback null, f data)(err, data)

getRootNode = (callback) ->
  db.getNodeById(ROOT_NODE_ID) callback

# Retusn a node from a table with a given id
getTableNodeById = (tableName, nodeId, callback) ->
  query = "START r=Node({rootId}), n=Node({nodeId})
           MATCH r-[:#{tableName}]->t-->n
           RETURN n"
  
  db.query query, {rootId: ROOT_NODE_ID, nodeId: nodeId}, (err, results) ->
    if err
      console.log "Could not find node with id #{nodeId} inside of the table #{tableName}", err
      callback err, null
    else if (results.length == 0)
      console.log "Could not find node with id #{nodeId} inside of the table #{tableName}"
      callback err, null
    else
      callback null, results[0].n

# Creates a table with a given name
# The table is directly connected to the root node
createTable = (root, name, callback) ->
  makeTableNode root, name, (err, node) ->
    if err
      console.log "Failed creating the node #{name}: #{err}"
      callback(err, null)
    else
      console.log "Created the table #{name}"
      makeRelationship root, node, name, callback

hasRelationship = (node1, node2, relationshipType, callback) ->
  node1.outgoing relationshipType, handler callback, (relationships) ->
    matches = (rel for rel in relationships when rel.end.id == node2.id)
    if (matches.length > 0)
      callback null, matches[0]
    else
      callback null, false

# Creates the table if it hasn't been defined yet
makeTableNode = (root, name, callback) ->
  getTable name, (err, node) ->
    if (err)
      db.createNode({ name: name }).save callback
    else
      callback null, node

# Creates a relationship if it hasn't been defined before
makeRelationship = (node1, node2, type, callback) ->
  hasRelationship node1, node2, type, handler callback, (rel) ->
    if rel
      callback null, rel
    else
      node1.createRelationshipTo(node2, type)(callback)


removeRelationship = (node1, node2, type, callback) ->
  hasRelationship node1, node2, type, handler callback, (rel) ->
    if rel
      rel.delete callback
    else
      callback "Relationship #{type} does not exist", null

# Function to be called in order to create the nodes
# db.createNode should not be called on its own
createNode = (tableName, data, relationship, callback) ->
  getTable tableName, handleWithError callback, "Could not create the table #{tableName}", (table) ->
    newNode = db.createNode data
    newNode.save handleWithError callback, "Could not create the node", (node) ->
      makeRelationship table, node, relationship, (err, relationship) -> callback err, node, relationship

createUniqueNode = (tableName, data, relationship, callback) ->
  values = serializeData data
  query = "MATCH table
           WHERE table.name = \"#{tableName}\"
           CREATE UNIQUE (table)-[:#{relationship}]->(node {#{values}})
           RETURN node"
  db.query query, {}, handler callback, (nodes) ->
    callback null, nodes[0].node.id

# Sets up the initial nodes in the database
setup = ->
  console.log "Events-database: Setting up the database"
  getRootNode (err, rootNode) ->
    if err
      console.log "Could not find the root node #{err}"
    else
      f = (table) -> (callback) -> createTable rootNode, table, callback
      queries = ((f table) for table in TABLES)
      async.parallel queries, (err) ->
        if err
          console.log "Failed creating the nodes"
        else
          console.log "Database setup successfully"

# Function that looks for the table with a given name
getTable = (fieldName, handler) ->
  query = "START root=Node(0) MATCH (root)-[:#{fieldName}]->table RETURN table"
  db.query query, {}, (err, results) ->
    returnValue err, results, ((results) -> results[0].table), handler

# Defines the exported variables and functions
exports.db = db
exports.setup = setup
exports.makeRelationship = makeRelationship
exports.getTable = getTable
exports.rootNodeId = ROOT_NODE_ID
exports.createNode = createNode
exports.getTableNodeById = getTableNodeById
exports.returnValue      = returnValue
exports.returnDataWithId = returnDataWithId
exports.returnListWithId = returnListWithId
exports.hasRelationship  = hasRelationship
exports.handle           = handler
exports.handleErr        = handleWithError
exports.removeRelationship = removeRelationship
exports.serializeData      = serializeData
exports.createUniqueNode   = createUniqueNode

# Running the script sets up the database
if (!module.parent)
  setup()
