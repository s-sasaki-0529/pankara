# Songテーブル内のURLから、リンク切れを起こしているURLを更新する
require_relative '../../app/models/song'
require_relative '../../app/models/util'
require_relative '../../app/models/db'
require 'open-uri'

def is404?(url)
end

# 全ての楽曲に対して、youtubeページにアクセスし、「申し訳ありません。」の有無を検証する
songs = DB.new(:FROM => 'song').execute_all
dead_links = []
songs.each do |s|
  image_url = "https://www.youtube.com/watch?v=#{s['url']}"
  response = Net::HTTP.get_response(URI.parse(image_url))
  if response.code == '404' || response.body.force_encoding("UTF-8").include?('申し訳ありません。')
    dead_links.push(s['id'])
  end
end

# 404だった楽曲について、URLにNULLをセットする
dead_links.empty? or DB.new(
  :UPDATE => ['song' , ['url']],
  :WHERE_IN => ['id' , dead_links.count],
  :SET => [nil].concat(dead_links)
).execute

# URLがNULLの楽曲に対してYoutubeから再度URLを設定し、DBを更新する
null_songs = DB.new(:SELECT => ['id'], :FROM => 'song', :WHERE => 'url is NULL').execute_columns
null_songs.each do |s_id|
  song = Song.new(s_id)
  url = Util.search_tube(song['name'], song['artist_name'])
  url and DB.new(:UPDATE => ['song', ['url']], :WHERE => 'id = ?', :SET => [url, s_id]).execute
  puts "#{song['name']}(#{song['artist_name']}のURLを更新: #{url})"
end
