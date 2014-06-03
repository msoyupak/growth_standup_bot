require 'tinder'
require 'yaml'

class StandupBot

  def initialize
    @start_time = Time.now
    @config = YAML.load_file("config.yml")
    @campfire = Tinder::Campfire.new 'twitter', :username => @config['campfire_username'], :password => @config['campfire_password']
    @team = @config["team"].shuffle
    @room = @campfire.find_room_by_id(@config['campfire_room'])
  end

  def do_standup
    @room.join
    start_message = @room.speak "Hello! We are starting the GTE standup!"
    start_message_id = start_message.message.id
    @room.speak "Please have your standup notes ready"

    sleep(10)

    remaining = @team.dup

    remaining.each{ |member| 
      if user_present?(member)
        @room.speak "#{member}: Go!"
        sleep(30)
      else
        @room.speak "#{member} missed the standup"
      end
    }

    messages = @room.recent(:since_message_id => start_message_id, :limit => 80)
    people_who_spoke = messages.select{|message| message.type == "TextMessage" || message.type = "PasteMessage"}.map{|m| m[:user][:name]}.uniq
    missing = @team - people_who_spoke

    @room.speak "We're done with the standup"
    missing_peeps = ""
    missing.each{ |m|
      missing_peeps = missing_peeps + ", " unless missing_peeps.empty?
      missing_peeps = missing_peeps + m
    }
    @room.speak "#{missing_peeps} please send your updates in email"
  end

  def user_present?(user)
    !@room.users.select{|u| u.name == user}.empty?
  end

end

StandupBot.new.do_standup
