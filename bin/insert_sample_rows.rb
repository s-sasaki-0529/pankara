PRODUCTS = 6
STORES = 15
ARTISTS = 100
SONGS = 300
USERS = 10
KARAOKES = 30
ATTENDANCES = 100
HISTORIES = 1000

def random_date
	year = 2000 + rand(15)
	month = rand(12) + 1
	day = rand(27) + 1
	hour = rand(24)
	min = rand(60)
	sec = rand(60)
	"#{year}-#{month}-#{day} #{hour}:#{min}:#{sec}"
end

def insert_product
	puts "INSERT INTO product ( brand , product ) VALUES"
	puts "('JOYSOUND' , 'WAVE') ,"
	puts "('JOYSOUND' , 'CROSSO') ,"
	puts "('JOYSOUND' , 'f1') ,"
	puts "('JOYSOUND' , 'MAX') ,"
	puts "('DAM' , 'Premier DAM') ,"
	puts "('DAM' , 'LIVE DAM');"
end

def insert_store(n , m)
	puts "INSERT INTO store ( name , branch , url , memo ) VALUES"
	insert = []
	n.times do |i|
		m.times do |s|
			insert.push "('カラオケ店#{i}' , '店舗#{s}' , 'http://www.yahoo.co.jp' , 'memo#{i}-#{s}')"
		end
	end
	print insert.join(",\n")
	puts ";"
end

def insert_artist(n)
	puts "INSERT INTO artist ( name ) VALUES"
	insert = []
	n.times do |i|
		insert.push "('歌手#{i}')"
	end
	print insert.join(",\n")
	puts ";"
end

def insert_user(n)
	puts "INSERT INTO user ( username , password , screenname ) VALUES"
	insert = []
	n.times do |i|
		insert.push "('user#{i}' , 'user#{i}' , 'ユーザ#{i}')"
	end
	print insert.join(",\n")
	puts ";"
end

def insert_song(n)
	puts "INSERT INTO song ( artist , name ) VALUES"
	insert = []
	n.times do |i|
		artist = rand(ARTISTS) + 1
		insert.push "(#{artist} , '楽曲#{i}')"
	end
	print insert.join(",\n")
	puts ";"
end

def insert_karaoke(n)
	puts "INSERT INTO karaoke ( name , datetime , plan , store , product , price , memo ) VALUES"
	insert = []
	n.times do |i|
		datetime = random_date
		name = "カラオケ#{i}"
		plan = rand(9) + 1
		store = rand(STORES) + 1
		product = rand(PRODUCTS) + 1
		price = rand(1000) + 1000
		memo = ['楽しかった' , '気まずかった' , '気持ちよかった' , 'クソだった'].sample
		insert.push "('#{name}' , '#{datetime}' , #{plan} , #{store} , #{product} , #{price} , '#{memo}')"
	end
	print insert.join(",\n")
	puts ";"
end

def insert_attendance(n)
	puts "INSERT INTO attendance ( user , karaoke ) VALUES"
	insert = []
	n.times do |i|
		user = rand(USERS) + 1
		karaoke = rand(KARAOKES) + 1
		insert.push "(#{user} , #{karaoke})"
	end
	uniq_insert = insert.uniq
	print uniq_insert.join(",\n")
	puts ";"
	return uniq_insert.size
end

def insert_history(n , attendances)
	puts "INSERT INTO history ( attendance , song , songkey , score_type , score ) VALUES"
	insert = []
	n.times do |i|
		attendance = rand(attendances) + 1
		song = rand(SONGS) + 1
		songkey = rand(13) - 6
		score_type = ['全国採点オンライン２' , '全国採点グランプリ' , '分析採点３' , '精密採点DX'].sample
		score = rand(100..10000).to_f / 100.0
		insert.push "(#{attendance} , #{song} , #{songkey} , '#{score_type}' , #{score})"
	end
	print insert.join(",\n")
	puts ";"
end

puts "use march"
insert_product
insert_store(5,3)
insert_artist(ARTISTS)
insert_user(USERS)
insert_song(SONGS)
insert_karaoke(KARAOKES)

attendances = insert_attendance(ATTENDANCES)
insert_history(HISTORIES , attendances)
insert_history(HISTORIES , attendances)
