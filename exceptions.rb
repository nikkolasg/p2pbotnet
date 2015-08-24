module Exceptions
    module Packet
        class PacketError < StandardError
        end
        class WrongName < PacketError
        end
        class Malformed < PacketError
        end
    end
end
