require_relative './march'
require_relative '../models/artist'

class ArtistRoute < March

  # get '/artist' - 歌手一覧を表示
  #--------------------------------------------------------------------
  get '/' do
    @artistlist = Artist.list({:song_num => 1})
    erb :artist_list
  end

  # get '/artist/:id' - 歌手情報を表示
  #---------------------------------------------------------------------
  get '/:id' do
    user = @current_user ? @current_user.params['id'] : nil
    @artist = Artist.new(params[:id])
    @artist.songs_with_count(:user => user , :sort => 'sang_count')
    @sang_all = @artist['songs'].inject(0) {|sum , s| sum + s['sang_count']}
    user and @sang_user = @artist['songs'].inject(0) {|sum , s| sum + s['sang_count_as_user']}

    # 円グラフ用のデータを作成
    songs_chart = @artist['songs'].clone
    if user
      songs_chart = songs_chart.map { |s| [ [s['song_name']] , [s['sang_count'] + s['sang_count_as_user']] ] } 
    else
      songs_chart = songs_chart.map { |s| [ [s['song_name']] , [s['sang_count']] ] } 
    end
    songs_chart.sort! { |a,b| b[1][0] <=> a[1][0] }
    # 楽曲が9曲以上ある場合、その他で括る
    if songs_chart.count >= 9
      another = 0
      songs_chart[8..-1].each { |s| another += s[1][0] }
      songs_chart = songs_chart[0..7]
      songs_chart.push ['その他' , another]
    end
    @songs_chart_json = Util.to_json(songs_chart)
    erb :artist_detail
  end
  
end
