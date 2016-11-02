require_relative 'ajax_route'

class AjaxAttendanceRoute < AjaxRoute

  # post '/ajax/attendance/modify/?' - 参加情報を編集する
  #--------------------------------------------------------------------
  post '/modify/?' do
    attendance_info = @current_user.get_attendance_at_karaoke(params[:id])
    attendance_info or return error('not found attendance')

    attendance = Attendance.new(attendance_info['id'])
    arg = Util.to_hash(params[:params])
    result = attendance.modify(arg)

    return result ? success : error('modify failed')
  end

  # post '/ajax/attendance/create' - 参加情報を値段と感想は空のまま登録する
  #---------------------------------------------------------------------
  post '/create' do
    attendance = {}
    karaoke_id = params[:karaoke_id]

    if @current_user
      @current_user.register_attendance karaoke_id
      success
    else
      error('invalid current user')
    end
  end

end
