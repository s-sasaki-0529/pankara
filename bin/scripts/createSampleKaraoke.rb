require_relative '../../app/models/register'
require_relative '../../app/models/user'

def create_karaoke(register)
  print '日付時刻: '
  date_time = STDIN.gets().chomp
  print 'カラオケ名: '
  karaoke_name = STDIN.gets().chomp
  print 'カラオケ時間: '
  karaoke_plan = STDIN.gets().to_f
  print '店舗名(name): '
  store_name = STDIN.gets().chomp
  print '店舗名(branch): '
  store_branch = STDIN.gets().chomp
  print '機種名(brand): '
  product_brand = STDIN.gets().chomp
  print '機種名(product): '
  product_name = STDIN.gets().chomp
  return register.create_karaoke(date_time , karaoke_name , karaoke_plan , {'name' => store_name , 'branch' => store_branch} , {'brand' => product_brand , 'product' => product_name})
end

def get_song(user)
  histories = user.histories(:song_info => true)
  history = histories.sample
  return {:song => history['song_name'] , :artist => history['artist_name']}
end

print 'カラオケを登録するユーザ: '
users = []
registers = []
users[0] = User.new(STDIN.gets().chomp)
registers[0] = Register.new(users[0])
karaoke = create_karaoke(registers[0])
registers[0].attend_karaoke

print 'カラオケに参加させるユーザの数: '
usernum = STDIN.gets().to_i
usernum.times do |i|
  print '友達のユーザ名: '
  users[i + 1] = User.new(STDIN.gets().chomp)
  registers[i + 1] = Register.new(users[i + 1])
  registers[i + 1].set_karaoke(karaoke)
  registers[i + 1].attend_karaoke
end

print '登録する楽曲数(一人あたり)'
STDIN.gets().to_i.times do |i|
  registers.each_with_index do |r , s|
    h = get_song(users[s])
    r.create_history(h[:song] , h[:artist])
  end
end

