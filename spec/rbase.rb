require 'spec_helper'
module Rbase
	def login(id , pw = id)
		visit '/logout'
		fill_in 'username' , with: id
		fill_in 'password' , with: pw
		click_on 'ログイン'
	end

	def iscontain(content)
		expect(page).to have_content content
	end

	def islack(content)
		expect(page).to (have_no_content content)
	end
end
