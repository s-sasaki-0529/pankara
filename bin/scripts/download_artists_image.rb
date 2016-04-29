require_relative "../../app/models/util"
DB.connect

artists = DB.new(:SELECT => 'id' , :FROM => 'artist').execute_columns
artists.each_with_index do |id , cnt|
  artist = Artist.new(id)
  artist.download_image
  puts "#{artist['name']} ダウンロード完了 (#{cnt + 1} / #{artists.size})"
end
