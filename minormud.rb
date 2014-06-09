require 'socket'

class Mud
  def initialize
    @all_threads = Array.new
  end

  def broadcast(message)
    
  end

  def startup
    server = TCPServer.new(3939)
    puts "*** STARTING UP ***"
    while (conn = server.accept)
	    Thread.new(conn) do |c|
		puts "New connection detected."
		c.print "What is your name? "
		thing = c.gets.chomp!
		c.puts "Welcome, #{thing}!"
		@all_threads << c
		loop do
			line = c.readline.chomp!
			if line.chomp == "logout"
				c.puts "Logging out."
				c.close
			elsif line.chomp == "shutdown"
				c.puts "Shutting down NOW!"
				Thread.main.exit
			end
			@all_threads.each { |x| x.puts line }
		end
	    end
    end
  end
end

minormud = Mud.new
minormud.startup
