
module Packet
    

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

        class String 
            prepend Type
            
            def initialize value; end; 

            def pack 
                @value
            end

            def self.unpack data
                Type::String.new data
            end

        end

        ## Wrapper class that does the work of figuring
        ## how to pack the value for network transmission
        class Integer
            prepend Type

            def initialize value
                length = Utils::get_int_length @value
                @type = Utils::get_pack_type length
            end

            def pack 
                @value.pack(@type)
            end
            
            ## DSL part of defining integer type
            ## char / short / int / long
            ## Size of the integer    
            def self.size size
                @size  = size
            end

            def self.unpack data
                value = data.unpack(Utils::get_pack_type(@size))
                Integer.new value
            end
        end
        
        ## Specific class when unpacking from string
        ## of course must know the type of the integer if you want ot decode it...
        class Int8 < Integer
            size 1
        end

        class Int16 < Integer
            size 2
        end

        class Int32 < Integer
            size 4
        end

        class Int64 < Integer
            size 8
        end
    end
end


                

