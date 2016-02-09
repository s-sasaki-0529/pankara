require_relative './march'

class HistoryRoute < March

	# get '/history - ログイン中のユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history' do
		@user = @current_user
		@histories = @current_user.histories
		erb :history
	end

	# get '/history/regist - 入力された歌唱履歴をすべて登録してカラオケ画面を表示
	#---------------------------------------------------------------------
	get '/history/regist' do
		karaoke_id = @current_user.registrate_history
		redirect "/karaoke/detail/#{karaoke_id}"	
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
		history[:song] = params[:song]
		history[:artist] = params[:artist]
		history[:score] = params[:score]
		history[:key] = params[:key]

		p params
		@current_user.store_history history
	end

end
