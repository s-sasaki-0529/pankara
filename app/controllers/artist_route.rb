require_relative './march'

class ArtistRoute < March

  # get '/artist/:id' - 歌手情報を表示
  #---------------------------------------------------------------------
  get '/artist/:id' do
    @artist = Artist.new(params[:id])
    @artist.songs_with_count(@current_user.params['id'])
    erb :artist_detail
  end
  
end
