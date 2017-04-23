require 'socket'

class ChatServer
  attr_reader :server, :clients, :to_bcast, :debug

  def initialize port=3333, debug: false
    @debug = debug
    puts "Starting server on port `#{port}`#{"-- #{Process.pid}" if debug}"
    @server = TCPServer.open port
    @clients = []
    puts "Server ready" if debug
    trap "SIGINT", proc { shutdown }  # ctrl+c to exit
    spawn_broadcaster
    run_acceptor
  end

private

  def spawn_broadcaster
    puts "Spawning broadcaster" if debug
    from_clients, @to_bcast = IO.pipe
    Thread.new do
      puts "BCAST: spawned: #{Process.pid}" if debug
      while line = from_clients.gets
        puts "BCAST: Received line from client: #{line.inspect}" if debug
        clients.each { |nick, conn| conn.print line }
        puts "BCAST: Line sent to #{clients.size} clients" if debug
      end
    end
  end

  def run_acceptor
    puts "Starting acceptor loop" if debug
    while conn = server.accept do
      puts "ACC: new connection: #{conn.inspect}" if debug
      nick = conn.gets.chomp
      puts "ACC: nickname: #{nick}" if debug
      clients << [nick, conn]
      puts "ACC: updated clients list: #{clients}" if debug
      fork_worker nick, conn
    end
  end

  def fork_worker nick, conn
    puts "Forking worker" if debug
    fork do
      puts "WOR: forked with pid #{Process.pid}" if debug
      while line = conn.gets
        puts "WOR #{Process.pid}: received line from client: #{line.inspect}" if debug
        to_bcast.print "#{nick}: #{line}"
        puts "WOR #{Process.pid}: line added to broadcaster pipe" if debug
      end
    end
  end

  def shutdown
    puts "Shutting down workers..." if debug
    Thread.list.each do |thread|
      thread.exit unless thread == Thread.current
    end
    puts "\nServer shut down"
    exit 0
  end

end


if __FILE__ == $0
  puts "ChatServer starting..."
  ChatServer.new debug: ARGV.first == 'debug'
end
