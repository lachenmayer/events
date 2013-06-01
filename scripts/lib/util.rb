class Util
    def self.process_pid(pattern)
        `ps aux | grep #{pattern} | grep -v grep | awk '{print $2}'`
    end
end