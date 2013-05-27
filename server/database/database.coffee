neo4j = require('neo4j')

URL = "http://localhost:7474"
db = new neo4j.GraphDatabase(URL)

exports.db = db

# Sets up the initial nodes in the database
exports.setup = ->
  db.createNode({ objectType: "scrapedData" })

# TODO: add query options