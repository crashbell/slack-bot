require 'slack-ruby-client'
require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY'] # The "key" from step 1
  config.member_token = ENV['TRELLO_MEMBER_TOKEN'] # The token from step 3.
end

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self["name"]}' to the '#{client.team["name"]}' team at https://#{client.team["domain"]}.slack.com."
end

client.on :message do |data|
  client.typing channel: data["channel"]

  case data["text"]
    when 'hi' then
      client.message channel: data["channel"], text: "Hi <@#{data['user']}>!"
    when /thanks/ then
      client.message channel: data["channel"], text: "<@#{data['user']}> You're welcome!"
    when /thu 6/ then
      client.message channel: data["channel"], text: "thứ 6 hả? nhậu đêêê"
    when /thứ 6/ then
      client.message channel: data["channel"], text: "thứ 6 hả? nhậu đêêê"
    when /report/ then
      client.message channel: data["channel"], text: "mới #{Time.now.strftime("%H:%M")} mà report rồi sao?"
    when /bot/ then
      client.message channel: data["channel"], text: "Gì đó <@#{data['user']}>, muốn cái giề?"
    when /rello doing/ then
      board = Trello::Board.find(ENV["TRELLO_BOARD_ID"])
      doingList = board.lists.find {|l| l.name == "Doing"}
      client.message channel: data["channel"], text: "We have #{doingList.cards.length} cards in Doing list"
  end
end

client.on :close do |_data|
  puts 'Connection closed, exiting.'
  EM.stop
end

client.start!
