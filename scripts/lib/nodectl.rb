require 'lib/ctl.rb'

class NodeCtl < Ctl
    def start
        if is_running?
          puts "Node is already running." 
          return
        end

        printf "Starting node... "
        Dir.mkdir(@@logs_dir) unless File.exists?(@@logs_dir)
        `coffee ../server/app.coffee > ../logs/node-log.txt &`
        puts "Done."
    end

    def stop
        return if !is_running?

        node_pid = Util.process_pid("node.*app.coffee")
        puts "Found node process with pid #{node_pid}"
        printf "Stopping node... "
        `kill #{node_pid}`
        puts "Done."
    end

    def is_running?
        not Util.process_pid("node.*app.coffee").empty?
    end
end
