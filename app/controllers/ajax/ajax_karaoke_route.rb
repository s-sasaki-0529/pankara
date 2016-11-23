require_relative 'ajax_route'

class AjaxKaraokeRoute < AjaxRoute


  # post '/ajax/karaoke/detail' - 指定したカラオケの詳細を取得
  #---------------------------------------------------------------------
  post '/detail' do
    result = params[:id].nil? ? Karaoke.list_all : Karaoke.new(params[:id]).params
    return success(result)
  end

  # post '/ajax/karaoke/create' - カラオケ記録を登録する
  #---------------------------------------------------------------------
  post '/create' do
    karaoke = {}
    karaoke['name'] = params[:name]
    karaoke['datetime'] = params[:datetime]
    karaoke['plan'] = params[:plan]
    karaoke['store'] = params[:store_name]
    karaoke['branch'] = params[:store_branch]
    karaoke['product'] = params['product'].to_i

    if @current_user
      result = @current_user.register_karaoke(karaoke)
      if result
        params[:twitter] and @current_user.tweet_karaoke(result , params[:tweet_text])
        return success(karaoke_id: result)
      else
        return error('カラオケの登録に失敗しました。管理者に問い合わせてください。')
      end
    else
      return error('ログインしてください')
    end
  end

  # post '/ajax/karaoke/delete/?' - カラオケを削除する
  #--------------------------------------------------------------------
  post '/delete/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    result = karaoke.delete
    return result ? success : error('カラオケの削除に失敗しました')
  end

  # post '/ajax/karaoke/modify/?' - カラオケを編集する
  #--------------------------------------------------------------------
  post '/modify/?' do
    karaoke = Karaoke.new(params[:id])
    karaoke.params or return error('no record')
    arg = Util.to_hash(params[:params])
    twitter = arg["twitter"]
    tweet_text = arg["tweet_text"]
    result = karaoke.modify(arg)
    result and twitter and @current_user and @current_user.tweet_karaoke(params[:id] , tweet_text)
    return result ? success : error('modify failed')
  end

end
