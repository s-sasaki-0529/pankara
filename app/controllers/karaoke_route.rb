require_relative './march'

class KaraokeRoute < March

  # get '/karaoke/list' - 全カラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/list/?' do
    @karaoke_list = Karaoke.list_all
    erb :karaokelist
  end

  # get '/karaoke/user' - ログイン中ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/user/?' do
    @current_user and redirect "/karaoke/user/#{@current_user['username']}"
  end

  # get '/karaoke/user/:username' - 特定ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/user/:username' do
    @user = User.new(params[:username])
    @karaoke_list = @user.get_karaoke
    erb :karaokelist
  end

  # get '/karaoke/detail/:id' - カラオケ記録の詳細表示
  #---------------------------------------------------------------------
  get '/karaoke/detail/:id' do
    @karaoke = Karaoke.new(params[:id])
    @karaoke.get_history
    erb :karaoke_detail
  end

  # get '/karaoke/input - カラオケ入力画面を表示
  #---------------------------------------------------------------------
  get '/karaoke/input' do
    @products = Product.list
    erb :_input_karaoke
  end

  # post '/karaoke/input' - カラオケ記録を受け取り登録
  #---------------------------------------------------------------------
  post '/karaoke/input' do
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

  # post '/karaoke/input/attendance' - 出席情報のみ受け取り登録
  #---------------------------------------------------------------------
  post '/karaoke/input/attendance' do
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

end
