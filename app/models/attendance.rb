#----------------------------------------------------------------------
# ScoreType - 採点モードに関する情報
#----------------------------------------------------------------------
require_relative 'util'
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
    DB.new(
      :UPDATE => ['attendance' , arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute
    @params = DB.new.get('attendance' , @params['id'])
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
    ).execute_columns
    DB.new(
      :DELETE => 1 ,
      :FROM => 'history' ,
      :WHERE_IN => ['id' , histories.length] ,
      :SET => histories
    ).execute

    #attendanceレコードを削除
    DB.new(:DELETE => 1 , :FROM => 'attendance' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    @params = nil

  end

end
