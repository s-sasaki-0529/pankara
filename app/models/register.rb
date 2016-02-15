#----------------------------------------------------------------------
# Register - 歌唱履歴を作成する
#----------------------------------------------------------------------
require_relative 'util'
class Register < Base

	attr_accessor :karaoke , :with_url

	# initialize - インスタンスを生成する
	#---------------------------------------------------------------------
	def initialize(user)
		@userid = user['id']
		@karaoke = nil
		@attendance = nil
		@score_type = nil
		@with_url = true
	end

	# create_karaoke - カラオケ記録を作成する
	#---------------------------------------------------------------------
	def create_karaoke(datetime , name , plan , store , product)
		store_id = self.create_store(store)
		product_id = self.create_product(product)

		db = DB.new(
			:INSERT => ['karaoke' , ['datetime' , 'name' , 'plan' , 'store' , 'product' , 'created_by']] ,
			:SET => [datetime , name , plan , store_id , product_id , @userid]
		)
		@karaoke = db.execute_insert_id
	end

	# set_karaoke - カラオケIDを設定する
	#---------------------------------------------------------------------
	def set_karaoke(id)
		@karaoke = id
	end

	# attend_karaoke - カラオケに参加する 既に参加している場合IDを設定する
	#---------------------------------------------------------------------
	def attend_karaoke(price = nil , memo = nil)
		@karaoke or return
		@attendance = DB.new(
			:SELECT => 'id' ,
			:FROM => 'attendance' ,
			:WHERE => ['user = ?' , 'karaoke = ?'] ,
			:SET => [@userid , @karaoke]
		).execute_column

		if @attendance.nil?
			db = DB.new(
				:INSERT => ['attendance' , ['user' , 'karaoke' , 'price' , 'memo']] ,
				:SET => [@userid , @karaoke , price , memo] 
			)
			@attendance = db.execute_insert_id
		end
	end

	# create_history - 歌唱履歴を作成する
	#---------------------------------------------------------------------
	def create_history(song , artist ,  key = 0 , score_type=nil , score=nil)
		@attendance or return
		artist_id = create_artist(artist)
		song_id = create_song(artist_id , artist , song)
		scoretype_id = get_scoretype(score_type)
		DB.new(
			:INSERT => ['history' , ['attendance' , 'song' , 'songkey' , 'score_type' , 'score']] ,
			:SET => [@attendance , song_id , key , scoretype_id , score] ,
		).execute_insert_id
	end

	# create_artist - 歌手を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_artist(name)
		artist_id = DB.new(
			:SELECT => 'id' , :FROM => 'artist' , :WHERE => 'name = ?' , :SET => name
		).execute_column
		
		if artist_id
			artist_id
		else
			DB.new(
				:INSERT => ['artist' , ['name']] ,
				:SET => name
			).execute_insert_id
		end
	end

	# create_song - 曲を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_song(artist_id , artist_name , song_name)
		song_id = DB.new(
			:SELECT => 'id' , :FROM => 'song' , :WHERE => ['artist = ?' , 'name = ?'] ,
			:SET => [artist_id , song_name]
		).execute_column
		
		if song_id
			song_id
		else
			url = @with_url ? Util.search_tube(artist_name , song_name) : nil
			DB.new(
				:INSERT => ['song' , ['artist' , 'name' , 'url']] ,
				:SET => [artist_id , song_name , url] ,
			).execute_insert_id
		end
	end

	# create_store - 店舗を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_store(store)
		store_id = DB.new(
			:SELECT => 'id' , :FROM => 'store' , :WHERE => ['name = ?' , 'branch = ?'] ,
			:SET => [store['name'] , store['branch']]
		).execute_column
		
		if store_id
			store_id
		else
			DB.new(
				:INSERT => ['store' , ['name' , 'branch']] ,
				:SET => [store['name'] , store['branch']] ,
			).execute_insert_id
		end
	end

	# create_product - 機種を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_product(product)
		product_id = DB.new(
			:SELECT => 'id' , :FROM => 'product' , :WHERE => ['brand = ?' , 'product = ?'] ,
			:SET => [product['brand'] , product['product']]
		).execute_column
		
		if product_id
			product_id
		else
			DB.new(
				:INSERT => ['product' , ['brand' , 'product']] ,
				:SET => [product['brand'], product['product']] ,
			).execute_insert_id
		end
	end

	# get_scoretype - 採点モードのIDを取得。固定データのため新規登録は無し
	#---------------------------------------------------------------------
	def get_scoretype(score_type)
		score_type or return
		brand = score_type['brand']
		name = score_type['name']
		db = DB.new(
			:SELECT => 'id' , :FROM => 'score_type' , :WHERE => ['brand = ?' , 'name = ?'] ,
			:SET => [brand , name]
		).execute_column
	end

end
