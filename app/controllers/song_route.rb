require_relative '../march'

class SongRoute < March

	# get '/song/:id' - 曲情報を表示
	#---------------------------------------------------------------------
	get '/song/:id' do
		score_type = 1 #現在は仮で固定
		@song = Song.new(params[:id])
		@song.count_all
		@song.score_all(score_type)
		@song.sang_history_all
		@my_sangcount = @song.count_as(@current_user.params['id'])
		@my_score = @song.score_as(score_type , @current_user.params['id'])
		@my_sang_history = @song.sang_history_as(@current_user.params['id'])
		template :song_detail
	end

	
end
