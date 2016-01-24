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

		db = DB.new
		db.insert('karaoke' , ['datetime' , 'name' , 'plan' , 'store' , 'product'])
		db.set(datetime , name , plan , store_id , product_id)
		@karaoke = db.execute_insert_id
	end

	# attend_karaoke - カラオケに参加する
	#---------------------------------------------------------------------
	def attend_karaoke(price = nil , memo = nil)
		@karaoke or return
		db = DB.new
		db.insert('attendance' , ['user' , 'karaoke' , 'price' , 'memo'])
		db.set(@userid , @karaoke , price , memo)
		@attendance = db.execute_insert_id
	end

	# create_history - 歌唱履歴を作成する
	#---------------------------------------------------------------------
	def create_history(artist , song , key = 0 , score_type=nil , score=nil)
		@attendance or return
		artist_id = create_artist(artist)
		song_id = create_song(artist_id , artist , song)
		scoretype_id = get_scoretype(score_type)
		db = DB.new
		db.insert('history' , ['attendance' , 'song' , 'songkey' , 'score_type' , 'score'])
		db.set(@attendance , song_id , key , scoretype_id , score)
		db.execute_insert_id
	end

	# create_artist - 歌手を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_artist(name)
		db = DB.new
		db.select('id')
		db.from('artist')
		db.where('name = ?')
		db.set(name)
		artist_id = db.execute_column
		if artist_id
			artist_id
		else
			db.insert('artist' , ['name'])
			db.set(name)
			db.execute_insert_id
		end
	end

	# create_song - 曲を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_song(artist_id , artist_name , song_name)
		db = DB.new
		db.select('id')
		db.from('song')
		db.where('artist = ?' , 'name = ?')
		db.set(artist_id , song_name)
		song_id = db.execute_column
		if song_id
			song_id
		else
			url = @with_url ? Util.search_tube(artist_name , song_name) : nil
			db.insert('song' , ['artist' , 'name' , 'url'])
			db.set(artist_id , song_name , url)
			db.execute_insert_id
		end
	end

	# create_store - 店舗を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_store(store)
		db = DB.new
		db.select('id')
		db.from('store')
		db.where('name = ?' , 'branch = ?')
		db.set(store['name'] , store['branch'])
		store_id = db.execute_column
		if store_id
			store_id
		else
			db.insert('store' , ['name' , 'branch'])
			db.set(store['name'] , store['branch'])
			db.execute_insert_id
		end
	end

	# create_product - 機種を新規登録。既出の場合IDを戻す
	#---------------------------------------------------------------------
	def create_product(product)
		db = DB.new
		db.select('id')
		db.from('product')
		db.where('brand = ?' , 'product = ?')
		db.set(product['brand'] , product['product'])
		product_id = db.execute_column
		if product_id
			product_id
		else
			db.insert('product' , ['brand' , 'product'])
			db.set(product['brand'], product['product'])
			db.execute_insert_id
		end
	end

	# get_scoretype - 採点モードのIDを取得。固定データのため新規登録は無し
	#---------------------------------------------------------------------
	def get_scoretype(score_type)
		score_type or return
		brand = score_type['brand']
		name = score_type['name']
		db = DB.new
		db.select('id')
		db.from('score_type')
		db.where('brand = ?' , 'name = ?')
		db.set(brand , name)
		db.execute_column
	end

end
