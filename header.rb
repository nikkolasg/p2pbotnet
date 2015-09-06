require_relative 'utils'
module Packet

    class Header

        attr_accessor :len_len,:name_len,:coumpound,:bigendian
        attr_accessor :pLength, :type
        ## size of the header itself
        attr_accessor :size

        ## create a header out of all informations
        def initialize ll,nl,c,b,length,name
            @len_len = ll
            @type_len = nl
            @coumpound = c
            @bigendian = b
            @pLength = length
            @type = name.to_s
            @size = 1 + ll + nl
        end
        
        def to_s
            "Coumpound #{@coumpound}, header size #{@size}, packet size #{@pLength}, len_len = #{@len_len}, name_len = #{@type_len}"
        end

        ## return this header into a byte string 
        def pack
            cb = 0x00
            case @len_len
            when 1 then cb += 0x40
            when 2 then cb += 0x80
            when 3 then cb += 0xC0
            end
            name_len = @type_len - 1
            name_len = (name_len & 0xFF) << 3
            cb += name_len 
            cb += 0x04 if @coumpound 
            str = [cb].pack("C")
            str += [@pLength].pack(Utils::get_pack_type(@len_len))
            str += @type
            str
        end

        ## construct a header from a packet
        def self.from_packet packet
            name = packet.class.name
            length = packet.children_size + packet.fields_size
            len_len = Utils::get_int_size(length)
            ## ASCII ... =)
            name_len = name.size
            coumpound = packet.children.empty? ? false : true
            bigendian = 0
            $log.debug "Header created from packet: name_length = #{name_len} name = #{name}, length_length = #{len_len} ,length = #{length}, coumpound ? #{coumpound ? "yes" : "no"}"

            Packet::Header.new len_len,name_len,coumpound,bigendian,length,name
        end

        ## Parse a header out of raw data
        def self.parse data
            cb = data.unpack("C").first.to_i
            len_len = (cb & 0xC0) >> 6
            name_len = ((cb & 0x38) >> 3) + 1
            coumpound = (cb &  0x04) >> 2 == 1 ? true : false
            bigendian = (cb & 0x02) >> 1 == 1 ? true : false

            len_type = Utils::get_pack_type len_len
            info = data.unpack("x #{len_type} Z#{name_len}")        
            length,name = info.first,info[1]
            $log.debug "Header parsed : Control Byte : #{data.unpack("C").first}, (name_length = #{name_len} name = #{name}, length_length = #{len_len} ,length = #{length}, coumpound ? #{coumpound ? "yes" : "no"} || info = #{info.inspect}"
            Header.new len_len,name_len,coumpound,bigendian,length,name
        rescue StandardError => e
            $log.warn e
        end
    end
end
