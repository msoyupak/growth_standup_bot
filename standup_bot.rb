require 'tinder'


class StandupBot

  def init

    @campfire = Tinder::Campfire.new 'twitter', :username => ENV['campfire_username'], :password => ENV['campfire_password']
    @team = ["Charles Yang", "Taro Minowa", "Lizan Zhou", "Swapnil Jain", "Yoshikatsu Fujita", "Alexandru Ghise", "Heerad Farkhoor", "Victor Dong", "Bowen Zhang", "Peng Jiang", "Siddhant Ujjain", "Jenny Hylbert", "Manzurur Khan", "Shamit Patel", "Josh Yang", "Anthony Smith", "Robert Chang", "Tim Abraham", "Mihai Anca"] 
    @growth_room = campfire.find_room_by_id(596947)
  end

  def do_standup
    team.shuffle.each{ |member|
      growth_room.speak "#{member}: Go!" if user_present?(member, growth_room)
    }
  end

  def user_present?(user, room)
    !room.users.select{|u| u.name == user}.empty?
  end
end
