require 'lib/ctl.rb'

class NginxCtl < Ctl

    def start
        if is_running?
          puts "nginx is already running." 
          return
        end

        printf "Starting nginx... "
        `nginx`
        puts "Done.\n"
    end

    def stop
        return if !is_running?

        printf "Stopping nginx... "
        `nginx -s stop`
        puts "Done.\n"
    end

    def is_running?
        not Util.process_pid("nginx").empty?
    end 
end