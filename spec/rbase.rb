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

	def link(text)
		page.all('a' , :text => text)[0].click
	end

	def examine_text(id , text)
		expect(page.find("#" + id).text).to eq text
	end

	def class_to_elements(classname)
		page.all(".#{classname}")
	end

	def examine_songlink(name , artist , referer = false)
		link name
		iscontain "#{name} / #{artist}"
		referer and visit referer
	end

	def examine_artistlink(name , referer = false)
		link name
		iscontain [name , 'この歌手の楽曲一覧']
		referer and visit referer
	end

	def examine_userlink(name , referer = false)
		link name
		iscontain "#{name}さんのユーザページ"
		referer and visit referer
	end

	def examine_karaokelink(name , referer = false)
		link name
		iscontain name #あんまよくないこれ
		referer and visit referer
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

end
