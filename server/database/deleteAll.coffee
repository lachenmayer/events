# Just a quick script for debugging purposes

database = require './database'

db = database.db


query =  "START n=Node(*)
        MATCH n-[r?]-()
        WHERE ID(n) <> 0
        DELETE n,r"
      
db.query query, (res) -> 
	if !res
		console.log "Successfully Deleted Database"
	else
		console.log "Some Error: #{res}"