require_relative './march'

class HistoryRoute < March

  # get '/history/input - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/history/input' do
    @score_type = ScoreType.List
    erb :_input_history
  end

  # get '/history/register - 入力された歌唱履歴をすべて登録してカラオケ画面を表示
  #---------------------------------------------------------------------
  get '/history/register' do
    redirect "/karaoke/detail/#{karaoke_id}"  
  end

  # get '/history - ログイン中のユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/history/?' do
    @current_user and redirect "/history/#{@current_user['username']}"
  end

  # get '/history/:username - ユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/history/:username' do
    @user = User.new(params[:username])
    @histories = @user.histories
    @histories.each do |h|
      h['datetime'] = h['datetime'].to_s.split(' ')[0]
    end
    erb :history
  end

  # post '/history/input - ユーザの歌唱履歴を登録
  #---------------------------------------------------------------------
  post '/history/input' do
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
