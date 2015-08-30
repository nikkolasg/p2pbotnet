require 'log'
require 'utils'
require 'exceptions'
require 'header'

module Packet

    ##
    ### For parsing packet
    ## p = Packet::parse data
    ### For creating packet
    # Packet::factory(Packet::LNI) << Packet::factory(Packet::GUID) << "a raw strin"
    # Packet::factory(Packet::LNI) do |payload|
    # p = Packet::LNI.new do |packet|
    #   packet Packet::GUID.new { |p| p << "GUID-GUID-GUID-GUID" }
    #   packet Packet::Firewall
    #   name "a raw string".to_ps
    # end ==> analyze the payload validity here !!
    #         
    #
    ## DSL for creating new kind of packet
    ## Packet::define :Router do 
    #       field Type::Timestamp,:timestamp,otional: true
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
    #       DSL for new kind of packet
    #
    ## ######################################################### 
    ## Module implementing the DSL for creating new kind of packets
    module PacketClassMethods

        def field type,name, opts = {}
            name = name.to_sym if name.is_a?(String)
            ## create new instance method based on the name and type
            define_method name do |arg = nil| 
            ## setter
            if arg 
                ## valid type
                if  arg.is_a?(type)
                    instance_variable_set("@#{name}_",arg)
                else
                    ##Logging ;)
                    $log.warn "Wrong type given (#{arg.class} instead of #{type.to_s}) for field #{name})"
                end
            else ## getter
                instance_variable_get("@#{name}_")
            end
            end
            ## then register this method with the assiocated type
            fields << [name,type,opts]
        end
    end


    ## First-level keyword for creating new kind of packet
    def self.define name,&block
        name = name.to_sym if name.is_a?(String)
        packet_class = Class.new(Object) do
            ## create class accessor for dynamic fields and the name of the packet
            class << self
                attr_accessor :fields
                attr_accessor :name
            end
            @fields = []
            @name = name

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

    def self.factory type
        type = type.to_sym if type.is_a?(String)
        klass = type.is_a?(Symbol) ? Packet::const_get(type) : type
        raise Exceptions::Packet::WrongName,"Unknown name #{klass} given to packet factory " unless klass.is_a?(Class) && @@classes.include?(klass)

        ## create packet and yield it
        packet = klass.new
        if block_given?
            yield packet
            packet.finalize!
        end
        ## construct the header and return
        packet
    end


    module PacketInstanceMethods

        attr_accessor :header, :children

        def initialize
            @children = []
        end 

        ## Add a packet to the children packet list
        def << packet
            @children << packet
        end

        alias :add_child :<<

        ## it will verify the payload of the packet if its 
        ## missing something or not
        def valid?
            ## check type of fields
            self.class.fields.each do |name,type,opts|
                ## by default every fields are mandatory
                next if opts.fetch(:optional,'false')
                val = self.send name
                unless val.kind_of?(type)
                    raise Exceptions::Packet::Malformed,"Field #{name} has been given a value of wrong type (#{val.class} instead of #{type})"
                end
            end
            ## check length
            header.pLength == (children_size + fields_size)
        end

        ## It will create the appropriate header    
        def finalize!
            @header = Packet::Header.from_packet self 
            valid?
        end

        ## return the name of the packet
        def name
            @header.name || "None header ><"
        end

        ## Return a byte-stream as a string
        def pack
            str = header.pack  ## pack header
            ## pack children packets
            str = @children.reduce(str) { |col,packet| col += packet.pack }
            ## pack packet fields
            self.class.fields.reduce(str) do |col,(name,type,opts)|
                val = self.send name
                col += val.pack if val
                col
            end
        end


        ## Parse the data into its payload fields (i.e. ip address, name etc)
        def parse_payload data
            read = 0
            self.class.fields.each do |name,type,opts|
                ## we may not know the length in advance. 
                # In this case, it should be the last field on the payload
                # and we take everything
                endpoint = type.size || -1   
                val = type.unpack data[read...(read + endpoint)]
                unless val.nil?
                    send name,val
                    read += val.size
                end
            end
        end

        ## Return the size of this packet in total
        def size
            header_size + children_size + fields_size 
        end

        def header_size
            header.size
        end

        def children_size
            @children_size ||= @children.reduce(0){ |col,packet| col += packet.size}
        end

        ## return size for the fields of this packet
        def fields_size
            @fields_size ||= self.class.fields.reduce(0) do |col,(name,type,opts)|
                val = self.send name
                ## only take fields defined
                col += val.size unless val.nil?
                col
            end
        end

        ## packet information
        def to_s
            str = "Packet #{self.class.name} :\n"
            str += "\t- header #{@header.to_s}\n"
            str += "\t- children size = #{children_size}\n"
            str += "\t- fields size = #{fields_size}\n"
            str += "\t- fields : \n"
            self.class.fields.each do |name,type,opts|
                val = self.send name
                str += "\t\t#{name} : #{val}\n"
            end
            children = @children.map { |c| "\t" + c.to_s.gsub("\n","\n\t") }.join("\n")
            str += "\t- Children (#{@children.size}) :\n"
            str += children
            str
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
        root = Packet::from_header header
        ## parse children
        while header.coumpound
            begin
                child = parse data[bRead..(header.size + header.pLength)] 
            rescue Exceptions::Packet::PacketError => e
                ## LOGGING
                $log.warn e 
                bRead += 1
                break;
            end
            root << child
            bRead += child.size
            ## no payload for root packet 
            break if bRead == header.pLength
        end

        ## Read payload
        if bRead < data.length 
            root.parse_payload  data[bRead..(header.size + header.pLength)] 
        end

        root
    end

    ## Actually creates the packet from given header
    def self.from_header header
        name = header.name
        if name.is_a?(String)
            name = name.to_sym
        end

        packet = Packet::const_get(name)

        (raise Exceptions::Packet::WrongName,"Unknown name : #{name}") unless packet
        ipacket = packet.new
        ipacket.header = header
        $log.debug "Packet Created from header : name = #{ipacket.name}"
        ipacket
    end
end
