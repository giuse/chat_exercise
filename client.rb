require 'socket'

class ChatClient
  attr_reader :nickname, :conn, :debug

  def initialize nickname='Guest', server: 'localhost', port: 3333, debug: false
    @debug = debug
    @nickname = nickname
    puts "Connecting to server `#{server}:#{port}`#{"-- #{Process.pid}" if debug}"
    @conn = TCPSocket.open server, port
    introduction
    spawn_printer
    send_inputs
  end

private

  def introduction
    puts "Logging in as: `#{nickname}`"
    conn.puts nickname
  end

  def spawn_printer
    puts "Spawning printer" if debug
    Thread.new do
      puts "Printer spawned: #{Process.pid}" if debug
      while line = conn.gets
        puts "Received from server: #{line.inspect}" if debug
        print line unless line.start_with? nickname
      end
    end
  end

  def send_inputs
    puts "Client ready. Chat away :)"
    while line = STDIN.gets
      puts "Read line: #{line.inspect}" if debug
      conn.print line
      puts "Line sent to server" if debug
    end
  end

end


if __FILE__ == $0
  if debug = ARGV.first == 'debug'
    nick = rand(36**8).to_s(36)
  else
    nick = ARGV.first || 'Guest'
  end
  ChatClient.new nick, debug: debug
end
