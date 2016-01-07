#----------------------------------------------------------------------
# Karaoke - カラオケ記録に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Karaoke

	attr_reader :params , :histories

	# initialize - インスタンスを生成し、機種名、店舗名を取得する
	#---------------------------------------------------------------------
	def initialize(id)
		db = DB.new
		db.from('karaoke')
		db.where('id = ?')
		db.set(id)
		@params = db.execute_row

		product = Product.new(@params['product'])
		@params['product_name'] = "#{product.params['brand']}(#{product.params['product']})"

		store = Store.new(@params['store'])
		@params['store_name'] = "#{store.params['name']} #{store.params['branch']}"
	end

	# list_all - カラオケ記録の一覧を全て取得し、店舗名まで取得する
	#---------------------------------------------------------------------
	def self.list_all()
		db = DB.new
		db.select({
			'karaoke.id' => 'id' ,
			'karaoke.name' => 'name' ,
			'karaoke.datetime' => 'datetime' ,
			'karaoke.plan' => 'plan' ,
			'karaoke.store' => 'store' ,
			'karaoke.product' => 'product_id' ,
			'karaoke.price' => 'price' ,
			'karaoke.memo' => 'memo' ,
			'store.name' => 'store_name' ,
			'store.branch' => 'branch_name' ,
			'product.brand' => 'brand_name' ,
			'product.product' => 'product_name'
		})
		db.from('karaoke')
		db.join(
			['karaoke' , 'store'] ,
			['karaoke' , 'product']
		)
		db.option('ORDER BY datetime DESC')
		db.execute_all
	end

	# get_history - カラオケ記録に対応した歌唱履歴を取得する
	#---------------------------------------------------------------------
	def get_history
		db = DB.new
		db.select('name' , 'datetime' , 'attendance' , 'song' , 'songkey' , 'score_type' , 'score')
		db.from('history')
		db.join(
			['history' , 'attendance'] ,
			['attendance' , 'karaoke']
		)
		db.where('attendance.karaoke = ?')
		db.option('ORDER BY datetime DESC')
		db.set(@params['id'])
		@histories = db.execute_all

		db = DB.new
		db.select({
			'attendance.id' => 'attendance' ,
			'user.id' => 'userid' ,
			'user.username' => 'username' ,
			'user.screenname' => 'screenname'
		})
		db.from('attendance')
		db.join(['attendance' , 'user'])
		db.where('karaoke = ?')
		db.set(@params['id'])
		users_info = db.execute_all
		@params['members'] = users_info.collect { |user| user['screenname'] }.join(' , ')
		@histories.each do | history |
			song = Song.new(history['song'])
			history['song_id'] = song.params['id']
			history['song_name'] = song.params['name']
			history['artist_id'] = song.params['artist']
			history['artist_name'] = song.params['artist_name']
			history['userinfo'] = users_info.find { |user| user['attendance'] == history['attendance'] }
		end
	end
end
