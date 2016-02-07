require_relative './march'

class HistoryRoute < March

	# get '/history - ログイン中のユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history' do
		@user = @current_user
		@histories = @current_user.histories
		erb :history
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
		history[:song] = @params[:song]
		history[:artist] = @params[:artist]
		history[:score] = @params[:score]
		
		@current_user.store_history history

		if @params.has_key? 'next'
			redirect "/"
		else
			karaoke_id = @current_user.registrate_history
			redirect "/karaoke/detail/#{karaoke_id}"
		end
	end
end
