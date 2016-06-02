require_relative './march'
require_relative '../models/product'
require_relative '../models/score_type'
require_relative '../models/song'
require_relative '../models/karaoke'
require_relative '../models/history'

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
    @twitter = @current_user ? @current_user.twitter_account : nil
    erb :_input_karaoke
  end

  # get '/ajax/history/dialog - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/ajax/history/dialog' do
    @score_type = ScoreType.List
    @twitter = @current_user ? @current_user.twitter_account : nil
    erb :_input_history
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

  # post '/ajax/song/tally/monthly/count/?' - 指定した楽曲の月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/ajax/song/tally/monthly/count/?' do
    song = Song.new(params['song']) or return error('invalid song id')
    sang_histories = song.monthly_sang_count or return error('no history')
    sang_histories.empty? and return error('no history')
    monthly_data = Util.monthly_array(:desc => true)
    monthly_data.each do |m|
      month = m[:month]
      sang_histories[month] and sang_histories[month].each do |u|
        screen_name = u['user_screenname']
        m[screen_name] or m[screen_name] = 0
        m[screen_name] += 1
      end
      m[:_month] = m[:month]
      m.delete(:month)
    end
    return success(monthly_data)
  end

  # post '/ajax/user/artist/favorite/?' - ログインユーザの主に歌うアーティスト１０組を戻す
  #--------------------------------------------------------------------
  post '/ajax/user/artist/favorite/?' do
    user = @current_user or return error('invalid user')
    favorite_artists = user.favorite_artists(:limit => 10, :want_rate => true) or return error('no artists')
    return success(favorite_artists.map { |a| [a['artist_name'] , a['artist_count_rate']] })
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

    result = karaoke.modify(arg)
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
    result = history.modify(arg)
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

    opt = {:tweet => params[:twitter]}

    if @current_user
      result = @current_user.register_karaoke(karaoke , opt)
     
      if result.kind_of?(Integer)
        @current_user.register_attendance(result)
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
    history['song'] = params[:song_name]
    history['artist'] = params[:artist_name]
    history['songkey'] = params[:songkey]
    history['score'] = params[:score]
    history['score_type'] = params[:score_type].to_i
    opt = {:tweet => params[:twitter]}
    if @current_user
      @current_user.register_history(karaoke_id , history , opt)
      Util.to_json({'result' => 'success'})
    else
      Util.to_json({'result' => 'invalid current user'})
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
