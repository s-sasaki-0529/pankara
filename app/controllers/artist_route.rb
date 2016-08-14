require_relative './march'
require_relative '../models/artist'

class ArtistRoute < March

  # get '/artist/:id' - 歌手情報を表示
  #---------------------------------------------------------------------
  get '/artist/:id' do
    user = @current_user ? @current_user.params['id'] : nil
    @artist = Artist.new(params[:id])
    @artist.songs_with_count(user)
    @wiki = Util.get_wikipedia(@artist['name'])
    erb :artist_detail
  end

  # get '/artist_list' - 歌手一覧を表示
  #--------------------------------------------------------------------
  get '/artist_list' do
    @artistlist = Artist.list({:song_num => 1})
    erb :artist_list
  end
  
end
