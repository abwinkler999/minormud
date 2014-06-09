require 'socket'
@all_threads = []
s = TCPServer.new(3939)
puts "*** STARTING UP ***"
while (conn = s.accept)
	Thread.new(conn) do |c|
		@all_threads << c
		c.print "What is your name? "
		thing = c.gets.chomp
		c.puts "Welcome, #{thing}!"
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
