require_relative './march'

class KaraokeRoute < March

	# get '/karaoke' - カラオケ記録を一覧表示
	#---------------------------------------------------------------------
	get '/karaoke' do
		@karaoke_list = @current_user.get_karaoke
		erb :mykaraoke
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

	# post '/karaoke/create' - カラオケ記録追加をリクエスト
	#---------------------------------------------------------------------
	post '/karaoke/create' do
		@current_user.create_karaoke_log(@params)
		redirect '/karaoke'
	end

	# post '/karaoke/input' - カラオケ記録を受け取り保持する
	#---------------------------------------------------------------------
	post '/karaoke/input' do
		p product = Product.new(params[:product].to_i)
		karaoke = {}
		karaoke['name'] = params[:name]
		karaoke['datetime'] = params[:datetime]
		karaoke['plan'] = params[:plan]
		karaoke['store'] = params[:store]
		karaoke['branch'] = params[:branch]
		karaoke['product'] = params[:product]
		@current_user.set_karaoke karaoke
	end

end
