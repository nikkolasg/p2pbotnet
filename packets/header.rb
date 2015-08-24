
module Packet

    class Header

        attr_accessor :len_len,:name_len,:coumpound,:bigendian
        attr_accessor :pLength, :name
        ## size of the header itself
        attr_accessor :size
        
        ## create a header out of all informations
        def initialize ll,nl,c,b,length,name
            @len_len = ll
            @name_len = nl
            @coumpound = c
            @bigendian = b
            @pLength = length
            @name = name
            @size = 1 + ll + nl
        end

        def self.from_packet packet
            name = packet.name
            length = packet.payload
        end

        ## Parse a header out of raw data
        def self.parse data
            cb = data.unpack("C").to_i
            len_len = (cb & 0xC0) >> 6
            name_len = (cb & 0x38) >> 3 + 1
            coumpound = (cb &  0x04) >> 2 == 1 ? true : false
            bigendian = (cb & 0x02) >> 1 == 1 ? true : false

            len_type = Utils::get_good_type len_len
            info = data.unpack("x #{len_type} Z#{name_len}")        
            length,name = info.first,info[1]
            $log.debug "Header parsed : name = #{name}, length = #{length} " + coumpound ? "(coumpound)" : "(leaf)"
            Header.new len_len,name_len,coumpound,bigendian,length,name
        rescue StandardError => e
            $log.warn e
        end
    end
end
