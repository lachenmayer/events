union = require('./scrapeUnion.coffee')
neo4j = require('neo4j')

URL = "http://localhost:7474"
db = new neo4j.GraphDatabase(URL)

pushToNeo = (config) ->
  # # Might need to parse the config file
  newNode = db.createNode config
  newNode.save (err, node) ->
    if (err)
      console.log "Error saving the data to the database #{err} #{node}"

scrapeAll = ->
  union.scrape pushToNeo

main = ->
  console.log "Events-scrape: Updating the auto-generated events"
  scrapeAll()

main()