require 'lib/ctl.rb'

class Neo4jCtl < Ctl
    def start
      stop if is_running?
      
      printf "Starting Neo4j... "
      `../server/database/neo4j-community-1.9/bin/neo4j start > /dev/null`
      puts "Done."
    end

    def stop
      return if !is_running?
      
      printf "Stopping Neo4j... "
      `../server/database/neo4j-community-1.9/bin/neo4j stop > /dev/null`
      puts "Done."
    end
    
    def is_running?
      `../server/database/neo4j-community-1.9/bin/neo4j status | grep "not running" | wc -l`
    end
end