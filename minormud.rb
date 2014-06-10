require 'socket'
require 'term/ansicolor'
require 'pry'

class Player
	attr_accessor :character, :socket

	def create_character(name)
		@character = Character.new
		@character.name = name
	end
end

class Character
	attr_accessor :name
end

class Mud
  def initialize
    @all_players = Array.new
    @color = Term::ANSIColor
    @system = Character.new
    @system.name = "System"
  end

  def send(message, recipient)
  	communique = @color.bold, @color.green, message, @color.clear
  	recipient.socket.puts communique.join
  end

  def broadcast(message, originator = nil)
	originator ||= @system
	message = "#{originator.character.name}: #{message}"
	@all_players.each { |x| send(message, x)}
  end

  def sys_message(message)
	message = "#{@system.name}: #{message}"
	@all_players.each { |x| send(message, x)}
  end

  def bust_a_prompt(recipient)
  	recipient.socket.print "> "
  end

  def shut_down_socket(target)
  	target.socket.puts "Logging out."
  	@all_players.delete target
  	sys_message("#{target.character.name} logged out.")
  	target.socket.close
  end

  def parse(this_player)
  	line = this_player.socket.readline.chomp!
	if line.length == 0
		this_player.socket.puts "Pardon?"
		bust_a_prompt(this_player)
		return
	end
	puts "#{this_player.character.name}: #{line}"
	case line
		when "look"
			send("You are in a little, uninteresting room.\n", this_player)
			@all_players.each { |x| send("#{x.character.name} is here.", this_player) }
			bust_a_prompt(this_player)
		when "logout"
			shut_down_socket(this_player)
		when "shutdown"
			sys_message("Shutting down NOW!")
			Thread.main.exit
		else
			broadcast(line, this_player)
			bust_a_prompt(this_player)
	end
  end

  def startup
    server = TCPServer.new(3939)
    puts "*** STARTING UP ***"
    while (conn = server.accept)
	    Thread.new(conn) do |c|
			puts "New connection detected."
			this_player = Player.new
			c.print "What is your name? "
			foo = c.gets.chomp!
			this_player.create_character(foo)
			this_player.socket = c
			this_player.socket.puts "Welcome, #{this_player.character.name}!"
			sys_message("#{this_player.character.name} has connected.")
			bust_a_prompt(this_player)
			@all_players << this_player
			loop do
				parse(this_player)
			end
	    end
    end
  end
end

minormud = Mud.new
minormud.startup
