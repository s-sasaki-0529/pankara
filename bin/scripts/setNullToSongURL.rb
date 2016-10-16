# Songテーブル内のURLから、リンク切れを起こしているURLにNULLを設定する

require_relative '../../app/models/song'
require_relative '../../app/models/util'
require_relative '../../app/models/db'
require 'open-uri'

def is404?(url)
  Net::HTTP.get_response(URI.parse(url)).code == '404'
end

songs = DB.new(:FROM => 'song').execute_all
dead_links = []
songs.each do |s|
  image_url = "http://i.ytimg.com/vi/#{s['url']}/mqdefault.jpg"
  if is404?(image_url)
    dead_links.push(s['id'])
  end
end

dead_links.empty? or DB.new(
  :UPDATE => ['song' , ['url']],
  :WHERE_IN => ['id' , dead_links.count],
  :SET => [nil].concat(dead_links)
).execute

