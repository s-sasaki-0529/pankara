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
require_relative 'score_type'
require_relative 'user'
require_relative 'register'
require 'uri'
require 'open-uri'
class Util

	# icon_file - ユーザ名を指定し、アイコンファイルのパスを取得する
	#----------------------------------------------------------------------
	def self.icon_file(username)
		user_icon = "/image/user_icon/#{username}.png"
		sample_icon = "/image/sample_icon.png"
		File.exist?("app/public/#{user_icon}") ? user_icon : sample_icon
	end

	# search_tube - 曲名と歌手名を指定し、Youtube動画のURLを取得する
	#----------------------------------------------------------------------
	def self.search_tube(song , artist)
		word = "#{song} #{artist}"
		uri = URI.escape("https://www.youtube.com/results?search_query=#{word}")
		html = open(uri) do |f|
			charset = f.charset
			f.read
		end
		html.scan(%r|"/watch\?v=(\w+?)"|) do
			return "https://www.youtube.com/watch?v=#{$1}"
		end
		return nil
	end

	# write_log - ログを生成する
	#---------------------------------------------------------------------
	def self.write_log(type , log)
		filepath = {
			'sql' => 'logs/sql.log'
		}[type] or return
		datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

		File.open(filepath , 'a') do |f|
			f.puts "---#{datetime}---"
			f.puts log
			f.puts "----------------------"
		end
	end

	# debug - 標準出力
	#--------------------------------------------------------------------
	def self.debug(v)
		require 'pp'
		puts "\n---debug---"
		pp v
		puts "-----------"
	end
end
