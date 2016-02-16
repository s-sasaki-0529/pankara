require_relative './march'

class LocalRoute < March

	# post '/local/rpc/storelist' - 店と店舗のリストをJSONで戻す
	#---------------------------------------------------------------------
	post '/local/rpc/storelist' do
		Util.to_json(Store.list)
	end

end
