require 'socket'

# Broadcaster: reads from its own socket, sends to all clients
bcast_r, bcast_w = IO.pipe
clients = []
Thread.new do
  while line = bcast_r.gets
    puts "bcast: received #{line.inspect}, sending to clients"
    clients.each { |c| c.print line }
  end
end

# Acceptor: accepts connections, registers clients, spawns workers
acceptor = TCPServer.open 3333
while client = acceptor.accept
  puts "srv: accepted client"
  clients << client

  # Worker: reads from its client, writes to broadcaster
  fork do
    puts "wrk: forked"
    while line = client.gets
      puts "wrk: received #{line.inspect}, sending to bcast"
      bcast_w.print line
    end
  end
end
