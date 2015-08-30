

## allocating new type
## Type::String.new("This is my payload")
##
## Parsing type from raw data
## 
module Type

    attr_accessor :value

    def initialize value
        @value = value
    end

    def to_s
        @value.to_s
    end
    
    ## Design extend + include 
    def self.included(klass)
       klass.extend(ClassMethods)
    end

    module ClassMethods

        def self.size
            nil
        end
    end

    class String 
        include  Type

        def pack 
            @value
        end

        def self.unpack data
            Type::String.new data
        end

        def size
            @value.size
        end

        def self.size
            nil
        end

    end

    ## Wrapper class that does the work of figuring
    ## how to pack the value for network transmission
    class Integer
        include Type

        def initialize value
            @value = value
            @size = Utils::get_int_size(@value)
            @type = Utils::get_pack_type size
        end

        def pack 
            [@value].pack(@type)
        end

        def size
            self.class.size || @size
        end

        ## DSL part of defining integer type
        ## char / short / int / long
        ## Size of the integer    
        def self.size size = nil
            if size
               @size  = size
            else 
                @size
            end
        end

        def self.unpack data
            value = data.unpack(Utils::get_pack_type(@size)).first
            self.new value
        end
    end

    ## Specific class when unpacking from string
    ## of course must know the type of the integer if you want ot decode it...
    class UInt8 < Integer
        size 1
    end

    class UInt16 < Integer
        size 2
    end

    class UInt32 < Integer
        size 4
    end

    class UInt64 < Integer
        size 8
    end

    class IPAddress 
        include Type
        require 'ipaddr'
        
        IP_SIZE = 4 


        def initialize value = nil
                @ip = value
                @int = ::IPAddr.new(@ip,Socket::AF_INET).to_i
        end

        def pack
            [@int].pack(Utils::get_pack_type(IP_SIZE))
        end

        def self.unpack data
            integer = data.unpack(Utils::get_pack_type(IP_SIZE)).first
            ip = 4.times.map { |i| ((integer >> (i*8)) & 0xFF).to_s }.reverse.join(".")
            IPAddress.new ip
        end

        def size
            IP_SIZE
        end

        def self.size
            IP_SIZE
        end
        
        def to_s
            @ip
        end
    end

end




