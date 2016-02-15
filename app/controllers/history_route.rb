require_relative './march'

class HistoryRoute < March

	# get '/history - ログイン中のユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history' do
		@user = @current_user
		@histories = @current_user.histories
		erb :history
	end

	# get '/history/input - 歌唱履歴の入力画面を表示
	#---------------------------------------------------------------------
	get '/history/input' do
		@score_type = ScoreType.List
		erb :_input_history
	end

	# get '/history/register - 入力された歌唱履歴をすべて登録してカラオケ画面を表示
	#---------------------------------------------------------------------
	get '/history/register' do
		karaoke_id = @current_user.get_karaoke_id
		karaoke_id = @current_user.register_karaoke if karaoke_id == 0
		@current_user.register_history
		redirect "/karaoke/detail/#{karaoke_id}"	
	end
	
	# get '/history/reset - 入力された歌唱履歴をすべて破棄
	#---------------------------------------------------------------------
	get '/history/reset' do
		@current_user.reset_input_info
	end

	# get '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(params[:username])
		@histories = @user.histories
		erb :history
	end

	# post '/history/input - ユーザの歌唱履歴を登録
	#---------------------------------------------------------------------
	post '/history/input' do
		history = {}
		history['song'] = params[:song]
		history['artist'] = params[:artist]
		history['score'] = params[:score]
		history['songkey'] = params[:songkey]
		history['score_type'] = params[:score_type].to_i

		@current_user.store_history history
	end

end
