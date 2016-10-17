=begin
----------------------------------------------------------------------------
createSampleKaraoke.rb - 実データを用いたkaraokeのサンプルを自動生成する

[実行方法] cdz && bundle exec ruby bin/scripts/createSampleKaraoke n m l
n: 生成するカラオケの個数
m: 各カラオケに参加するユーザ数
l: 各カラオケの一人あたりの歌唱数

=end

require_relative '../../app/models/register'
require_relative '../../app/models/user'

def get_karaoke_name
  now = Time.now.to_i
  return "自動生成カラオケ#{now}"
end

def get_plan
  Random.rand(1 .. 14).to_f / 2
end

def get_datetime
  month = Random.rand(1 .. 12)
  day = Random.rand(1 .. 28)
  hour = Random.rand(0 .. 23)
  min = Random.rand(0 .. 59)
  sec = Random.rand(0 .. 59)
  return "2016/%02d/%02d %02d:%02d:%03d"%[month,day,hour,min,sec]
end

def get_product
  [
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'},
    {'brand' => 'JOYSOUND' , 'product' => 'f1'},
    {'brand' => 'JOYSOUND' , 'product' => 'CROSSO'},
    {'brand' => 'JOYSOUND' , 'product' => 'WAVE'},
    {'brand' => 'DAM' , 'product' => 'Premire DAM'},
    {'brand' => 'DAM' , 'product' => 'LIVE DAM'},
    {'brand' => 'その他' , 'product' => 'その他'},
  ].sample
end

def get_store
  DB.new(
    :SELECT => ['name' , 'branch'],
    :FROM => 'store'
  ).execute_all.sample
end

def get_song(user)
  #histories = user.histories(:song_info => true)
  #history = histories.sample
  history = DB.new(
    :SELECT => {'song.name' => 'song_name' , 'artist.name' => 'artist_name'} ,
    :FROM => 'song',
    :JOIN => ['song' , 'artist'],
  ).execute_all.sample
  return {:song => history['song_name'] , :artist => history['artist_name']}
end

def get_score_type
  [
    {'brand' => 'JOYSOUND' , 'name' => '全国採点'} ,
    {'brand' => 'JOYSOUND' , 'name' => '分析採点'} ,
    {'brand' => 'JOYSOUND' , 'name' => 'その他'} ,
    {'brand' => 'DAM' , 'name' => 'ランキングバトル'} ,
    {'brand' => 'DAM' , 'name' => '精密採点'} ,
    {'brand' => 'DAM' , 'name' => 'その他'} ,
    {'brand' => 'その他' , 'name' => 'その他'} ,
  ].sample
end

def get_score
  rand(70000 .. 100000).to_f / 1000
end

def get_song_key
  Random.rand(-6 .. 6)
end

def get_price
  Random.rand(500 .. 2500)
end

def get_users(num)
  users = []
  usernames = DB.new(:SELECT => ['username'] , :FROM => 'user').execute_columns
  usernames.each do |un|
    users.push User.new(un)
  end
  return users
end

def create_karaoke(register)
  return register.create_karaoke(get_datetime , get_karaoke_name , get_plan , get_store , get_product)
end

KARAOKENUM = ARGV[0].to_i
USERNUM = ARGV[1].to_i
SANGNUM = ARGV[2].to_i

KARAOKENUM.times do

  users = get_users(USERNUM)
  registers = []
  registers[0] = Register.new(users[0])
  karaoke = create_karaoke(registers[0])
  registers[0].attend_karaoke(get_price)

  (USERNUM - 1).times do |i|
    registers[i + 1] = Register.new(users[i + 1])
    registers[i + 1].set_karaoke(karaoke)
    registers[i + 1].attend_karaoke(get_price)
  end

  SANGNUM.times do |i|
    registers.each_with_index do |r , s|
      h = get_song(users[s])
      r.create_history(h[:song] , h[:artist] , get_song_key , get_score_type , get_score)
    end
  end

end
