require_relative './march'
require_relative '../models/ranking'
require_relative '../models/score_type'

class RankingRoute < March

  # GETでshowmineが指定されている時、ログイン中ユーザを戻す
  #--------------------------------------------------------------------
  def target_user
    @showmine = params[:showmine] == '1'
    @target_user = @showmine && @current_user ? @current_user : nil
    return @target_user
  end

  # get '/ranking/score - 得点ランキングを表示
  #--------------------------------------------------------------------
  get '/score' do
    @type = 'score'
    @current_score_type = params[:score_type] || 1
    param = {:score_type => @current_score_type , :user => target_user}
    @scores = Ranking.score(param)
    @score_type = ScoreType.id_to_name(@current_score_type , :hash => true)
    # brandで参照できる採点モード一覧
    @score_type_list = Hash.new {|h , k| h[k] = Array.new}
    ScoreType.List.each do |st|
      @score_type_list[st["brand"]].push(st)
    end
    erb :score_ranking
  end

  # get '/ranking/song' - 楽曲の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/song' do
    @type = 'song'
    @songs = Ranking.sang_count({
      :user => target_user ,
      :distinct => params[:distinct] && params[:distinct] == '1'
    })
    erb :song_ranking
  end

  # get '/ranking/artist' - 歌手別の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/artist' do
    @type = 'artist'
    @artists = Ranking.artist_sang_count({
      :user => target_user ,
      :distinct => params[:distinct] && params[:distinct] == '1'
    })
    erb :artist_ranking
  end

end
