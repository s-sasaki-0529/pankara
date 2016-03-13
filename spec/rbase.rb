require 'spec_helper'
require_relative '../app/models/util'
module Rbase
  def login(id , pw = id)
    visit '/logout'
    fill_in 'username' , with: id
    fill_in 'password' , with: pw
    find('#login_button').click
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
    url = page.all('a' , :text => text)[0]['href']
    visit url
  end

  def examine_text(id , text)
    expect(page.find("#" + id).text).to eq text
  end

  def id_to_element(id)
    page.find("\##{id}")
  end

  def class_to_elements(classname)
    page.all(".#{classname}")
  end

  def examine_songlink(name , artist , referer = nil)
    link name
    iscontain "#{name} / #{artist}"
    referer and visit referer
  end

  def examine_artistlink(name , referer = nil)
    link name
    iscontain [name , 'この歌手の楽曲一覧']
    referer and visit referer
  end

  def examine_userlink(name , referer = nil)
    href = page.all('.userlink').select {|i| i.text == name}[0]['href']
    visit href
    iscontain "#{name}さんのユーザページ"
    referer and visit referer
  end

  def examine_karaokelink(name , referer = nil)
    link name
    iscontain name #あんまよくないこれ
    referer and visit referer
  end

  def table_to_hash(id)
    ary = page.find("table[id='#{id}']").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
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

  def thumbnail_list
    page.all('.thumbnail').collect {|element| element['src']}
  end

  def input_karaoke
    page.find('#name')
    fill_in 'name', with: '入力ダイアログテスト用カラオケ'
    fill_in 'datetime', with: '2016-02-20 12:00:00'
    select '02時間00分', from: 'plan'
    fill_in 'store', with: '歌広場'
    fill_in 'branch', with: '相模大野店'
    select 'JOYSOUND MAX', from: 'product'
    fill_in 'price', with: '620'
    fill_in 'memo', with: '楽しかった'
  end

  def input_history_with_data(history, num = 0)
    page.find('#song')
    fill_in 'song', with: history['song']
    fill_in 'artist', with: history['artist']
    select history['score_type'], from: 'score_type'
    fill_in 'score', with: history['score']
  end
  
  def input_history(value = 0)
    page.find('#song')
    score = 0 + value
    score = 100 if score > 100
    fill_in 'song', with: "song#{value}"
    fill_in 'artist', with: "artist#{value}"
    select 'JOYSOUND 全国採点', from: 'score_type'
    fill_in 'score', with: score
  end

  # 以下、ajax対応
  def js(script)
    execute_script script
    wait_for_ajax
  end

  def wait_for_ajax
    Timeout.timeout(default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    result = page.evaluate_script('jQuery.active')
    result.nil? ? false : result.zero?
  end

  def default_wait_time
    Capybara.respond_to?(:default_max_wait_time) ? Capybara.default_max_wait_time : Capybara.default_wait_time
  end

end
