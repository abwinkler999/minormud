require 'socket'
require 'term/ansicolor'
require 'pry'

class Connection
	attr_accessor :user, :socket
	def create_user(name)
		@user = User.new
		@user.name = name
	end
end

class User
	attr_accessor :name
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
	message = "#{originator.user.name}: #{message}"
	@all_sockets.each { |x| send(message, x)}
  end

  def sys_message(message)
	message = "#{@system.name}: #{message}"
	@all_sockets.each { |x| send(message, x)}
  end

  def bust_a_prompt(recipient)
  	recipient.socket.print "> "
  end

  def startup
    server = TCPServer.new(3939)
    puts "*** STARTING UP ***"
    while (conn = server.accept)
	    Thread.new(conn) do |c|
			puts "New connection detected."
			this_connection = Connection.new
			c.print "What is your name? "
			foo = c.gets.chomp!
			this_connection.create_user(foo)
			#this_connection.user.name = c.gets.chomp!
			this_connection.socket = c
			this_connection.socket.puts "Welcome, #{this_connection.user.name}!"
			bust_a_prompt(this_connection)
			@all_sockets << this_connection.socket
			loop do
				line = this_connection.socket.readline.chomp!
				if line.length == 0
					this_connection.socket.puts "Pardon?"
					bust_a_prompt(this_connection)
					next
				end
				puts "#{this_connection.user.name}: #{line}"
				if line.chomp == "logout"
					this_connection.socket.puts "Logging out."
					@all_sockets.delete this_connection.socket
					sys_message("#{this_connection.user.name} logged out.")
					this_connection.socket.close
				elsif line.chomp == "shutdown"
					sys_message("Shutting down NOW!")
					Thread.main.exit
				else
					broadcast(line, this_connection)
					bust_a_prompt(this_connection)
				end

			end
	    end
    end
  end
end

minormud = Mud.new
minormud.startup
