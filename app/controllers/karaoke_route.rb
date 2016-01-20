require_relative '../march'

class KaraokeRoute < March

	# get '/karaoke' - カラオケ記録を一覧表示
	#---------------------------------------------------------------------
	get '/karaoke' do
		@karaoke_list = @current_user.get_karaoke
		template :mykaraoke
	end

	# get '/karaoke/detail/:id' - カラオケ記録の詳細表示
	#---------------------------------------------------------------------
	get '/karaoke/detail/:id' do
		@karaoke = Karaoke.new(params[:id])
		@karaoke.get_history
		template :karaoke_detail
	end

	# get '/karaoke/create' - カラオケ記録追加ページヘのアクセス
	#---------------------------------------------------------------------
	get '/karaoke/create' do
		template :create_karaoke
	end

	# post '/karaoke/create' - カラオケ記録追加をリクエスト
	#---------------------------------------------------------------------
	post '/karaoke/create' do
		@current_user.create_karaoke_log(@params)
		redirect '/karaoke'
	end

end