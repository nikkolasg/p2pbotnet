require 'log'
require 'utils'

module Packet

    ##
    ### For parsing packet
    # header = Packet::Header.parse data
    # p = Packet::from_header header
    # p.payload << Packet::parse(data[...])
    # p.payload << "raw string"
    #
    # or p = Packet::from_header header do |payload|
    #   payload << Packet::Parse(data[...])
    #   payload << "network raw string"
    # end ==> Analyze the payload validity here !!
    #
    ### For creating packet
    # Packet::factory(Packet::LNI) << Packet::factory(Packet::GUID) << "a raw strin"
    # Packet::factory(Packet::LNI) do |payload|
    # p = Packet::LNI.new do |packet|
    #   packet << Packet::GUID.new { |p| p << "GUID-GUID-GUID-GUID" }
    #   packet << "a raw string"
    # end ==> analyze the payload validity here !!
    #         
    #
    ## DSL for creating new kind of packet
    ## Packet::define :Router do 
    #       field Type::Timestamp,:timestamp
    #       field Type::IP,:router_ip
    #       ## String type must be alone or at the end since the size is unknown
    #       field Type::String,:router_name
    #  end
    #       
    #  
    
    ## shortcut to directly access classes inside this module
    ## instead of iterating over every dynamic classes
    @@classes = []



    ## #########################################################
    #
    #       DSL for new kinf of packet
    #
    ## ######################################################### 
    ## Module implementing the DSL for creating new kind of packets
    module PacketClassMethods

        def field type,name
            define_method name do |arg = nil| 
                ## setter
                if arg 
                    ## valid type
                    if  arg.kind_of?(type)
                        instance_variable_set("@#{name}_",arg)
                    else
                        ##Logging ;)
                    end
                else
                    instance_variable_get("@#{name}_",arg)
                end
            end
        end
    end

    
    ## First-level keyword for creating new kind of packet
    def self.define name,&block
        packet_class = Class.new(Object) do
            extend PacketClassMethods
            include PacketInstanceMethods
            class_eval &block
        end
        Packet::const_set(name,packet_class)
        ## shortcut for directly access classes in this module
        @@classes << packet_class
        packet_class
    end
              
    ## ########################################################
    #
    #   Creation of packet
    #
    ## ######################################################## 

    def factory type
        type = type.to_sym if type.is_a?(String)
        klass = type.is_a?(Symbol) ? Packet::const_get(type) : type
        raise Exceptions::Packet::WrongName,"Unknown name #{klass} given to packet factory " unless @@classes.include? klass
        ## create packet and yield it
        packet = klass.new
        yield packet
        ## construct the header and return
        packet.finalize!
        packet
    end
        
       
    module PacketInstanceMethods
        
       ## Add a payload to this packet 
       def << payload

       end 
       
       ## It will create the appropriate header    
       def finalize!

       end

       ## Return a byte-stream as a string
       def pack

       end

    end
    ############################################
    #
    #   PARSING
    #
    ###########################################      
    ##
    ## Parse a binary data into a well define packet
    ##
    def self.parse data
        header = Packet::Header::parse data
        bRead = header.size
        ## parse children
        while header.coumpound
            begin
                child = parse data[header.size..-1] 
            rescue PacketError => e
                ## LOGGING
                $log.warn e 
                bRead += 1
                break;
            end
            add_children child
            bRead += child.size
            ## no payload for root packet 
            break if bRead == header.pLength
        end

        ## Read payload
        payload = bRead < data.length ? data[bRead..-1] : nil
        Packet::create header,payload
    end

    ## Actually creates the packet 
    def self.from_header header
        name = header.name
        if name.is_a?(String)
            name = name.capitalize.to_sym
        end

        packet = Packet::const_get(name)

        (raise Exceptions::Packet::WrongName,"Unknown name : #{name}") unless packet
        $log.debug "Packet Created : #{name} (#{packet.children.size} children)"
        packet.new header
    end
end
