Standup bot
==================

This is a script to automate standups over campfire.

The bot goes through a list of team members, pings them for status and mentions the missing members.

Setup:

1) Add campfire auth information into the config.yml file. It should look like this:

campfire_room: {room_number}
campfire_username: {your_username}
campfire_password: {your_password}
campfire_domain: {domain: i.e. domain.campfirenow.com}
team:
  - Team member #1
  - Team member #2
  
2) The script uses tinder gem. Install it by "gem install tinder"

3) run the script before the standup or setup a cron job to do it periodically
