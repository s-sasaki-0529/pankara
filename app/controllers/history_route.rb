require_relative './march'

class HistoryRoute < March

	# get '/history - ログイン中のユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history' do
		@user = @current_user
		@histories = @current_user.histories
		template :history
	end

	# get '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(params[:username])
		@histories = @user.histories
		template :history
	end
	
end
