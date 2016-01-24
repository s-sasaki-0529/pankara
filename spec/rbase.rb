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
end
