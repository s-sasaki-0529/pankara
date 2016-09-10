require_relative '../models/song'

class PlaylistRoute < March
  get '/' do
    songs = params[:songs].split('_')
    @songs = Util.array_to_hash(Song.list(:songs => songs , :artist_info => true) , 'song_url')
    @songs_json = Util.to_json(@songs)
    erb :playlist
  end
end
