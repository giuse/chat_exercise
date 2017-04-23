require 'socket'

conn = TCPSocket.open 'localhost', 3333
nick = ARGV.first || 'Guest'

# Print everything coming from server (async)
Thread.new do
  while line = conn.gets
    puts "Received line: #{line.inspect}"
  end
end

# Send anything we type to server
while line = STDIN.gets
  puts "Read #{line.inspect} from stdin, sending"
  conn.print line
end
