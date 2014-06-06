require 'tinder'
require 'yaml'
require 'net/smtp'

class StandupBot

  def initialize
    @start_time = Time.now
    @config = YAML.load_file("config.yml")
    @campfire = Tinder::Campfire.new @config['campfire_domain'], :username => @config['campfire_username'], :password => @config['campfire_password']
    @team = @config["team"].map{|person| person["name"]}.shuffle
    @room = @campfire.find_room_by_id(@config['campfire_room'])
  end

  def do_standup
    @room.join
    start_message = @room.speak "Hello! We are starting the GTE standup!"
    start_message_id = start_message.message.id
    @room.speak "Please have your standup notes ready"

    sleep(@config['first_pause'])

    remaining = @team.dup

    remaining.each{ |member| 
      if user_present?(member)
        @room.speak "#{member}: Go!"
        sleep(@config['speak_pause'])
      else
        @room.speak "#{member} missed the standup"
      end
    }

    messages = @room.recent(:since_message_id => start_message_id, :limit => 80)
    people_who_spoke = messages.select{|message| message[:user] != nil && (message.type == "TextMessage" || message.type = "PasteMessage")}.map{|m| m[:user][:name]}.uniq
    missing = @team - people_who_spoke

    @room.speak "We're done with the standup"
    missing_peeps = ""
    missing.each{ |m|
      missing_peeps = missing_peeps + ", " unless missing_peeps.empty?
      missing_peeps = missing_peeps + m
    }
    @room.speak "#{missing_peeps} missed the standup"
    
    send_email(missing_peeps) if @config['send_followup_email']
  end

  def send_email(missing_peeps)
    recipients = @config["team"].select{|person| missing_peeps.include?(person["name"])}.map{|person| person["email"]}
    email_config = @config['followup_email']
    smtp = Net::SMTP.new email_config['smtp_server'], email_config['smtp_port']
    smtp.enable_starttls
    email_account = email_config['account']
    reply_to = email_config['reply_to']
    recipients.each { |address|
      smtp.start(email_config['domain'], email_account, email_config['password'], :login) do 
        msg = <<END_OF_MESSAGE
From: #{email_account} <#{email_account}>
To: #{address} <#{address}>
Subject: Standup notes #{Time.now.strftime("%Y-%m-%d")}
Reply-To: #{reply_to} <#{reply_to}>

You missed the standup on Campfire. Please reply to this email with your notes
END_OF_MESSAGE

        smtp.send_message(msg, email_config['account'], address)
      end 
    }   
  end

  def user_present?(user)
    !@room.users.select{|u| u.name == user}.empty?
  end

end

StandupBot.new.do_standup
