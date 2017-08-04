require_relative './march'
require_relative '../models/user_attr'

class ConfigRoute < March

  # get '/config' - ユーザ設定ページ
  #--------------------------------------------------------------------
  get '/' do

    #ログインユーザのみアクセス可能
    @current_user or redirect '/auth/login'

    # 設定変更のメッセージ
    @mod_config_result = flash[:mod_config_result]

    erb :config
  end

  # get '/config/viewtype' - スマフォアクセス時の表示モードを切り替える'
  #--------------------------------------------------------------------
  get '/viewtype/?' do
    callback = params['callback']
    unless Util.is_smartphone_strictly?
      redirect '/'
    else
      new_mode = ! Util.session['view_pc_mode']
      Util.modify_session('view_pc_mode' , new_mode)
      redirect callback
    end
  end

  # post '/config/icon/?' - アイコンファイルのアップロード
  #--------------------------------------------------------------------
  post '/icon/?' do
    if params[:icon_file] && @current_user
     flash[:mod_config_result] = Util.save_icon_file(params[:icon_file] , @current_user['username'])
    end
    redirect '/config'
  end

end
