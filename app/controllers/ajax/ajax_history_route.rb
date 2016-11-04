require_relative 'ajax_route'

class AjaxHistoryRoute < AjaxRoute

  # post '/ajax/history/detail/?' - 歌唱履歴の詳細を取得
  #---------------------------------------------------------------------
  post '/detail/?' do
    params[:id] or return error('invalid history id')
    result = History.new(params[:id], true).params
    result or return error('歌唱履歴を取得できませんでした')
    return success(result)
  end

  # post '/ajax/history/create - ユーザの歌唱履歴を登録
  #---------------------------------------------------------------------
  post '/create' do
    @current_user or return error('ログインしてください')
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
    info = @current_user.register_history(karaoke_id , history)
    twitter and @current_user.tweet_history(karaoke_id , history , params[:tweet_text])
    return success(info)
  end

  # post '/ajax/history/delete/?' - 歌唱履歴を削除する
  #--------------------------------------------------------------------
  post '/delete/?' do
    @current_user or return error('ログインしてください')
    history = History.new(params[:id])
    @current_user.attend_ids.include?(history['attendance']) or return error ('あなたの歌唱履歴ではありません')
    history.params or return error('no record')
    history.delete
    return success
  end

  # post '/ajax/history/modify/?' - 歌唱履歴を編集する
  #--------------------------------------------------------------------
  post '/modify/?' do
    @current_user or return error('ログインしてください')
    history = History.new(params[:id])
    @current_user.attend_ids.include?(history['attendance']) or return error ('あなたの歌唱履歴ではありません')
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

end
