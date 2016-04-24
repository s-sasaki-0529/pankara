#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class User < Base

  # initialize(user) - usernameをインスタンスを生成
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
    @params and reset_input_info
  end

  # histories - 歌唱履歴を取得、limitを指定するとその行数だけ取得
  #---------------------------------------------------------------------
  def histories(limit = 0)
    db = DB.new(
      :SELECT => {
        'karaoke.id' => 'karaoke_id' ,
        'karaoke.name' => 'karaoke_name' ,
        'karaoke.datetime' => 'datetime' ,
        'history.song' => 'song' ,
        'history.songkey' => 'songkey'
      } ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'attendance'] ,
        ['attendance' , 'karaoke']
      ] ,
      :WHERE => 'attendance.user = ?' ,
      :SET => @params['id'] ,
      :OPTION => 'ORDER BY datetime DESC' ,
    )
    db.option("LIMIT #{limit}") if limit > 0
    histories = db.execute_all
    histories.each do | history |
      song = Song.new(history['song'])
      history['song_name'] = song.params['name']
      history['artist'] = song.params['artist']
      history['artist_name'] = song.params['artist_name']
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

  # get_most_sang_artist - 最も歌っている歌手を取得する 
  #---------------------------------------------------------------------
  def get_most_sang_artist
    @most_sang_artist = DB.new(
      :SELECT => {'song.artist' => 'artist', 'COUNT(*)' => 'counter'} ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'attendance'] ,
        ['history' , 'song'] ,
      ] ,
      :WHERE => 'attendance.user = ?' ,
      :SET => @params['id'] ,
      :OPTION => ['GROUP BY artist', 'ORDER BY counter DESC, history.created_at DESC'] ,
    ).execute_row

		unless @most_sang_artist.nil?
			@most_sang_artist['artist_name'] = DB.new(
				:SELECT => 'name' , :FROM => 'artist' , :WHERE => 'id = ?' , :SET => @most_sang_artist['artist']
			).execute_column
		else
			@most_sang_artist = {}
		end

    return @most_sang_artist
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
    db = DB.new(:FROM => 'user' , :WHERE => 'username = ?' , :SET => name)
    db.execute_row and return

    DB.new(
      :INSERT => ['user' , ['username' , 'password' , 'screenname']] ,
      :SET => [name , pw , screenname] ,
    ).execute_insert_id
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
  def register_karaoke(karaoke)
    karaoke_id = @register.create_karaoke(
      karaoke['datetime'], 
      karaoke['name'], 
      karaoke['plan'].to_f,
      {'name' => karaoke['store'], 'branch' => karaoke['branch']},
      Product.get(karaoke['product'])
    )
    karaoke_id
  end

  # register_attendance - 入力された出席情報をDBに登録する
  #---------------------------------------------------------------------
  def register_attendance(karaoke_id, attendance)
    @register.set_karaoke karaoke_id
    @register.attend_karaoke(attendance['price'] , attendance['memo'])
  end

  # register_history - 入力された歌唱履歴をDBに登録する
  #---------------------------------------------------------------------
  def register_history(karaoke_id, history)
    @register.set_karaoke karaoke_id
    @register.attend_karaoke

    if history['score_type'] > 0
      score_type = ScoreType.id_to_name(history['score_type'], true)
    else
      score_type = nil
      history['score'] = nil
    end

    @register.create_history(
      history['song'],  
      history['artist'], 
      history['songkey'], 
      score_type , 
      history['score']
    )
  end

  # attend_ids - 対応するattendanceの一覧を戻す
  #---------------------------------------------------------------------
  def attend_ids
    DB.new(
      :SELECT => 'id',
      :FROM => 'attendance',
      :WHERE => 'user = ?',
      :SET => @params['id']
    ).execute_columns
  end

  # attended? - カラオケにすでに参加済みか確認する
  #---------------------------------------------------------------------
  def attended?(karaoke_id)
    attended = DB.new(
      :SELECT => ['id'] ,
      :FROM => 'attendance' ,
      :WHERE => ['user = ?' , 'karaoke = ?'] ,
      :SET => [@params['id'] , karaoke_id]
    ).execute_column

    return attended.nil? ? false : true
  end

  # tweet - ツイッターに投稿する。設定、認証状態の確認も行う
  # 戻り値 Tweeted: 成功 Ineffective: 設定無効 InvalidAuth: 認証エラー
  #---------------------------------------------------------------------
  def tweet(text)
    twitter = Twitter.new(self)
    if twitter && twitter.authed
      twitter.tweet(text)
      return 'Tweeted'
    else
      return 'InvalidAuth'
    end
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

  private
  # reset_input_info - 入力情報を初期化する
  #---------------------------------------------------------------------
  def reset_input_info
    @register = Register.new(self)
    @register.with_url = true
    @karaoke_id = 0
  end

end
