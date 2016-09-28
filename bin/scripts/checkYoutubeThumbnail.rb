# Songテーブル内のURLから、リンク切れを起こしている動画を抽出するスクリプト

require_relative '../../app/models/song'
require_relative '../../app/models/util'
require_relative '../../app/models/db'
require 'open-uri'

def is404?(url)
  Net::HTTP.get_response(URI.parse(url)).code == '404'
end

songs = DB.new(:FROM => 'song').execute_all
songs.each do |s|
  image_url = "http://i.ytimg.com/vi/#{s['url']}/mqdefault.jpg"
  if is404?(image_url)
    puts s['id']
  end
end

