require_relative './march'
require_relative '../models/product'
require_relative '../models/score_type'
require_relative '../models/song'
require_relative '../models/artist'
require_relative '../models/karaoke'
require_relative '../models/history'
require_relative '../models/register'

class LocalRoute < March

  # success - 正常を通知するJSONを戻す
  #--------------------------------------------------------------------
  def success(data = nil)
    return Util.to_json({:result => 'success' , :info => data})
  end

  # error - 異常を通知するJSONを戻す
  #--------------------------------------------------------------------
  def error(info = '')
    return Util.to_json({:result => 'error' , :info => info})
  end

  # get '/ajax/karaoke/dialog - カラオケ入力画面を表示
  #---------------------------------------------------------------------
  get '/ajax/karaoke/dialog' do
    @products = Product.list
    @twitter = @current_user ? @current_user['has_twitter'] : nil
    erb :_input_karaoke
  end

  # get '/ajax/history/dialog - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/ajax/history/dialog' do
    @score_type = ScoreType.List
    @twitter = @current_user ? @current_user['has_twitter'] : nil
    erb :_input_history
  end

  # get '/ajax/song/dialog' - 楽曲新規登録の入力画面を表示
  #--------------------------------------------------------------------
  get '/ajax/song/dialog' do
    erb :_input_song
  end

  # post '/ajax/songlist' - 楽曲一覧を戻す
  #---------------------------------------------------------------------
  post '/ajax/songlist/?' do
    hash = Hash.new
    song_list = Song.list({:artist_info => true})
    song_list.each do |s|
      hash[s['song_name']] = s['artist_name']
    end
    return Util.to_json(hash)
  end

  # post '/ajax/song/tag/list' - 指定した楽曲のタグ一覧を戻す
  #--------------------------------------------------------------------
  post '/ajax/song/tag/list/?' do
    song = Song.new(params['song']) or return error('invalid song id')
    tags = song.tags or return error('fails get tags')
    return success(tags)
  end

  # post '/ajax/song/tally/monthly/count/?' - 指定した楽曲の月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/ajax/song/tally/monthly/count/?' do
    song = Song.new(params['id']) or return error('invalid song id')
    sang_histories = song.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # post '/ajax/artist/tally/monthly/count/?' - 指定したアーティストの月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/ajax/artist/tally/monthly/count/?' do
    artist = Artist.new(params['id']) or return error('invalid artist id')
    sang_histories = artist.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # post '/ajax/user/artist/favorite/?' - ログインユーザの主に歌うアーティスト１０組を戻す
  #--------------------------------------------------------------------
  post '/ajax/user/artist/favorite/?' do
    if params[:user]
      user = User.new(params[:user])
    else
      user = @current_user or return error('invalid user')
    end
    favorite_artists = user.favorite_artists(:limit => 10, :want_rate => true) or return error('no artists')
    return success(favorite_artists.map { |a| [a['artist_name'] , a['artist_count_rate']] })
  end

  # post '/ajax/song/tally/score/?' - 指定した楽曲、採点モードの採点集計を戻す
  #--------------------------------------------------------------------
  post '/ajax/song/tally/score/?' do
    song = Song.new(params[:song]) or return error('no song')
    score_type = params[:score_type].to_i or return error('no score type')
    user = @current_user ? @current_user.params['id'] : nil

    # ScoreTypeとScoreTypeNameの対応を取得
    score_type_name = ScoreType.id_to_name(score_type , :hash => true).values.join(' ')

    # みんなの得点集計を取得
    agg_score = song.tally_score(:score_type => score_type, :without_user => user)
    # 得点を小数点以下第二位で四捨五入
    agg_score.keys.each { |k| agg_score[k] and agg_score[k] = sprintf('%.2f' , agg_score[k]) }

    # あなたの得点集計を取得
    agg_myscore = {'score_max' => nil, 'score_min' => nil, 'score_avg' => nil}
    if user
      agg_myscore = song.tally_score(:score_type => score_type, :target_user => user)
      agg_myscore.keys.each { |k| agg_myscore[k] and agg_myscore[k] = sprintf('%.2f' , agg_myscore[k]) }
    end

    # グラフ生成用にデータを加工
    avg_data = {:name => '平均', :みんな => agg_score['score_avg'], :あなた => agg_myscore['score_avg']}
    max_data = {:name => '最高', :みんな => agg_score['score_max'], :あなた => agg_myscore['score_max']}
    min_data = {:name => '最低', :みんな => agg_score['score_min'], :あなた => agg_myscore['score_min']}

    # まとめてJSONで返却
    return success(:score_type_name => score_type_name, :scores => [min_data , avg_data , max_data])
  end

  # post '/ajax/storelist' - 店と店舗のリストをJSONで戻す
  #---------------------------------------------------------------------
  post '/ajax/storelist/?' do
    Util.to_json(Store.list)
  end

  # post '/ajax/attendance' - 参加情報をJSONで戻す
  #---------------------------------------------------------------------
  post '/ajax/attendance' do
    attendance = @current_user.get_attendance_at_karaoke(params[:id])
    
    return attendance ? Util.to_json(attendance) : error('get attendance failed')
  end
  
  # post '/ajax/karaokelist/?' - カラオケの一覧もしくは指定したカラオケを戻す
  #---------------------------------------------------------------------
  post '/ajax/karaokelist/?' do
    params[:id].nil? ? Util.to_json(Karaoke.list_all) : Util.to_json(Karaoke.new(params[:id]).params)
  end

  # post '/ajax/historylist/?' - 歌唱履歴の一覧もしくは指定した歌唱履歴を戻す
  #---------------------------------------------------------------------
  post '/ajax/historylist/?' do
    params[:id].nil? ? Util.to_json(History.recent_song) : Util.to_json(History.new(params[:id], true).params)
  end

  # post '/ajax/karaoke/delete/?' - カラオケを削除する
  #--------------------------------------------------------------------
  post '/ajax/karaoke/delete/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    result = karaoke.delete
    if result
      return success
    else
      return error('delete failed')
    end
  end

  # post '/ajax/karaoke/modify/?' - カラオケを編集する
  #--------------------------------------------------------------------
  post '/ajax/karaoke/modify/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    arg = Util.to_hash(params[:params])
    twitter = arg["twitter"]
    tweet_text = arg["tweet_text"]
    result = karaoke.modify(arg)
    result and twitter and @current_user and @current_user.tweet_karaoke(params[:id] , tweet_text)
    return result ? success : error('modify failed')
  end
  
  # post '/ajax/attendance/modify/?' - 参加情報を編集する
  #--------------------------------------------------------------------
  post '/ajax/attendance/modify/?' do
    attendance_info = @current_user.get_attendance_at_karaoke(params[:id])
    attendance_info or return error('not found attendance')

    attendance = Attendance.new(attendance_info['id'])
    arg = Util.to_hash(params[:params])
    result = attendance.modify(arg)
    
    return result ? success : error('modify failed')
  end

  # post '/ajax/song/modify/?' - 楽曲情報を編集する
  #--------------------------------------------------------------------
  post '/ajax/song/modify/?' do
    @current_user or return error('invalid user')
    song_id = params[:song_id]
    song_name = params[:song]
    artist_name = params[:artist]
    artist_id = Artist.name_to_id(artist_name , :create => 1)
    url = params[:url]
    song = Song.new(song_id)
    song or return error('no song')
    result = song.modify('name' => song_name, 'artist' => artist_id, 'url' => url)
    return result ? success : error('invalid params')
  end

  # post '/ajax/history/delete/?' - 歌唱履歴を削除する
  #--------------------------------------------------------------------
  post '/ajax/history/delete/?' do
    history = History.new(params[:id])
    history.params or return error('no record')
    history.delete
    return success
  end

  # post '/ajax/history/modify/?' - 歌唱履歴を編集する
  #--------------------------------------------------------------------
  post '/ajax/history/modify/?' do
    history = History.new(params[:id])
    history.params or return error('no record')
    arg = Util.to_hash(params[:params])
    twitter = arg['twitter']
    tweet_text = arg['tweet_text']
    result = history.modify(arg.dup)
    result and twitter and @current_user and @current_user.tweet_history(params[:id] , arg , tweet_text)
    return result ? success : error('modify failed')
  end

  # post '/ajax/attended/' - カラオケに参加済みか確認する
  #--------------------------------------------------------------------
  post '/ajax/attended' do
    attended = @current_user.get_attendance_at_karaoke params[:karaoke_id]
    return attended ? Util.to_json({:attended => true}) : Util.to_json({:attended => false})
  end

  # post '/ajax/karaoke/create' - カラオケ記録を登録する
  #---------------------------------------------------------------------
  post '/ajax/karaoke/create' do
    karaoke = {}
    karaoke['name'] = params[:name]
    karaoke['datetime'] = params[:datetime]
    karaoke['plan'] = params[:plan]
    karaoke['store'] = params[:store_name]
    karaoke['branch'] = params[:store_branch]
    karaoke['product'] = params['product'].to_i

    if @current_user
      result = @current_user.register_karaoke(karaoke)
     
      if result.kind_of?(Integer)
        params[:twitter] and @current_user.tweet_karaoke(result , params[:tweet_text])
        Util.to_json({'result' => 'success', 'karaoke_id' => result})
      else
        result
      end
    else
      Util.to_json({'result' => 'invalid current user'})
    end
  end

  # post '/ajax/attendance/create' - 参加情報を値段と感想は空のまま登録する
  #---------------------------------------------------------------------
  post '/ajax/attendance/create' do
    attendance = {}
    karaoke_id = params[:karaoke_id]

    if @current_user
      @current_user.register_attendance karaoke_id
      Util.to_json({'result' => 'success'})
    else
      Util.error('invalid current user')
    end
  end
  
  # post '/ajax/history/create - ユーザの歌唱履歴を登録
  #---------------------------------------------------------------------
  post '/ajax/history/create' do
    history = {}
    karaoke_id = params[:karaoke_id]
    history['song_name'] = params[:song_name]
    history['artist_name'] = params[:artist_name]
    history['songkey'] = params[:songkey]
    history['score'] = params[:score]
    history['score_type'] = params[:score_type].to_i
    twitter = params[:twitter]
    if @current_user
      info = @current_user.register_history(karaoke_id , history)
      twitter and @current_user.tweet_history(karaoke_id , history , params[:tweet_text])
      return success(info)
    else
      Util.to_json({'result' => 'invalid current user'})
    end
  end

  # post '/ajax/song/create/?' 楽曲を新規登録
  post '/ajax/song/create/?' do
    user = @current_user or return error('invalid current user')
    song = params[:song]
    artist = params[:artist]
    register = Register.new(user)
    artist_id = register.create_artist(artist)
    song_id = register.create_song(artist_id , artist , song)
    if artist_id && song_id
      return success(song_id)
    else
      return error('fails create song')
    end
  end

  # ppost '/ajax/artist/wiki' - 指定したアーティストのWikiページを取得
  #--------------------------------------------------------------------
  post '/ajax/artist/wiki' do
    artist = params[:artist]
    wiki = Util.get_wikipedia(artist)
    if wiki
      return success(:summary => wiki.summary, :url => wiki.fullurl)
    else
      return error('not found')
    end
  end

  # post '/ajax/key - 歌ったことがある楽曲ならば最近歌ったときのキーを返す
  #---------------------------------------------------------------------
  post '/ajax/key' do
    # テスト実行時は失敗を返す
    Util.run_mode == 'ci' and return error('never sang')
    @current_user or return error('never sang')

    song = Song.name_to_id(params[:name], params[:artist]) or return error('never sang')
    key = @current_user.search_songkey(song['song_id'])
    if key
      Util.to_json('result' => 'success' , 'songkey' => key)
    else
      error('never sang')
    end
  end

end
