# Songテーブルの全楽曲を対象に、URLをYoutubeのURLから動画IDのみに書き換える
# このスクリプトは本番環境では一度のみの利用を想定

require 'pp'
require_relative '../../app/models/db'

songs = DB.new(:SELECT => ['id' , 'url'] , :FROM => 'song').execute_all
songs.each do |s|
  song_id = s['id']
  url = s['url']
  tube = Util.youtube_to_id(url)
  DB.new(:UPDATE => ['song' , ['url']] , :WHERE => 'id = ?' , :SET => [tube , song_id]).execute
end
