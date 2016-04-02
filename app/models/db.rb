#----------------------------------------------------------------------
# DB - データベースに直接アクセスするクラス
#----------------------------------------------------------------------
require 'mysql'
require_relative 'util'
class DB

  @@db = nil
  
  # initialize - インスタンス生成
  #---------------------------------------------------------------------
  def initialize(arg = nil)
    @select = ''
    @distinct = false
    @from = ''
    @join = ''
    @where = []
    @insert = ''
    @update = ''
    @delete = false
    @option = ''
    @params = []
    if arg
      arg[:DISTINCT] and distinct()
      arg[:SELECT] and select(arg[:SELECT])
      arg[:FROM] and from(arg[:FROM])
      arg[:WHERE] and where(arg[:WHERE])
      arg[:WHERE_IN] and where_in(arg[:WHERE_IN])
      arg[:JOIN] and join(arg[:JOIN])
      arg[:INSERT] and insert(arg[:INSERT])
      arg[:UPDATE] and update(arg[:UPDATE])
      arg[:DELETE] and delete()
      arg[:OPTION] and option(arg[:OPTION])
      arg[:SET] and set(arg[:SET])
    end
  end

  # connect - mysqlサーバへの接続を行う
  #---------------------------------------------------------------------
  def self.connect
    @@db = Mysql.new('127.0.0.1' , 'root' , 'zenra' , 'march')
    @@db.charset = 'utf8'
  end

  # select - SELECT文を作成する
  # String / Array[String] / Hash[String => String]のみサポート
  #---------------------------------------------------------------------
  def select(params)
    hash = {}
    if params.kind_of?(Hash)
      hash = params
    elsif params.kind_of?(Array)
      params.each do |param|
        hash[param] = param
      end
    elsif params.kind_of?(String)
      hash[params] = params
    end

    selects = []
    hash.each do |key , val|
      selects.push "#{key} AS #{val}"
    end

    @select = @distinct ? "SELECT DISTINCT #{selects.join(',')}" : "SELECT #{selects.join(',')}"
  end

  # distinct - 重複列排除設定
  #---------------------------------------------------------------------
  def distinct
    @distinct = true
  end

  # from - FROM文を作成する
  # String のみサポート 複数表にまたがる場合はJOINを用いること
  #---------------------------------------------------------------------
  def from(param)
    @from = "FROM #{param}"
  end

  # where - WHERE分を作成する
  # String / Array[String] のみサポート
  #---------------------------------------------------------------------
  def where(params)
    params.kind_of?(String) and params = [params]
    @where.concat(params)
  end

  # where_in - WHEREのラッパーメソッド WHERE hoge in (? , ? , ?) を構築
  # [String , Integer] のみサポート
  #---------------------------------------------------------------------
  def where_in(params)
    key = params[0]
    num = params[1]
    qlist = Util.make_questions(num)
    where("#{key} in (#{qlist})")
  end

  # join - JOIN文を作成する
  # Array[String , String] / Array[Array[String , String]] のみサポート
  #---------------------------------------------------------------------
  def join(params)
    params[0].kind_of?(String) and params = [params]
    sql = []
    params.each do |set|
      sql.push  "JOIN #{set[1]} ON #{set[0]}.#{set[1]} = #{set[1]}.id"
    end
    @join = sql.join(' ')
  end

  # insert - INSERT文を作成する
  # [String , Array[String]] / [String , String] のみサポート
  #---------------------------------------------------------------------
  def insert(params)
    params[1].kind_of?(String) and params = [params[0] , [params[1]]]
    table = params[0]
    column_list = params[1]
    columns = column_list.join(',')
    questions = ('?' * column_list.size).split('').join(',') 
    @insert = "INSERT INTO #{table} (#{columns}) VALUES (#{questions})"
  end

  # update - UPDATE文を作成する
  # [tablename , [keys]] にて指定する
  #--------------------------------------------------------------------
  def update(params)
    table = params[0]
    keys = params[1].collect {|i| "#{i} = ?"}.join(',')
    values = Util.make_questions(params[1].size)
    @update = "UPDATE #{table} SET #{keys}"
  end

  # delete - DELETE文を作成する
  # 対象テーブルの指定にはFROM,条件設定はWHEREメソッドで行う
  #--------------------------------------------------------------------
  def delete
    @delete = true
  end

  # option - ORDER BY / LIMIT などその他の構文を作成
  # String / Array[String]
  # 複数回呼び出すと上書きでなく追記になる
  #---------------------------------------------------------------------
  def option(params)
    params.kind_of?(String) and params = [params]
    @option = [@option , params.join(' ')].join(' ')
  end

  # set - prepareに引き渡すパラメータをセットする
  # String / Array[String] のみサポート
  #---------------------------------------------------------------------
  def set(params)
    params.kind_of?(Array) or params = [params]
    @params.concat(params)
  end

  # execute_column - SQLを実行し、先頭行先頭列の値を戻す
  #---------------------------------------------------------------------
  def execute_column
    st = self.execute
    result = st.fetch_hash
    return nil if result.nil?
    return result.values.to_a[0]  
  end

  # execute_columns = SQKを実行し、先頭列の配列を戻す
  #---------------------------------------------------------------------
  def execute_columns
    st = self.execute
    result = []
    while (row = st.fetch_hash)
      result.push row.values.to_a[0]
    end
    return result
  end

  # execute_row - SQLを実行し、先頭行を戻す
  #---------------------------------------------------------------------
  def execute_row
    st = self.execute
    return st.fetch_hash
  end
  
  # execute_all - SQLを実行し、結果をハッシュ配列の形式で戻す
  #---------------------------------------------------------------------
  def execute_all
    result = []
    st = self.execute
    while (h = st.fetch_hash)
      result.push h
    end
    return result
  end

  # execute_insert_id - SQLを実行後、挿入レコードのIDを戻す
  #---------------------------------------------------------------------
  def execute_insert_id
    st = self.execute
    st.insert_id
  end

  # execute - SQLを実行する
  #---------------------------------------------------------------------
  def execute
    # 実行
    make
    st = @@db.prepare(@sql)
    st.execute(*@params)
    # ログ生成
    done_sql = @sql
    @params.each do |param|
      done_sql.sub!('?' , param.to_s)
    end
    Util.write_log('sql' , done_sql)
    return st
  end

  # get - 対象テーブルから特定のレコードを取得
  #---------------------------------------------------------------------
  def get(table , id)
    self.from(table)
    self.where('id = ?')
    self.set(id)
    self.execute_row
  end

  # all - 対象テーブルから全レコードを取得
  #---------------------------------------------------------------------
  def self.all(table)
    self.from(table)
    self.execute_all
  end

  # sql - SQLを実行
  #---------------------------------------------------------------------
  def self.sql(sql , params = [])
    @sql = sql
    @params = params
    execute_all
  end

  # make - SQL分を生成する
  #---------------------------------------------------------------------
  private
  def make
    where = @where.empty? ? "" : "where #{@where.join(' and ')}"
    if @insert.size > 0
      @sql = @insert
    elsif @update.size > 0
      @sql = @update
      where.size > 0 and @sql += " #{where}"
    elsif @delete
      @sql = ["DELETE" , @from , where].join(' ')
    else
      @select = @select.empty? ? 'SELECT *' : @select
      @sql = [@select , @from , @join , where , @option].join(' ')
    end
  end

end
