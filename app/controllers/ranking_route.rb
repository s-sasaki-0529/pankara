require_relative './march'
require_relative '../models/ranking'
require_relative '../models/score_type'

class RankingRoute < March

  # GETでshowmineが指定されている時、ログイン中ユーザを戻す
  #--------------------------------------------------------------------
  def target_user
    @showmine = params[:showmine] == 'true'
    @target_user = @showmine && @current_user ? @current_user : nil
    return @target_user
  end

  # get '/ranking/score/?' - 得点ランキングを表示
  #-------------------------------------------------------------------
  get '/score/?' do
    redirect '/ranking/score/1' #取り急ぎデフォルトはJOY全国採点
  end

  # get '/ranking/score/:score_type - 指定した採点モードの得点ランキングを表示
  #--------------------------------------------------------------------
  get '/score/:score_type' do
    @current_score_type = params[:score_type]
    param = {:score_type => @current_score_type , :user => target_user}
    @scores = Ranking.score(param)
    @score_type = ScoreType.id_to_name(@current_score_type , :hash => true)
    @score_type_list = ScoreType.List
    erb :score_ranking
  end

  # get '/ranking/song' - 楽曲の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/song' do
    @songs = Ranking.sang_count({:user => target_user})
    erb :song_ranking
  end

  # get '/ranking/artist' - 歌手別の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/artist' do
    @artists = Ranking.artist_sang_count({:user => target_user})
    erb :artist_ranking
  end

end
