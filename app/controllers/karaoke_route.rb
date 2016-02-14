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
		redirect "/karaoke/user/#{@current_user['username']}"
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

	# get '/karaoke/create' - カラオケ記録追加ページヘのアクセス
	#---------------------------------------------------------------------
	get '/karaoke/create' do
		erb :create_karaoke
	end
	
	# get '/karaoke/input - カラオケ入力画面を表示
	#---------------------------------------------------------------------
	get '/karaoke/input' do
		@products = Product.list
		erb :_input_karaoke
	end

	# post '/karaoke/create' - カラオケ記録追加をリクエスト
	#---------------------------------------------------------------------
	post '/karaoke/create' do
		@current_user.create_karaoke_log(@params)
		redirect '/karaoke'
	end

	# post '/karaoke/input' - カラオケ記録を受け取り保持する
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

		@current_user.set_karaoke karaoke
		@current_user.set_attendance attendance
	end

end
