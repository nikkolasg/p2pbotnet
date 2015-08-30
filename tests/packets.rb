require 'packets'
require 'type'
Packet::define :Push do
    field Type::IPAddress,:remote_ip
    field Type::UInt16,:remote_port
end

Packet::define :SSL do 
    field Type::UInt8,:version
end

Packet::define :String do
    field Type::String,:name
end

first = Packet::factory(Packet::String) do |packet|
    packet.name Type::String.new("Elou")
end
last = Packet::factory(Packet::String) do |packet|
    packet.name Type::String.new("Shka")
end

ssl = Packet::factory(Packet::SSL)
ssl.version Type::UInt8.new(3)
ssl.finalize!

push = Packet::factory(Packet::Push) 
push << ssl
push << first
push << last
push.remote_ip Type::IPAddress.new("10.0.0.15")
push.remote_port Type::UInt16.new(256)
push.finalize!
puts push.to_s
puts "###################### TO BINARY ######################"
bin = push.pack
puts bin
unpacked = Packet::parse bin
puts "######################## PARSING AGAIN ###############"
puts unpacked.to_s
idun = unpacked.children[1]
ideu = unpacked.children[2]
puts "ID : #{idun.name} #{ideu.name}"
