#----------------------------------------------------------------------
# Karaoke - カラオケ記録に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Karaoke < Base

  attr_reader :histories

  # initialize - インスタンスを生成し、機種名、店舗名を取得する
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('karaoke' , id)
    @params or return nil

    product = Product.new(@params['product'])
    @params['product_name'] = "#{product.params['brand']}(#{product.params['product']})"

    store = Store.new(@params['store'])
    @params['store_name'] = store.params['name']
    @params['branch_name'] = store.params['branch']
    @params['store_full_name'] = "#{store.params['name']} #{store.params['branch']}"
  end

  # list_all - カラオケ記録の一覧を全て取得し、店舗名まで取得する
  #---------------------------------------------------------------------
  def self.list_all()
    DB.new(
      :SELECT =>  {
        'karaoke.id' => 'id' ,
        'karaoke.name' => 'name' ,
        'karaoke.datetime' => 'datetime' ,
        'karaoke.plan' => 'plan' ,
        'karaoke.store' => 'store' ,
        'karaoke.product' => 'product_id' ,
        'store.name' => 'store_name' ,
        'store.branch' => 'branch_name' ,
        'product.brand' => 'brand_name' ,
        'product.product' => 'product_name'
      } ,
      :FROM => 'karaoke' ,
      :JOIN => [
        ['karaoke' , 'store'] ,
        ['karaoke' , 'product'] ,
      ] ,
      :OPTION => 'ORDER BY datetime DESC'
    ).execute_all
  end

  # modify - カラオケレコードを修正する
  #---------------------------------------------------------------------
  def modify(arg)

    # 店名と店舗名の指定がある場合、storeに置き換える
    if  arg['store_name'] && arg['store_branch']
      r = Register.new
      arg['store'] = r.create_store({'name' => arg['store_name'] ,'branch' => arg['store_branch']})
    end

    arg.select! do |k , v| 
      ['name' , 'datetime' , 'plan' , 'store' , 'product'].include?(k)
    end
    DB.new(
      :UPDATE => ['karaoke' , arg.keys] , 
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute
    @params = DB.new.get('karaoke' , @params['id'])
  end

  # delete - カラオケレコードを削除する
  #--------------------------------------------------------------------
  def delete

    # 参照されているattendanceレコードを削除する
    attendances = DB.new(
      :SELECT => {'attendance.id' => 'id'} ,
      :FROM => 'attendance' ,
      :JOIN => ['attendance' , 'karaoke'] ,
      :WHERE => 'karaoke.id = ?' ,
      :SET => @params['id']
    ).execute_columns
    attendances.each do |id|
      attendance = Attendance.new(id)
      attendance.delete
    end

    # karaokeレコードを削除する
    DB.new(:DELETE => 1 , :FROM => 'karaoke' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    @params = nil

  end

  # get_history - カラオケ記録に対応した歌唱履歴を取得する
  #---------------------------------------------------------------------
  def get_history
    #Todo: ３テーブルのJOINは効率悪すぎる。参加ユーザを取得するメソッドを実装すべき
    @histories = DB.new(
      :SELECT => {
        'history.id' => 'history_id' ,
        'history.created_at' => 'history_datetime' ,
        'history.song' => 'song' ,
        'history.songkey' => 'songkey' ,
        'history.score_type' => 'score_type' ,
        'history.score' => 'score',
        'attendance.id' => 'attendance'
      } ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'attendance'] ,
        ['attendance' , 'karaoke']
      ] ,
      :WHERE => 'attendance.karaoke = ?' ,
      :SET => @params['id'] ,
      :OPTION => 'ORDER BY karaoke.datetime DESC'
    ).execute_all

    # karaokeに参加しているユーザ一覧を取得
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
    @params['members'] = users_info

    # historiesに含まれる楽曲情報を取得
    # Todo: ここループでSong.newしててクッソ無駄
    @histories.each do | history |
      song = Song.new(history['song'])
      history['song_id'] = song.params['id']
      history['song_name'] = song.params['name']
      history['song_url'] = song.params['url']
      history['artist_id'] = song.params['artist']
      history['artist_name'] = song.params['artist_name']
      history['userinfo'] = users_info.find { |user| user['attendance'] == history['attendance'] }
      history['scoretype_name'] = ScoreType.id_to_name(history['score_type'])
    end
  end
end
