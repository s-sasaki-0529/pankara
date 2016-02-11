#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class History < Base

	# recent_song - 最近歌われた楽曲のリストを戻す
	#---------------------------------------------------------------------
	def self.recent_song(limit = 20)
		songs = DB.new(
			:DISTINCT => true ,
			:SELECT => {
					'song.id' => 'id' ,
					'song.name' => 'name' ,
					'song.url' => 'url'
			} ,
			:FROM => 'history' ,
			:JOIN => ['history' , 'song'] ,
			:WHERE => 'song.url IS NOT NULL' ,
			:OPTION => ['ORDER BY history.created_at DESC' , "LIMIT #{limit}"]
		).execute_all #現在はURLがyoutubeであることが前提。今後はプレーヤー化できるかの情報も必要になる
		songs.empty? and return []

		while songs.length < limit
			songs = (songs + songs).each_slice(limit).to_a[0]
		end
		return songs
	end

end
