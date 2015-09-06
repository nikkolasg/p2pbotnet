# Assigning value to a packet field f with type t
# t is now a regular ruby type/class such as String Fixnum or IPAddr
# packet.f "hello" ==> will transform "Hello" into type t (raise error if wrong type)
#
## Parsing type from raw data
#  type t
#  val = t::parse(data) 

module TypeInstanceMethod

    ## Design extend + include 
    def self.included(klass)
        klass.prepend(PrependInstanceMethods)
        klass.extend(TypeClassMethod)
    end 

    module TypeClassMethod
        ## Check if val is of the right type,i.e. the class we are checking on
        def valid? val
            val.is_a?(self)
        end

    end

    module PrependInstanceMethod
        ## just a "proxy" method to the class method size
        ## instead of implementing it twice ...
        def size val = nil
            self.class.size val
        end
    end
end

class String 

    include TypeInstanceMethod

    def self.bin str
        str
    end

    def self.unbin data,size = nil
        data
    end

    def self.size str = nil
        ## TODO: raise an error?
        str ? str.size : nil
    end

end

## Monkey patching fixnum class that does the work of figuring
## how to pack the value for network transmission
class Fixnum

    include TypeInstanceMethod

    def self.bin int 
        [int].pack(Utils::get_pack_type(Utils::get_int_size(int)))
    end

    def self.size int = nil
        @bsize || Utils::get_int_size(int)
    end


    def self.unbin data,size = nil
        size = @size || size || 4
        data.unpack(Utils::get_pack_type(size)).first
    end

    def self.byte_size size
        @bsize = size
    end

end

## Actual class to use for defining packet structure
class Char < Fixnum
    byte_size  1
end
class Short < Fixnum
    byte_size  2
end
class Int < Fixnum
    byte_size 4
end
class Long < Fixnum
    byte_size 8
end

class IPAddr 

    include TypeInstanceMethod

    IP_SIZE = 4 

    def self.bin ip
        [ip].pack(Utils::get_pack_type(IP_SIZE))
    end

    ## parse the ip address. Size can be specified when IPv6 implementation comes into place.
    def self.unbin data,size = nil
        integer = data.unpack(Utils::get_pack_type(IP_SIZE)).first
        ip = 4.times.map { |i| ((integer >> (i*8)) & 0xFF).to_s }.reverse.join(".")
        IPAddr.new ip
    end

    def self.size val = nil
        IP_SIZE
    end

end





