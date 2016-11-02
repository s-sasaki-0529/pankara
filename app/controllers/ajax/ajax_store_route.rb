require_relative 'ajax_route'

class AjaxStoreRoute < AjaxRoute

  # post '/ajax/store/list' - 店と店舗のリストをJSONで戻す
  #---------------------------------------------------------------------
  post '/list/?' do
    success(Store.list)
  end

end
