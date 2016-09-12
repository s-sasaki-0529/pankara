require_relative '../models/song'

class PlaylistRoute < March
  get '/' do
    songs = params[:songs].split('_')
    songs_list = Song.list(:songs => songs , :artist_info => true , :sort => 'origin')
    params[:random] and songs_list.shuffle!
    @songs = Util.array_to_hash(songs_list , 'song_url')
    @songs_json = Util.to_json(@songs)
    erb :playlist
  end
end
