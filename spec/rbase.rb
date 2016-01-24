require 'spec_helper'
require_relative '../app/models/util'
module Rbase
	def login(id , pw = id)
		visit '/logout'
		fill_in 'username' , with: id
		fill_in 'password' , with: pw
		click_on 'ログイン'
	end

	def iscontain(contents)
		contents = [contents] if contents.kind_of?(String)
		contents.each do |content|
			expect(page).to have_content content
		end
	end

	def islack(*contents)
		contents = [contents] if contents.kind_of?(String)
		contents.each do |content|
			expect(page).to (have_no_content content)
		end
	end

	def id_to_element(id)
		page.find("#" + id)
	end

	def class_to_elements(classname)
		page.all(".#{classname}")
	end

	def examine_songlink(name , artist)
		page.all('a' , :text => name)[0].click
		iscontain "#{name} / #{artist}"
	end

	def examine_artistlink(name)
		page.all('a' , :text => name)[0].click
		iscontain [name , 'この歌手の楽曲一覧']
	end

	def table_to_hash(id)
		ary = page.find("table[@id=#{id}]").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
		header = ary.shift
		list = []
		ary.each do |row|
			hash = {}
			row.each_with_index do |val , idx|
				hash[header[idx]] = val
			end
			hash['tostring'] = row.join(',')
			list.push hash
		end
		list
	end

	def youtube_links
		page.all('iframe').collect {|element| element[:src]}
	end

	def debug(v)
		require 'pp'
		puts "\n----debug----"
		pp v
		puts "-------------"
	end
end
