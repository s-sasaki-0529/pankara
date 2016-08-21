#----------------------------------------------------------------------
# ScoreType - 採点モードに関する情報
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class Attendance < Base

  # initialize イニシャライズ
  #....................................................................
  def initialize(id)
    @params = DB.new.get('attendance' , id)
  end

  # modify - attendanceレコードを修正する
  #--------------------------------------------------------------------
  def modify(arg)
    arg.select! do |k , v|
      ['price' , 'memo'].include?(k)
    end

    arg['price'] and arg['price'] == '' and arg['price'] = nil
    arg['memo'] and arg['memo'] == '' and arg['memo'] = nil

    result = DB.new(
      :UPDATE => ['attendance' , arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute

    if result
      old_params = @params
      @params = DB.new.get('attendance' , old_params['id'])
      Util.write_log('event' , "【参加情報修正】#{old_params} → #{@params}")
      return true
    else
      return false
    end
  end

  # delete - レコードを削除
  #....................................................................
  def delete
    # 参照しているhistoryから削除する
    histories = DB.new(
      :SELECT => {'history.id' => 'id'} ,
      :FROM => 'history' ,
      :JOIN => ['history' , 'attendance'] ,
      :WHERE => 'attendance.id = ?' ,
      :SET => @params['id'] ,
    ).execute_columns or return false
    if histories.size > 0
      DB.new(
        :DELETE => 1 ,
        :FROM => 'history' ,
        :WHERE_IN => ['id' , histories.length] ,
        :SET => histories
      ).execute or return false
    end
    #attendanceレコードを削除
    DB.new(:DELETE => 1 , :FROM => 'attendance' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    @params = nil
    return true
  end

  # self.to_user_info - attendanceのリストを渡すと、それぞれのユーザ情報を取得する
  #--------------------------------------------------------------------
  def self.to_user_info(attend_list)
    user_info = DB.new(
      :SELECT => {
        'user.id' => 'user_id',
        'user.username' => 'user_name',
        'user.screenname' => 'user_screenname',
        'attendance.id' => 'attendance'
      },
      :FROM => 'user',
      :FLEXIBLE_JOIN => {:target => 'attendance', :from => 'attendance', :to => 'user'},
      :WHERE_IN => ['attendance.id' , attend_list.length],
      :SET => attend_list
    ).execute_all
    user_info.empty? and return false
    return user_info
  end

  # self.to_karaoke_info - attendanceのリストを渡すと、それぞれのカラオケ情報を取得する
  #--------------------------------------------------------------------
  def self.to_karaoke_info(attend_list)
    karaoke_info = DB.new(
      :SELECT => {'karaoke.datetime' => 'datetime', 'attendance.id' => 'attendance'},
      :FROM => 'karaoke',
      :FLEXIBLE_JOIN => {:target => 'attendance', :from => 'attendance', :to => 'karaoke'},
      :WHERE_IN => ['attendance.id' , attend_list.length],
      :SET => attend_list
    ).execute_all
    karaoke_info.empty? and return false
    return karaoke_info
  end

end
