require_relative './march'

class ArtistRoute < March

  # get '/artist/:id' - 歌手情報を表示
  #---------------------------------------------------------------------
  get '/artist/:id' do
    user = @current_user ? @current_user.params['id'] : nil
    @artist = Artist.new(params[:id])
    @artist.songs_with_count(user)
    erb :artist_detail
  end
  
end
