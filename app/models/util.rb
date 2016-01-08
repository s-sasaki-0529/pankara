#----------------------------------------------------------------------
# Util - 汎用ライブラリ
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'base'
require_relative 'artist'
require_relative 'history'
require_relative 'karaoke'
require_relative 'product'
require_relative 'song'
require_relative 'store'
require_relative 'user'
require 'uri'
require 'open-uri'

# search_tube - 曲名と歌手名を指定し、Youtube動画のURLを取得する
#----------------------------------------------------------------------
def search_tube(song , artist)
	word = "#{song} #{artist}"
	uri = URI.escape("https://www.youtube.com/results?search_query=#{word}")
	html = open(uri) do |f|
		charset = f.charset
		f.read
	end
	html.scan(%r|"/watch\?v=(\w+?)"|) do
		return "https://www.youtube.com/watch?v=#{$1}"
	end
end
