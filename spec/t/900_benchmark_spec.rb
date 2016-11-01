# 各種ページに大量のアクセスを行い、経過時間を評価するためのスクリプト
# ただし、計測は実時間を用い貯め、CPU時間、IO待ち時間を含んでしまうため参考程度とする

require 'uri'
require_relative '../rbase'
include Rbase

def do_sql (sql)
  values = `zenra mysql -s -e "#{sql}"`.lines.each {|l| l.chomp!}
  return values
end

describe 'ベンチマーク' , :js => true do

  LOAD = 5
  USERS = do_sql("select username from user")
  before_score = 0

  def access_user_page (num , url , param = '') 
    num.times do |i|
      USERS.each do |u|
        visit "#{url}/#{u}?#{param}"
        wait_for_ajax
      end
    end
  end

  def access (num , url)
    num.times do |i|
      visit url
      wait_for_ajax
    end
  end

  before do
    before_score = Time.now
  end

  after do
    after_score = Time.now - before_score
    puts sprintf('↓%.2f↓' , after_score.to_f)
  end

  describe 'ユーザ' do
    it '認証' do
      LOAD.times do |i|
        USERS.each { |u| login u }
      end
    end
    it 'マイページ' do
      access_user_page(LOAD , '/user/userpage') 
    end
    it '歌唱履歴' do
      access_user_page(LOAD , '/history/list') 
    end
    it '持ち歌一覧' do
      access_user_page(LOAD , '/user/songlist/sa2knight' , 'pagenum=120')
    end
  end

  describe 'カラオケ' do
    it '全てのカラオケ一覧' do
      (LOAD * USERS.count).times do
        visit '/karaoke/list'
      end
    end
    it 'あなたのカラオケ一覧' do
      access_user_page(LOAD , '/karaoke/user')
    end
    it '詳細画面' do
      karaoke_list = do_sql("select id from karaoke order by id desc limit #{LOAD}")
      karaoke_list.each do |k|
        visit "/karaoke/detail/#{k}"
        wait_for_ajax
      end
    end
  end
  describe '楽曲' do
    it '詳細画面' do
      login 'sa2knight'
      songs = do_sql("select song.id from song join history on history.song = song.id 
                      group by song.id order by count(song.id) desc limit #{LOAD * 10}")
      songs.each do |s|
        visit "/song/detail/#{s}"
        wait_for_ajax
      end
    end
    it '楽曲ランキング' do
      access(LOAD * 30 , "/ranking/song") 
    end
    it '得点ランキング' do
      score_types = do_sql('select id from score_type')
      (LOAD * 5).times do |i|
        score_types.each do |st|
          visit "/ranking/score/#{st}"
        end
      end
    end
    it 'タグ検索' do
      # 曲名/歌手名/ユーザ名に含まれていないか随時確認が必要
      login 'sa2knight'
      words = ['VOCALOID' , 'アニソン' , 'GUMI' , '鏡音リン' , '鏡音レン'] * LOAD
      words.each do |w|
        url = URI.escape("/search/tag/?tag=#{w}")
        visit url
      end
    end
    it '再生リスト' do
      login 'sa2knight'
      visit '/search/tag/?tag=VOCALOID'
      link '動画を連続再生する'
      (LOAD * 10).times do |i|
        link '順番をシャッフル'
        wait_for_ajax
      end
    end
  end
  describe 'アーティスト' do
    it '詳細画面' do
      login 'sa2knight'
      artists = do_sql("
        select artist.id from artist join song on artist.id = song.artist
        group by artist.id order by count(artist.id) desc limit #{LOAD * 10}")
      artists.each do |a|
        visit "/artist/#{a}"
      end
    end
    it 'アーティストランキング' do
      access(LOAD * 30 , "/ranking/artist")
    end
    it '一覧' do
      access(LOAD * 30 , "/artist")
    end
  end
  describe 'その他' do
    it '検索' do
      words = 'abcdefghijklmnopqrstuvwxyz'.split('') * LOAD
      words.each do |w|
        visit "/search/keyword?search_word=#{w}"
      end
    end
  end
end
