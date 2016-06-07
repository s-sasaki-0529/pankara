#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
require_relative 'karaoke'
require_relative 'user'
require_relative 'score_type'
require_relative 'product'
require_relative 'register'
require_relative 'twitter'
require_relative 'friend'
require_relative 'pager'

class User < Base

  # initialize(user) - インスタンスを生成
  # 正しいコンストラクタ引数が届くこと前提
  # User.new('sa2knight') - usernameがsa2knightのユーザを生成
  # User.new({:id => 1}) - idが1のユーザを生成
  #---------------------------------------------------------------------
  def initialize(user)
    user.kind_of?(String) and username = user
    user.kind_of?(Hash) and user[:username] and username = user[:username]
    user.kind_of?(Hash) and user[:id] and id = user[:id]
    if username
      @params = DB.new(:FROM => 'user' , :WHERE => 'username = ?' , :SET => username).execute_row
    elsif id
      @params = DB.new(:FROM => 'user' , :WHERE => 'id = ?' , :SET => id).execute_row
    end
    @params['has_twitter'] = Twitter.has_twitter?(@params['username'])
  end

  # histories - ユーザの歌唱履歴と関連情報を取得
  #---------------------------------------------------------------------
  def histories(opt = {})

    # attendance / karaoke 一覧を取得
    attend_info = self.attend_ids(:want_karaoke => true)
    attend_info.size > 0 or return []
    attend_ids = attend_info.map {|a| a['id']}
    karaoke_ids = attend_info.map {|a| a['karaoke']}
    ak_map = {}
    attend_ids.each_with_index {|a,i| ak_map[a] = karaoke_ids[i]}

    # 歌唱履歴を全て取得し、場号を振る
    db = DB.new(
      :SELECT => ['song' , 'songkey' , 'attendance'],
      :FROM => 'history' ,
      :WHERE_IN => ['attendance' , attend_ids.length],
      :SET => attend_ids ,
      :OPTION => 'ORDER BY id desc'
    )
    histories = db.execute_all
    histories.each_with_index {|h,i| h['number'] = histories.count - i}

    if pager = opt[:pager] #ページャ利用
      histories = pager.getData(histories)
    elsif limit = opt[:limit] # ページャは利用しないが取得件数を制限
      histories = histories[0 , limit]
    end

    # カラオケ情報を取得、attendanceと関連付け
    karaoke_info = Util.array_to_hash(Karaoke.list(:ids => karaoke_ids) , 'karaoke_id')

    # 各々の歌唱履歴に対応する楽曲、歌手情報を取得
    songs = histories.map {|h| h['song']}
    songs_info = Song.list(:songs => songs, :artist_info => true , :want_hash => true)

    # それぞれをマージ
    histories.each_with_index do |h , i|
      song = h['song']
      karaoke = ak_map[h['attendance']]
      h.merge!(songs_info[song] || {})
      h.merge!(karaoke_info[karaoke] || {})
    end
    return histories
  end

  # get_karaoke - limitを指定するとその行数だけ取得
  #---------------------------------------------------------------------
  def get_karaoke(limit = 0)
    # 対象ユーザが参加したkaraokeのID一覧を取得
    db = DB.new(
      :SELECT => {'attendance.karaoke' => 'karaoke'} ,
      :FROM => 'attendance' ,
      :JOIN => ['attendance' , 'karaoke'],
      :WHERE => 'user = ?' , :SET => @params['id'] ,
      #:OPTION => (limit > 0) ? "LIMIT #{limit}" : 'ORDER BY karaoke.datetime DESC'
    )
    opt = ['ORDER BY karaoke.datetime DESC']
    opt += ["LIMIT #{limit}"] if limit > 0
    db.option(opt)
    attended_id_list = db.execute_all.collect {|info| info['karaoke']}

    # 全karaokeの情報から、ユーザが参加したカラオケについてのみ抽出
    all_karaoke_info = Karaoke.list_all
    attended_karaoke_info = all_karaoke_info.select do |karaoke|
      attended_id_list.include?(karaoke['id'])
    end
    return attended_karaoke_info
  end

  # get_most_sang_song - 最も歌っている曲を取得する 
  #---------------------------------------------------------------------
  def get_most_sang_song
    #Todo: インスタンス変数にする意味ある？
    @most_sang_song = DB.new(
      :SELECT => {'history.song' => 'song' , 'COUNT(*)' => 'counter'} ,
      :FROM => 'history' ,
      :JOIN => ['history' , 'attendance'] ,
      :WHERE => 'attendance.user = ?' ,
      :SET => @params['id'] ,
      :OPTION => ['GROUP BY song', 'ORDER BY counter DESC, history.created_at DESC']
    ).execute_row

		unless @most_sang_song.nil?  
			get_song @most_sang_song
		else
			@most_sang_song = {}
		end

    return @most_sang_song
  end

  # favorite_artists - よく歌う歌手を取得する
  #--------------------------------------------------------------------
  def favorite_artists(opt = {})
    attend_ids = self.attend_ids
    attend_ids.size > 0 or return []
    db = DB.new(
      :SELECT => {
        'artist.id' => 'artist_id',
        'artist.name' => 'artist_name',
        'count(artist.id)' => 'artist_count'
      },
      :FROM => 'history',
      :JOIN => [
        ['history' , 'song'],
        ['song' , 'artist'],
      ],
      :WHERE_IN => ['history.attendance' , attend_ids.length],
      :SET => attend_ids,
      :OPTION => ['GROUP BY artist.id' , 'ORDER BY artist_count DESC']
    )

    # オプション: 取得するアーティスの上限を設定
    if opt[:limit]
      db.option("limit #{opt[:limit]}")
    end
    artists = db.execute_all

    # オプション: 該当アーティスト全体の歌唱回数に対する割合を計算
    if opt[:want_rate]
      all_sang_count = artists.inject(0) {|sum , a| sum += a['artist_count']}
      artists.each {|a| a['artist_count_rate'] = (a['artist_count'].to_f / all_sang_count * 100).round(1)}
    end

    return artists
  end

  # get_max_score - 最高スコアとその曲情報を取得する 
  #---------------------------------------------------------------------
  def get_max_score
    db = DB.new(
      :SELECT => {
        'history.song' => 'song',
        'history.score_type' => 'score_type',
        'history.score' => 'score'
      } ,
      :FROM => 'history' ,
      :JOIN => ['history' , 'attendance'] ,
      :WHERE => 'attendance.user = ?' ,
      :OPTION => ['ORDER BY score DESC', 'LIMIT 1'],
      :SET => @params['id'] ,
    )
    @max_score_history = db.execute_row
		
    unless @max_score_history.nil?
			@max_score_history['scoretype_name'] = ScoreType.id_to_name(@max_score_history['score_type'])
			get_song @max_score_history
		else
			@max_score_history = {}
		end

    return @max_score_history
  end

  # addfriend - 友達を追加する
  #---------------------------------------------------------------------
  def addfriend(as_user)
    Friend.add(@params['id'] , as_user)
  end

  # get_friend_status - 指定したユーザとも友達関係を戻す
  # statusを指定した場合、そのstatusであるかを戻す
  #---------------------------------------------------------------------
  def get_friend_status(as_userid , as_status = nil)
    status = Friend.get_status(@params['id'] , as_userid)
    return as_status ? (status == as_status) : status
  end

  # friend_list - 友達関係のユーザ一覧を取得
  # statusを指定した場合、そのstatusのユーザのみ絞り込む
  #---------------------------------------------------------------------
  def friend_list(status = nil)
    friend_list = Friend.get_status(@params['id'])
    friend_info = User.id_to_name(friend_list.keys)
    friend_list.each do |userid , status|
      friend_info[userid] and friend_info[userid]['status'] = status
    end

    if status
      return friend_info.select {|k ,v| v['status'] == status}
    else
      return friend_info
    end
  end

  # timeline - 友達の最近のカラオケを取得する
  #---------------------------------------------------------------------
  def timeline(limit = 10)
    friends = self.friend_list(Util::Const::Friend::FRIEND)
    friends.empty? and return []
    timeline = DB.new(
      :SELECT => {
        'attendance.karaoke' => 'karaoke_id' ,
        'attendance.user' => 'user_id' ,
        'attendance.memo' => 'memo' ,
        'karaoke.datetime' => 'datetime' ,
        'karaoke.name' => 'name' ,
        'karaoke.plan' => 'plan' ,
      } ,
      :FROM => 'attendance' ,
      :JOIN => ['attendance' , 'karaoke'] ,
      :WHERE_IN => ['attendance.user' , friends.length] ,
      :SET => friends.keys ,
      :OPTION => ["ORDER BY karaoke.datetime DESC" , "LIMIT #{limit}"]
    ).execute_all

    timeline.each do |row|
      row['userinfo'] = friends[row['user_id']]
    end
    return timeline
  end

  # authenticate - クラスメソッド ユーザのIDとパスワードを検証する
  #---------------------------------------------------------------------
  def self.authenticate(name , pw)
    db = DB.new(:FROM => 'user' , :WHERE => ['username = ?' , 'password = ?'] , :SET => [name , pw])
    db.execute_row
  end

  # create - クラスメソッド ユーザを新規登録
  #---------------------------------------------------------------------
  def self.create(name , pw , screenname)
    result = validate_user_info(name , pw , screenname)
    (result[:result] == 'error') and return result

    db = DB.new(:FROM => 'user' , :WHERE => 'username = ?' , :SET => name)
    db.execute_row and return Util.error('そのユーザ名はすでに使われています。' , 'hash')
    Util.create_user_icon(name)

    DB.new(
      :INSERT => ['user' , ['username' , 'password' , 'screenname']] ,
      :SET => [name , pw , screenname] ,
    ).execute_insert_id

    return result
  end
  
  # validate_user_info - 入力されたユーザ情報がフォーマットに沿っているか確認する
  #---------------------------------------------------------------------
  def self.validate_user_info(name , password , screenname)
    Validate.is_in_range?(screenname , 2 , 16) or return Util.error('ニックネームは2文字以上16文字以下で入力してください。' , 'hash')
    Validate.include_special_character?(screenname) and return Util.error('<>$#%&"\'!はニックネームに使用できません。' , 'hash')
    Validate.is_username?(name) or return Util.error('ユーザ名は4文字以上16文字以下の半角英数字で入力してください。' , 'hash')
    Validate.is_password?(password) or return Util.error('パスワードは4文字以上の半角英数字で入力してください。' , 'hash')
    return {:result => 'successful'}
  end

  # id_to_name - クラスメソッド useridに対応するusername,screennameを戻す
  # 複数useridについてまとめて対応するので、基本的にUser.newでなくこちらを使う
  #---------------------------------------------------------------------
  def self.id_to_name(users)
    users.empty? and return []
    name_map = {}
    table = DB.new(
      :SELECT => ['id' , 'username' , 'screenname'] ,
      :FROM => 'user' ,
      :WHERE_IN => ["id" , users.length] ,
      :SET => users
    ).execute_all
    return Util.array_to_hash(table , 'id')
  end

  # register_karaoke - 入力されたカラオケをDBに登録する
  #---------------------------------------------------------------------
  def register_karaoke(karaoke , opt = {})
    register = Register.new(self)
    karaoke_id = register.create_karaoke(
      karaoke['datetime'], 
      karaoke['name'], 
      karaoke['plan'].to_f,
      {'name' => karaoke['store'], 'branch' => karaoke['branch']},
      Product.get(karaoke['product'])
    )
    karaoke_id
  end

  # register_attendance - 入力された出席情報をDBに登録する
  # attendanceの引数を与えないと値段、感想は空で登録できる
  #---------------------------------------------------------------------
  def register_attendance(karaoke_id, attendance = {})
    register = Register.new(self)
    register.set_karaoke karaoke_id
    register.attend_karaoke(attendance['price'] , attendance['memo'])
  end

  # register_history - 入力された歌唱履歴をDBに登録する
  #---------------------------------------------------------------------
  def register_history(karaoke_id , history , opt = {})
    register = Register.new(self)
    register.set_karaoke karaoke_id
    register.attend_karaoke
    if history['score_type'] > 0
      score_type = ScoreType.id_to_name(history['score_type'], :hash => true)
    else
      score_type = nil
      history['score'] = nil
    end

    register.create_history(
      history['song_name'],
      history['artist_name'],
      history['songkey'],
      score_type , 
      history['score']
    )
  end

  # attend_ids - 対応するattendanceの一覧を戻す
  # opt[:want_karaoke] - attendance.id => karaoke.id のハッシュに変換
  #---------------------------------------------------------------------
  def attend_ids(opt = {})
    attend = DB.new(
      :SELECT => ['id' , 'karaoke'],
      :FROM => 'attendance',
      :WHERE => 'user = ?',
      :SET => @params['id']
    ).execute_all
    if opt[:want_karaoke]
      attend
    else
      attend.map {|a| a['id']}
    end
  end

  # get_attendance_id_at_karaoke - カラオケIDを元に参加済みのattendanceのIDを取得する
  # 参加していないカラオケの場合はnilを返す
  #---------------------------------------------------------------------
  def get_attendance_at_karaoke(karaoke_id)
    attendance = DB.new(
      :SELECT => ['id' , 'price' , 'memo'] ,
      :FROM => 'attendance' ,
      :WHERE => ['user = ?' , 'karaoke = ?'] ,
      :SET => [@params['id'] , karaoke_id]
    ).execute_row

    return attendance
  end

  # twitter_account - Twitter認証済みの場合のみ、Twitterオブジェクトを戻す
  #--------------------------------------------------------------------
  def twitter_account
    twitter = Twitter.new(@params['username'])
    if twitter && twitter.authed
      @params['has_twitter'] = true
      return twitter
    else
      return nil
    end
  end

  # tweet - ツイッターに投稿する。設定、認証状態の確認も行う
  # 戻り値 Tweeted: 成功 Ineffective: 設定無効 InvalidAuth: 認証エラー
  #---------------------------------------------------------------------
  def tweet(text)
    if twitter = self.twitter_account
      twitter.tweet(text)
    end
    return twitter
  end

  # tweet_karaoke - ツイッターにカラオケについてツイートする
  #--------------------------------------------------------------------
  def tweet_karaoke(karaoke_id)
    tweet = "#{@params['screenname']}さんがカラオケに行きました"
    url = Util.url('karaoke' , 'detail' , karaoke_id)
    self.tweet("#{tweet} #{url}")
  end

  # tweet_history - ツイッターに歌唱履歴についてツイートする
  #--------------------------------------------------------------------
  def tweet_history(karaoke_id , history)
    tweet = "#{history['song_name']}(#{history['artist_name']})を歌いました"
    url = Util.url('karaoke' , 'detail' , karaoke_id)
    self.tweet("#{tweet} #{url}")
  end

  # search_songkey - 指定した楽曲の、前回歌唱時のキーを取得
  #--------------------------------------------------------------------
  def search_songkey(id)
    attend_ids = self.attend_ids
    attend_ids.empty? and return false
    DB.new(
      :SELECT => 'songkey',
      :FROM => 'history',
      :WHERE => 'song = ?',
      :WHERE_IN => ['attendance' , attend_ids.length],
      :SET => [id].concat(attend_ids),
      :OPTION => ['ORDER BY id DESC' , 'LIMIT 1']
    ).execute_column
  end

  private
  # get_song - history['song']を元に曲情報を取得する
  #---------------------------------------------------------------------
  def get_song(history)
    song = Song.new(history['song'])
    history['song_name'] = song.params['name']
    history['artist'] = song.params['artist']
    history['artist_name'] = song.params['artist_name']
  end

end
