require 'socket'
require 'term/ansicolor'

class User
	attr_accessor :name, :socket
end

class Mud
  def initialize
    @all_sockets = Array.new
    @color = Term::ANSIColor
    @system = User.new
    @system.name = "System"
  end

  def send(message, recipient)
  	communique = @color.bold, @color.green, message, @color.clear
  	recipient.puts communique.join
  end

  def broadcast(message, originator = nil)
   originator ||= @system
   message = "#{originator.name}: #{message}"
   @all_sockets.each { |x| send(message, x)}
  end

  def startup
    server = TCPServer.new(3939)
    puts "*** STARTING UP ***"
    while (conn = server.accept)
	    Thread.new(conn) do |c|
			puts "New connection detected."
			this_guy = User.new
			c.print "What is your name? "
			this_guy.name = c.gets.chomp!
			this_guy.socket = c
			this_guy.socket.puts "Welcome, #{this_guy.name}!"
			this_guy.socket.print "> "
			@all_sockets << this_guy.socket
			loop do
				line = this_guy.socket.readline.chomp!
				puts "#{this_guy.name}: #{line}"
				if line.chomp == "logout"
					this_guy.socket.puts "Logging out."
					@all_sockets.delete this_guy.socket
					broadcast("#{this_guy.name} logged out.")
					this_guy.socket.close
				elsif line.chomp == "shutdown"
					broadcast("Shutting down NOW!")
					Thread.main.exit
				else
					broadcast(line, this_guy)
					this_guy.socket.print "> "
				end

			end
	    end
    end
  end
end

minormud = Mud.new
minormud.startup
