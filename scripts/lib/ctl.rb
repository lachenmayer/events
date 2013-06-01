class Ctl
    def start
    end

    def stop
    end

    def restart
        stop
        start
    end

    def is_running?
        false
    end
end