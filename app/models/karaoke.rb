#----------------------------------------------------------------------
# Karaoke - カラオケ記録に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class Karaoke

	attr_reader :params , :artist_name

	# initialize - インスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id)
	end

	# list_all - カラオケ記録の一覧を全て取得し、店舗名まで取得する
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

end
