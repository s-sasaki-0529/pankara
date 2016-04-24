require_relative './march'

class LocalRoute < March

  # success - 正常を通知するJSONを戻す
  #--------------------------------------------------------------------
  def success
    return Util.to_json({:result => 'success'})
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
    erb :_input_karaoke
  end

  # get '/ajax/history/dialog - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/ajax/history/dialog' do
    @score_type = ScoreType.List
    erb :_input_history
  end

  # post '/local/rpc/songlist' - 楽曲一覧を戻す
  #---------------------------------------------------------------------
  post '/local/rpc/songlist/?' do
    hash = Hash.new
    Song.list.each do |s|
      hash[s['song_name']] = s['artist_name']
    end
    return Util.to_json(hash)
  end

  # post '/local/rpc/storelist' - 店と店舗のリストをJSONで戻す
  #---------------------------------------------------------------------
  post '/local/rpc/storelist/?' do
    Util.to_json(Store.list)
  end

  # post '/local/rpc/karaokelist/?' - カラオケの一覧もしくは指定したカラオケを戻す
  #---------------------------------------------------------------------
  post '/local/rpc/karaokelist/?' do
    params[:id].nil? ? Util.to_json(Karaoke.list_all) : Util.to_json(Karaoke.new(params[:id]).params)
  end

  # post '/local/rpc/historylist/?' - 歌唱履歴の一覧もしくは指定した歌唱履歴を戻す
  #---------------------------------------------------------------------
  post '/local/rpc/historylist/?' do
    params[:id].nil? ? Util.to_json(History.recent_song) : Util.to_json(History.new(params[:id], true).params)
  end

  # post '/local/rpc/karaoke/delete/?' - カラオケを削除する
  #--------------------------------------------------------------------
  post '/local/rpc/karaoke/delete/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    result = karaoke.delete
    if result
      return success
    else
      return error('delete failed')
    end
  end

  # post '/local/rpc/karaoke/modify/?' - カラオケを編集する
  #--------------------------------------------------------------------
  post '/local/rpc/karaoke/modify/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    arg = Util.to_hash(params[:params])
    result = karaoke.modify(arg)
    return result ? success : error('modify failed')
  end

  # post '/local/rpc/history/delete/?' - 歌唱履歴を削除する
  #--------------------------------------------------------------------
  post '/local/rpc/history/delete/?' do
    history = History.new(params[:id])
    history.params or return error('no record')
    history.delete
    return success
  end

  # post '/local/rpc/history/modify/?' - 歌唱履歴を編集する
  #--------------------------------------------------------------------
  post '/local/rpc/history/modify/?' do
    history = History.new(params[:id])
    history.params or return error('no record')
    arg = Util.to_hash(params[:params])
    result = history.modify(arg)
    return result ? success : error('modify failed')
  end

  # post '/ajax/attended/' - カラオケに参加済みか確認する
  #--------------------------------------------------------------------
  post '/ajax/attended' do
    attended = @current_user.attended? params[:karaoke_id]
    return Util.to_json({:attended => attended})
  end

  # post '/ajax/karaoke/create' - カラオケ記録を登録する
  #---------------------------------------------------------------------
  post '/ajax/karaoke/create' do
    karaoke = {}
    karaoke['name'] = params[:name]
    karaoke['datetime'] = params[:datetime]
    karaoke['plan'] = params[:plan]
    karaoke['store'] = params[:store]
    karaoke['branch'] = params[:branch]
    karaoke['product'] = params['product'].to_i

    attendance = {}
    attendance['price'] = params[:price].to_i
    attendance['memo'] = params[:memo]

    if @current_user
      karaoke_id = @current_user.register_karaoke karaoke
      @current_user.register_attendance karaoke_id, attendance
      Util.to_json({'result' => 'success', 'karaoke_id' => karaoke_id})
    else
      Util.to_json({'result' => 'invalid current user'})
    end
  end

  # post '/ajax/attendance/create' - 出席情報のみ登録する
  #---------------------------------------------------------------------
  post '/ajax/attendance/create' do
    attendance = {}
    karaoke_id = params[:karaoke_id]
    attendance['price'] = params[:price].to_i
    attendance['memo'] = params[:memo]

    if @current_user
      @current_user.register_attendance karaoke_id, attendance
      Util.to_json({'result' => 'success'})
    else
      Util.to_json({'result' => 'invalid current user'})
    end
  end
  
  # post '/ajax/history/create - ユーザの歌唱履歴を登録
  #---------------------------------------------------------------------
  post '/ajax/history/create' do
    history = {}
    karaoke_id = params[:karaoke_id]
    history['song'] = params[:song]
    history['artist'] = params[:artist]
    history['songkey'] = params[:songkey]
    history['score'] = params[:score]
    history['score_type'] = params[:score_type].to_i

    if @current_user
      @current_user.register_history karaoke_id, history
      Util.to_json({'result' => 'success'})
    else
      Util.to_json({'result' => 'invalid current user'})
    end
  end

end
