class Main
  include Cinch::Plugin

  match /setup/, method: :setup

  def setup(m)
    m.reply 'Setting up the channel for IdleRPG'
    begin
      m.channel.voice CONFIG['nickname']
    rescue
      m.reply 'I do not have permission to voice users! Aborting!'
      return
    end
    channel = m.channel.to_s[1..m.channel.to_s.length]
    filename = "data/channels/#{channel}.yaml"
    unless File.exist?(filename)
      File.new(filename, 'w+')
      exconfig = YAML.load_file('data/channels/channel.example.yaml')
      File.open(filename, 'w') { |f| f.write exconfig.to_yaml }
      Dir.mkdir("data/channels/#{channel}")
    end
    data = YAML.load_file(filename)
    data['name'] = channel
    data['ownerhost'] = m.user.host
    data['users'] = 0
    File.open(filename, 'w') { |f| f.write data.to_yaml }
    m.reply "Channel ready! Run `/msg #{CONFIG['nickname']} register #{m.channel.name} [username] [password] [classname]`"
  end
end
