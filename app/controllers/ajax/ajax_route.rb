require_relative '../march'
require_relative '../../models/product'
require_relative '../../models/score_type'
require_relative '../../models/song'
require_relative '../../models/artist'
require_relative '../../models/karaoke'
require_relative '../../models/history'
require_relative '../../models/register'
require_relative '../../models/attendance'

class AjaxRoute < March

  # success - 正常を通知するJSONを戻す
  #--------------------------------------------------------------------
  def success(data = nil)
    return Util.to_json({:result => 'success' , :info => data})
  end

  # error - 異常を通知するJSONを戻す
  #--------------------------------------------------------------------
  def error(info = '')
    return Util.to_json({:result => 'error' , :info => info})
  end

end
