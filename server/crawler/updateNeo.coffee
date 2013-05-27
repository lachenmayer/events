union = require('./scrapeUnion.coffee')
database = require('../database/database.coffee')

db = database.db

pushToNeo = (config) ->
  # Might need to parse the config file
  newNode = db.createNode config
  newNode.save (err, node) ->
    if (err)
      console.log "Error saving the data to the database #{err} #{node}"

scrapeAll = ->
  # Remove the previously scraped data
  query = "START n=Node(*)
           WHERE n.source = \"scrapedData\"
           DELETE n"
  db.query(query)

  # Add the new data to the database
  union.scrape pushToNeo

main = ->
  console.log "Events-scrape: Updating the auto-generated events"
  scrapeAll()

# If the module is run from a script invoke it
if (!module.parent)
  main()