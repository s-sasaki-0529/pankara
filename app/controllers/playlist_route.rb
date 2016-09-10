class PlaylistRoute < March
  get '/' do
    songs = params[:songs].split('_')
    @songs_json = Util.to_json(songs)
    erb :playlist
  end
end
