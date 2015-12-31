#----------------------------------------------------------------------
# Karaoke - カラオケ記録に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'store'
class Karaoke

	attr_reader :params , :histories

	# initialize - インスタンスを生成し、機種名、店舗名を取得する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.sql_row("SELECT * FROM karaoke WHERE id = ?" , [id])

		product_info = DB.sql_row(
			"SELECT brand , product FROM product WHERE id = ?" ,
			[@params['product']]
		)
		@params['product_name'] = "#{product_info['brand']}(#{product_info['product']})"

		store = Store.new(@params['store'])
		@params['store_name'] = "#{store.params['name']} #{store.params['branch']}"
	end

	# list_all - カラオケ記録の一覧を全て取得し、店舗名まで取得する
	#---------------------------------------------------------------------
	def self.list_all()
		DB.sql_all(
			"SELECT datetime , plan , store , karaoke.product as product_id , price , karaoke.memo as memo , 
							store.name as store_name , store.branch as branch_name ,
							product.brand as brand_name , product.product as product_name
			 FROM (karaoke JOIN store ON karaoke.store = store.id)
			 JOIN product on karaoke.product = product.id
			 ORDER BY datetime DESC;"
		)
	end

	# get_history - カラオケ記録に対応した歌唱履歴を取得する
	#---------------------------------------------------------------------
	def get_history
		@histories = DB.sql_all(
			"SELECT datetime , attendance , history.song , history.songkey
			FROM ( history JOIN attendance ON history.attendance = attendance.id)
			JOIN karaoke ON karaoke.id = attendance.karaoke
			WHERE attendance.karaoke = ?
			ORDER BY datetime DESC;" , [@params['id']]
		)

		users_info = DB.sql_all(
			"SELECT attendance.id as attendanceid , user.id as userid , username , screenname
				FROM attendance JOIN user ON attendance.user = user.id
				WHERE karaoke = ?" , [@params['id']]
		)
		@params['members'] = users_info.collect { |user| user['username'] }.join(' , ')

		@histories.each do | history |
			song = Song.new(history['song'])
			history['song_name'] = song.params['name']
			history['artist_name'] = song.artist_name
			history['userinfo'] = users_info.find { |user| user['attendanceid'] == history['attendance'] }
		end
	end

end
