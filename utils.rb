module Utils

    ## return type (short, char, int etc) according to the length
    ## return the formatstring expected by pack/unpack
    def self.get_pack_type length
        case length
        when 1
            return "C"
        when 2
            return "S"
        when 3..4
            return "L"
        when 5..8
            return "Q"
        else
            return nil
        end
    end

    MAX_CHAR = 256
    MAX_SHORT = 65536
    MAX_INT = 4294967296
    
    ## Return the length needed to encode this integer
    ## in bytes
    def self.get_int_size int
        case int
        when 0...MAX_CHAR
            return 1
        when MAX_CHAR...MAX_SHORT
            return 2
        when MAX_SHORT...MAX_INT
            return 4
        else
            return 8
        end
    end 
end
