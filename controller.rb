require 'eventmachine'

class Controller < EM::Connection
    attr_accessor :type
    def connection_completed
        puts "#{@type} initialized ..."
        if @type == "client" 
            arr = [24,"nico"]
            send_data arr.pack("C Z")
        end
    end

    def receive_data data
        puts "data length : " + data.length.to_s
        puts data
    end
end

EM.run do
    Signal.trap("INT")  { EventMachine.stop }
    Signal.trap("TERM") { EventMachine.stop }
    if ARGV[0]== "server"
    EM.start_server("0.0.0.0",ARGV[1],Controller) do |c|
        c.type = "server"
    end
    elsif ARGV[0] == "client"
    if ARGV[1] && ARGV[2]
        EM.connect(ARGV[1],ARGV[2].to_i,Controller) do |c|
            c.type = "client"
        end
    end
    end
end
