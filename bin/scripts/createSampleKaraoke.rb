=begin
----------------------------------------------------------------------------
createSampleKaraoke.rb - 実データを用いたkaraokeのサンプルを自動生成する

[実行方法] cdz && bundle exec ruby bin/scripts/createSampleKaraoke

[入力例(キーボードから標準入力)]

カラオケを登録するユーザ: sa2knight
日付時刻: 2016/10/10 13:00:00
カラオケ名: テスト
カラオケ時間: 7
店舗名(name): カラオケ館
店舗名(branch): 亀戸店
機種名(brand): JOYSOUND
機種名(product): MAX
カラオケに参加させるユーザの数: 5
友達のユーザ名: hetare
友達のユーザ名: unagipai
友達のユーザ名: tomotin
友達のユーザ名: mya0ryuta
友達のユーザ名: worry
登録する楽曲数(一人あたり)15

[入力例(パイプを用いる場合)]

cdz && cat bin/scripts/createSampleKaraoke_dataSample | bundle exec ruby bin/scripts/createSampleKaraoke.rb 2>&1 > /dev/null

dataのサンプル

sa2knight
2016/10/10 13:00:00
テスト
7
カラオケ館
亀戸店
JOYSOUND
MAX
JOYSOUND
全国採点
5
hetare
unagipai
tomotin
mya0ryuta
worry
15

[実行結果]

上記の例の場合、６人(sa2knight,hetare,unagipai,tomotin,mya0ryuta,worry)が参加した
karaokeを生成し、karaokeに対し一人あたり１５曲の歌唱履歴を登録する。
その際に登録する楽曲は、そのユーザの持ち歌からランダムで選曲されるため、
より実データに近い結果を得ることができる

=end

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

print '登録する楽曲数(一人あたり): '
STDIN.gets().to_i.times do |i|
  registers.each_with_index do |r , s|
    h = get_song(users[s])
    r.create_history(h[:song] , h[:artist] , 0 , get_score_type , get_score)
  end
end

