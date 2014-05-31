require 'tinder'

class StandupBot

  def initialize
    @start_time = Time.now
    @campfire = Tinder::Campfire.new 'twitter', :username => ENV['campfire_username'], :password => ENV['campfire_password']
    @team = ["Murat Soyupak","Charles Yang", "Taro Minowa", "Lizan Zhou", "Swapnil Jain", "Yoshikatsu Fujita", "Alexandru Ghise", "Heerad Farkhoor", "Victor Dong", "Bowen Zhang", "Peng Jiang", "Siddhant Ujjain", "Jenny Hylbert", "Manzurur Khan", "Shamit Patel", "Josh Yang", "Anthony Smith", "Robert Chang", "Tim Abraham", "Mihai Anca"].shuffle
    @room = @campfire.find_room_by_id(596947)
  end

  def do_standup
    @room.join
    @room.speak "Hello! We are starting GTE standup!"
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
        sleep(15)
        messages = @room.recent(:since_message_id => message_id , :limit => 100)
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

  def test
    
  end
end

StandupBot.new.do_standup
