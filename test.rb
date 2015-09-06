
module ClassMethod
    def field name, type
        metho = define_method name.to_sym do |arg = nil|
            if arg 
                instance_variable_set("@#{name}_",arg)
            else
                instance_variable_get("@#{name}_")
            end
        end
        dmethods << metho
        fields << name
    end

end
module AllClasses
    
end
module InstanceMethod
    attr_accessor :header
    def list_dynamic_fields 
        puts "Dynamic fields listing   #{self.class}: "
        self.class.fields.each do |f|
            puts "Field : #{f}"
        end
    end

    def size val = nil
        self.class.size val
    end
end
def define name,&block
    c = Class.new(Object) do 
        class << self
            attr_accessor :fields, :dmethods
        end
        @fields = []
        @dmethods = []
        extend ClassMethod
        include InstanceMethod
        class_eval &block
    end
    AllClasses::const_set(name,c)
    c
end

c = define :Pricing do
    field "price","string"
end
instance = AllClasses::Pricing.new
puts AllClasses::Pricing.dmethods.first.inspect

class Fixnum
    prepend InstanceMethod
    def self.size val = nil
        2 
    end

end

i = 5
puts "i = #{i}, size = #{i.size} class size = #{i.class.size}"

