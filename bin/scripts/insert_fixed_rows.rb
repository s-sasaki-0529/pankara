PRODUCTS = 6
STORES = 15
SCORE_TYPES = 8
ARTISTS = 100
SONGS = 3
USERS = 5
FRIENDS = 5
KARAOKES = 30
HISTORIES = 4220

def random_date
  year = 2000 + rand(15)
  month = rand(12) + 1
  day = rand(27) + 1
  hour = rand(24)
  min = rand(60)
  sec = rand(60)
  "#{year}-#{month}-#{day} #{hour}:#{min}:#{sec}"
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

def insert_friend(n)
  puts "INSERT INTO friend ( user_from , user_to ) VALUES"
  print [
    "(1 , 2)" ,
    "(1 , 3)" ,
    "(1 , 4)" ,
    "(2 , 1)" ,
    "(3 , 1)"
  ].join(",\n")
  puts ";"
end

def insert_song(n)
  puts "INSERT INTO song ( artist , name , url) VALUES"
  insert = []
  ARTISTS.times do |i|
    n.times do |s|
      tube = 'https://www.youtube.com/watch?v=_4P4P1Q-3k4'
      nico = 'http://www.nicovideo.jp/watch/sm27583432'
      url = s % 2 == 0 ? tube : nico
      insert.push "(#{i + 1} , '楽曲#{i}-#{s}' , '#{url}')"
    end
  end
  print insert.join(",\n")
  puts ";"
end

def insert_karaoke(n)
  puts "INSERT INTO karaoke ( name , datetime , plan , store , product , created_by ) VALUES"
  insert = []
  n.times do |i|
    datetime = random_date
    name = "カラオケ#{i}"
    plan = (i % 18 + 1).to_f / 2
    store = i % STORES + 1
    product = i % PRODUCTS + 1
    created_by = i % USERS + 1
    insert.push "('#{name}' , '#{datetime}' , #{plan} , #{store} , #{product} , #{created_by})"
  end
  print insert.join(",\n")
  puts ";"
end

def insert_attendance
  puts "INSERT INTO attendance ( user , karaoke , price , memo) VALUES"
  count = 0
  insert = []
  KARAOKES.times do |i|
    karaoke = i + 1
    USERS.times do |s|
      user = s + 1
      price = rand(1000) + 1000
      memo = ['楽しかった' , '気まずかった' , '気持ちよかった' , 'クソだった'].sample
      if karaoke % user == 0
        insert.push "( #{user} , #{karaoke} , #{price} , '#{memo}')"
        count += 1
      end
    end
  end
  print insert.join(",\n")
  puts ";"
  return count
end

def insert_history(n , attendances)
  puts "INSERT INTO history ( attendance , song , songkey , score_type , score ) VALUES"
  insert = []
  n.times do |i|
    attendance = i % attendances + 1
    song = i % (SONGS * ARTISTS) + 1
    songkey = i % 12 - 6
    score_type = i % (SCORE_TYPES) + 1
    score = [10 , 25, 45 , 55 ,60 , 65 , 70.5 , 74.8 , 80.2 , 87.5 , 90.2 , 95.6 , 99.9 , 100][i % 14]
    insert.push "(#{attendance} , #{song} , #{songkey} , #{score_type} , #{score})"
  end
  print insert.join(",\n")
  puts ";"
end

puts "use march"
insert_store(5,3)
insert_artist(ARTISTS)
insert_user(USERS)
insert_friend(FRIENDS)
insert_song(SONGS)
insert_karaoke(KARAOKES)

attendances = insert_attendance()
insert_history(HISTORIES , attendances)
