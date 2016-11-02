require_relative './march'
require_relative '../models/product'
require_relative '../models/score_type'
require_relative '../models/song'
require_relative '../models/artist'
require_relative '../models/karaoke'
require_relative '../models/history'
require_relative '../models/register'
require_relative '../models/attendance'

class AjaxRoute < March

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

  # get '/ajax/dialog/karaoke - カラオケ入力画面を表示
  #---------------------------------------------------------------------
  get '/dialog/karaoke' do
    @products = Product.list
    @twitter = @current_user ? @current_user['twitter_info'] : nil
    erb :_input_karaoke
  end

  # get '/ajax/dialog/history - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/dialog/history' do
    @score_type = ScoreType.List
    @twitter = @current_user ? @current_user['twitter_info'] : nil
    erb :_input_history
  end

  # post '/ajax/song/create/?' 楽曲を新規登録
  #---------------------------------------------------------------------
  post '/song/create/?' do
    user = @current_user or return error('invalid current user')
    song = params[:song]
    artist = params[:artist]
    # 歌手名 / 曲名は必須
    if song.nil? || song == ''
      return error('曲名を入力してください')
    elsif artist.nil? || artist == ''
      return error('歌手名を入力してください')
    end
    register = Register.new(user)
    artist_id = register.create_artist(artist)
    song_id = register.create_song(artist_id , artist , song)
    if artist_id && song_id
      return success(song_id)
    else
      return error('fails create song')
    end
  end


  # get '/ajax/song/dialog' - 楽曲新規登録の入力画面を表示
  #--------------------------------------------------------------------
  get '/dialog/song' do
    erb :_input_song
  end

  # post '/ajax/song/list/names' - 全ての楽曲を取得し、曲名→歌手名のハッシュをJSONで戻す
  #---------------------------------------------------------------------
  post '/song/list/names' do
    hash = Hash.new
    song_list = Song.list({:artist_info => true})
    song_list.each do |s|
      hash[s['song_name']] = s['artist_name']
    end
    return success(hash)
  end

  # post '/ajax/song/list/details' - SongIDのリストをPOSTすると、該当する楽曲情報のリストを戻す
  #--------------------------------------------------------------------
  post '/song/list/details' do
    songs = params[:songs]
    (songs && songs.size > 0) or return error('invalid songs')
    songs_info = Song.list(:songs => songs)
    (songs_info && songs_info.size > 0) or return error('failed get songs info')
    return success(songs_info)
  end

  # post '/ajax/song/modify/?' - 楽曲情報を編集する
  #--------------------------------------------------------------------
  post '/song/modify/?' do
    @current_user or return error('invalid user')
    song_id = params[:song_id]
    song_name = params[:song]
    artist_name = params[:artist]
    song_name == "" and return error('曲名を入力してください')
    artist_name == "" and return error('歌手名を入力してください')
    artist_id = Artist.name_to_id(artist_name , :create => 1)
    url = params[:url]
    song = Song.new(song_id)
    song or return error('no song')
    result = song.modify('name' => song_name, 'artist' => artist_id, 'url' => url)
    return result ? success : error('invalid params')
  end

  # post '/ajax/song/tag/list' - 指定した楽曲のタグ一覧を戻す
  #--------------------------------------------------------------------
  post '/song/tag/list/?' do
    song = Song.new(params['song']) or return error('invalid song id')
    tags = song.tags or return error('fails get tags')
    return success(tags)
  end

  # post '/ajax/song/tally/monthly/count/?' - 指定した楽曲の月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/song/tally/monthly/count/?' do
    song = Song.new(params['id']) or return error('invalid song id')
    sang_histories = song.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # post '/ajax/song/tally/score/?' - 指定した楽曲、採点モードの採点集計を戻す
  #--------------------------------------------------------------------
  post '/song/tally/score/?' do
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

  # post '/ajax/artist/tally/monthly/count/?' - 指定したアーティストの月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/artist/tally/monthly/count/?' do
    artist = Artist.new(params['id']) or return error('invalid artist id')
    sang_histories = artist.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # ppost '/ajax/artist/wiki' - 指定したアーティストのWikiページを取得
  #--------------------------------------------------------------------
  post '/artist/wiki' do
    artist = params[:artist]
    wiki = Util.get_wikipedia(artist)
    if wiki
      begin
        return success(:summary => wiki.summary, :url => wiki.fullurl)
      rescue
        wiki = Util.get_wikipedia(wiki.links[0])
        return success(:summary => wiki.summary, :url => wiki.fullurl)
      end
    else
      return error('not found')
    end
  end

  # post '/ajax/user/karaoke/recent/?' - ユーザの参加するカラオケの中で最も新しいものを取得
  #--------------------------------------------------------------------
  post '/user/karaoke/recent/?' do
    @current_user or return error('ログインしてください')
    attends = @current_user.attend_ids(:want_karaoke => true)
    attends.empty? and return error('参加しているカラオケがありません')
    karaoke = Karaoke.new(attends[-1]['karaoke'])
    return success(:id => karaoke['id'] , :name => karaoke['name'])
  end

  # post '/ajax/user/karaoke/attended' - カラオケに参加済みか確認する
  #--------------------------------------------------------------------
  post '/user/karaoke/attended' do
    attended = @current_user.get_attendance_at_karaoke params[:karaoke_id]
    result = attended ? {:attended => true} : {:attended => false}
    return success(result)
  end

  # post '/ajax/user/aggregate/?' - 指定したユーザの集計情報
  #--------------------------------------------------------------------
  get '/user/:user/aggregate/dialog' do
    user = User.new(params[:user])
    user or return error('invalid user id')
    @agg = user.aggregate
    erb :_aggregate
  end

  # post '/ajax/user/artist/favorite/?' - ログインユーザの主に歌うアーティスト１０組を戻す
  #--------------------------------------------------------------------
  post '/user/artist/favorite/?' do
    if params[:user]
      user = User.new(params[:user])
    else
      user = @current_user or return error('invalid user')
    end
    favorite_artists = user.favorite_artists(:limit => 10, :want_rate => true) or return error('no artists')
    return success(favorite_artists.map { |a| [a['artist_name'] , a['artist_count_rate']] })
  end

  # post '/ajax/user/karaoke/attendance' - ログインユーザの指定したカラオケに対するattendanceを取得
  #---------------------------------------------------------------------
  post '/user/karaoke/attendance' do
    attendance = @current_user.get_attendance_at_karaoke(params[:id])
    
    return attendance ? success(attendance) : error('get attendance failed')
  end

  # post '/ajax/user/history/recent/key - 歌ったことがある楽曲ならば最近歌ったときのキーを返す
  #---------------------------------------------------------------------
  post '/user/history/recent/key' do
    # テスト実行時は失敗を返す
    Util.run_mode == 'ci' and return error('never sang')
    @current_user or return error('never sang')

    song = Song.name_to_id(params[:name], params[:artist]) or return error('never sang')
    key = @current_user.search_songkey(song['song_id'])
    if key
      success(key)
    else
      error('never sang')
    end
  end

  # post '/ajax/store/list' - 店と店舗のリストをJSONで戻す
  #---------------------------------------------------------------------
  post '/store/list/?' do
    success(Store.list)
  end

  # post '/ajax/history/detail/?' - 歌唱履歴の詳細を取得
  #---------------------------------------------------------------------
  post '/history/detail/?' do
    result = params[:id].nil? ? History.recent_song(:limit => 20) : History.new(params[:id], true).params
    return success(result)
  end

  # post '/ajax/history/create - ユーザの歌唱履歴を登録
  #---------------------------------------------------------------------
  post '/history/create' do
    history = {}
    karaoke_id = params[:karaoke_id]
    history['song_name'] = params[:song_name]
    history['artist_name'] = params[:artist_name]
    history['songkey'] = params[:songkey]
    history['score'] = params[:score]
    history['score_type'] = params[:score_type].to_i
    twitter = params[:twitter]
    # 歌手名/曲名は必須
    if history['song_name'].nil? || history['song_name'] == ''
      return error('曲名を入力してください')
    elsif history['artist_name'].nil? || history['artist_name'] == ''
      return error('歌手名を入力してください')
    end
    if @current_user
      info = @current_user.register_history(karaoke_id , history)
      twitter and @current_user.tweet_history(karaoke_id , history , params[:tweet_text])
      return success(info)
    else
      error('invalid current user')
    end
  end

  # post '/ajax/history/delete/?' - 歌唱履歴を削除する
  #--------------------------------------------------------------------
  post '/history/delete/?' do
    @current_user or return error('no login')
    history = History.new(params[:id])
    @current_user['username'] == Attendance.to_user_info([history['attendance']])[0]['user_name'] or return error('invalid user')
    history.params or return error('no record')
    history.delete
    return success
  end

  # post '/ajax/history/modify/?' - 歌唱履歴を編集する
  #--------------------------------------------------------------------
  post '/history/modify/?' do
    history = History.new(params[:id])
    history.params or return error('no record')
    arg = Util.to_hash(params[:params])
    twitter = arg['twitter']
    tweet_text = arg['tweet_text']
    arg['song_name'] == "" and return error('曲名を入力してください')
    arg['artist_name'] == "" and return error('歌手名を入力してください')
    result = history.modify(arg.dup)
    result and twitter and @current_user and @current_user.tweet_history(params[:id] , arg , tweet_text)
    return result ? success : error('modify failed')
  end

  # post '/ajax/karaoke/detail' - 指定したカラオケの詳細を取得
  #---------------------------------------------------------------------
  post '/karaoke/detail' do
    result = params[:id].nil? ? Karaoke.list_all : Karaoke.new(params[:id]).params
    return success(result)
  end

  # post '/ajax/karaoke/create' - カラオケ記録を登録する
  #---------------------------------------------------------------------
  post '/karaoke/create' do
    karaoke = {}
    karaoke['name'] = params[:name]
    karaoke['datetime'] = params[:datetime]
    karaoke['plan'] = params[:plan]
    karaoke['store'] = params[:store_name]
    karaoke['branch'] = params[:store_branch]
    karaoke['product'] = params['product'].to_i

    # 店名は必須
    if karaoke['store'].nil? || karaoke['store'] == ''
      return error('店名を入力してください')
    end

    if @current_user
      result = @current_user.register_karaoke(karaoke) 
      if result.kind_of?(Integer)
        params[:twitter] and @current_user.tweet_karaoke(result , params[:tweet_text])
        return success(karaoke_id: result)
      else
        return success(result)
      end
    else
      return error('invalid current user')
    end
  end

  # post '/ajax/karaoke/delete/?' - カラオケを削除する
  #--------------------------------------------------------------------
  post '/karaoke/delete/?' do
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
  post '/karaoke/modify/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    arg = Util.to_hash(params[:params])
    if arg['store_name'].nil? || arg['store_name'] == ""
      return error('店名を入力してください')
    end
    twitter = arg["twitter"]
    tweet_text = arg["tweet_text"]
    result = karaoke.modify(arg)
    result and twitter and @current_user and @current_user.tweet_karaoke(params[:id] , tweet_text)
    return result ? success : error('modify failed')
  end

  # post '/ajax/attendance/modify/?' - 参加情報を編集する
  #--------------------------------------------------------------------
  post '/attendance/modify/?' do
    attendance_info = @current_user.get_attendance_at_karaoke(params[:id])
    attendance_info or return error('not found attendance')

    attendance = Attendance.new(attendance_info['id'])
    arg = Util.to_hash(params[:params])
    result = attendance.modify(arg)
    
    return result ? success : error('modify failed')
  end

  # post '/ajax/attendance/create' - 参加情報を値段と感想は空のまま登録する
  #---------------------------------------------------------------------
  post '/attendance/create' do
    attendance = {}
    karaoke_id = params[:karaoke_id]

    if @current_user
      @current_user.register_attendance karaoke_id
      success
    else
      error('invalid current user')
    end
  end

end
