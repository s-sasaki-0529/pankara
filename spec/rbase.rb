require 'spec_helper'
require_relative '../app/models/util'
module Rbase

  # ログインする
  def login(id , pw = id)
    visit '/auth/logout'
    fill_in 'username' , with: id
    fill_in 'password' , with: pw
    find('#login_button').click
  end

  # 指定した文字列がページ内に含まれていることを検証する
  def iscontain(contents)
    contents = [contents] if contents.kind_of?(String)
    contents.each do |content|
      expect(page).to have_content content
    end
  end

  # 指定した文字列がページ内に含まれていることを検証する
  def islack(*contents)
    contents = [contents] if contents.kind_of?(String)
    contents.each do |content|
      expect(page).to (have_no_content content)
    end
  end

  # 指定したテキストを含むリンクを踏む
  def link(text)
    url = page.all('a' , :text => text)[0]['href']
    visit url
  end

  # 指定したテキストを持つリンクを踏む
  def link_strictly(text)
    url = page.all('a' , :text => text).select {|e| e.text == text}[0]['href']
    visit url
  end

  # 指定したIDを持つ要素のtextを検証する
  def examine_text(id , text)
    expect(page.find("#" + id).text).to eq text
  end

  # 指定したIDを持つ要素のvalueを検証する
  def examine_value(id , value)
    expect(page.find("#" + id).value).to eq value
  end

  # 指定したIDを持つ要素を取得
  def id_to_element(id)
    page.find("\##{id}")
  end

  # 指定したclassを持つ要素を取得
  def class_to_elements(classname)
    page.all(".#{classname}")
  end

  # 曲名に楽曲詳細ページへのリンクが設定されているかを検証する
  def examine_songlink(name , artist , referer = nil)
    link name
    expect(current_url.scan(%r|song/.+$|).empty?).to eq false
    iscontain [name , artist]
    referer and visit referer
  end

  # 歌手名に歌手詳細ページへのリンクが設定されているかを検証する
  def examine_artistlink(name , referer = nil)
    link name
    iscontain [name , 'この歌手の楽曲一覧']
    referer and visit referer
  end

  # ユーザ名にユーザページへのリンクが設定されているかを検証する
  def examine_userlink(name , referer = nil)
    href = page.all('.userlink').select {|i| i.text == name}[0]['href']
    visit href
    iscontain "#{name}"
    referer and visit referer
  end

  # カラオケ名にカラオケ詳細ページへのリンクが設定されているかを確認する
  def examine_karaokelink(name , referer = nil)
    link name
    expect(page.all('h3')[0].text).to eq name
    referer and visit referer
  end

  # 指定したIDを持つテーブル要素を、行列の二次元配列に変換する
  def table_to_array(id)
    page.find("table[id='#{id}']").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
  end

  # 指定したIDを持つテーブル要素を、ヘッダー行をキーとしたハッシュ配列に変換する
  def table_to_hash(id)
    ary = table_to_array(id)
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

  # ページ内に含まれるyoutubeプレイヤーのURLの一覧を取得
  def youtube_links
    page.all('iframe').collect {|element| element[:src]}
  end

  # ページ内に含まれるyoutubeサムネイルのリンク先一覧を取得
  def thumbnail_list
    page.all('.thumbnail').collect {|element| element['src']}
  end

  # Todo: 汎用性が皆無なので、使用しているテストに移動する
  def input_karaoke
    page.find('#name')
    fill_in 'name', with: '入力ダイアログテスト用カラオケ'
    fill_in 'datetime', with: '2016-02-20 12:00:00'
    select '02時間00分', from: 'plan'
    fill_in 'store', with: '歌広場'
    fill_in 'branch', with: '相模大野店'
    select 'JOYSOUND MAX', from: 'product'
  end

  # Todo: 汎用性が皆無なので、使用しているテストに移動する
  def input_history_with_data(history, num = 0)
    page.find('#song')
    fill_in 'song', with: history['song']
    fill_in 'artist', with: history['artist']
    select history['score_type'], from: 'score_type'
    fill_in 'score', with: history['score']
    wait_for_ajax
  end
  
  # Todo: 汎用性が皆無なので、使用しているテストに移動する
  def input_history(song_value = 0 , artist_value = song_value , score_value = artist_value)
    page.find('#song')
    score = 0 + score_value
    score = 100 if score > 100
    fill_in 'song', with: "song#{song_value}"
    fill_in 'artist', with: "artist#{artist_value}"
    select 'JOYSOUND 全国採点', from: 'score_type'
    fill_in 'score', with: score
    wait_for_ajax
  end

  # JavaScriptを実行
  def js(script)
    execute_script script
    wait_for_ajax
  end

  # JavaScriptの非同期処理が完了するまで待機
  def wait_for_ajax
    Timeout.timeout(default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  # JavaScriptの非同期処理の状態を取得
  def finished_all_ajax_requests?
    result = page.evaluate_script('jQuery.active')
    result.nil? ? false : result.zero?
  end

  # JavaScriptの非同期処理を待つ最大時間を取得
  def default_wait_time
    Capybara.respond_to?(:default_max_wait_time) ? Capybara.default_max_wait_time : Capybara.default_wait_time
  end

end
