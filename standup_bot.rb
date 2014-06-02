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
    @room.speak "Hello! We are starting the GTE standup!"
    @room.speak "Please have your standup notes ready"

    sleep(10)

    remaining = @team.dup
    talked = []
    missing = []

    while (missing.count + talked.count) < @team.count && Time.now - @start_time < 15 * 60 do
      member = remaining.sample

      if !user_present?(member)
        missing << member
        remaining.delete(member)
        @room.speak "#{member} is missing"

      else
        message_id = @room.speak "#{member}: Go!"
        sleep(30)
        messages = @room.recent(:since_message_id => message_id , :limit => 20)
        people_who_spoke = messages.select{|m| m.type == "TextMessage"}.map{|m| m[:user][:name]}.uniq

        if people_who_spoke.include?(member)
          talked << member
        else
          missing << member
        end

        remaining.delete(member)
      end
    end

    @room.speak "We're done with standup"
    missing_peeps = ""
    missing.each{ |m| 
      missing_peeps = missing_peeps + ", " unless missing_peeps == "" 
      missing_peeps = missing_peeps + m
    }

    @room.speak "#{missing_peeps} please send your updates in email"

  end

  def user_present?(user)
    !@room.users.select{|u| u.name == user}.empty?
  end

end

StandupBot.new.do_standup
