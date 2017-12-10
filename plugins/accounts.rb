class Accounts
  include Cinch::Plugin

  match /register (.+) (.+) (.+) (.+)/, method: :register, prefix: /^/
  match /login (.+) (.+) (.+)/, method: :login, prefix: /^/
  match /delete (.+) (.+)/, method: :delete, prefix: /^/

  def register(m, chan, user, pass, clazz)
    channel = chan.to_s[1..chan.to_s.length].downcase
    user.downcase!
    filename = "data/channels/#{channel}.yaml"
    unless File.exist?(filename)
      m.reply 'That channel isn\'t set up, yet!'
      return
    end
    data = false
    data = YAML.load_file(filename) while data == false
    userdataname = "data/channels/#{channel}/#{user}.yaml"
    if File.exist?(userdataname)
      m.reply 'A user with that account name already exists! Please sign in with `LOGIN #chan user pass`'
      return
    end
    userdata = false
    userdata = YAML.load_file('data/channels/users.example.yaml') while userdata == false
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    userdata['salt'] = (0...50).map { o[rand(o.length)] }.join
    userdata['name'] = user
    userdata['pass'] = Digest::SHA256.hexdigest("#{pass}#{userdata['salt']}")
    userdata['class'] = clazz
    data['count'] += 1
    File.open(filename, 'w') { |f| f.write data.to_yaml }
    File.open(userdataname, 'w') { |f| f.write userdata.to_yaml }
    m.reply "User #{user} set up in channel #{chan}, with the class name #{clazz}. Your passwords are not stored in plain text and are hashed with salt."
  end
end
