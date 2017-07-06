require 'uri'
require 'spec_helper'
require_relative '../app/models/util'
module Rbase

  # ログインする
  def login(id , pw = '')
    visit '/auth/logout'
    fill_in 'username' , with: id
    fill_in 'password' , with: pw
    find('#login_button').click
  end

  # ログアウトする
  def logout
    visit '/auth/logout'
  end

  # 指定した文字列がページ内に含まれていることを検証する
  def iscontain(contents)
    islack "You're seeing this error because you have enabled the show_exceptions setting."
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

  # 指定したclassを持つ要素のtextを検証する
  def examine_text_by_class(_class , text)
    expect(page.find("." + _class).text).to eq text
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

  # 指定した要素が存在しないことを検証
  # Todo すこぶる遅いので別な方法を考える
  def cant_find(selecter)
    expect { find(selecter) }.to raise_error(Capybara::ElementNotFound)
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

  # カラオケ名にカラオケ詳細ページへのリンクが設定されているかを検証する
  def examine_karaokelink(name , referer = nil)
    link name
    expect(page.all('h2')[0].text).to eq name
    referer and visit referer
  end

  # 歌唱履歴詳細画面へのリンクが設定されているかを検証する
  def examine_historylink(user_name , karaoke_name , song_name)
    iscontain '歌唱履歴詳細'
    table = table_to_array('history_detail')
    expect(table[0][1]).to eq user_name
    expect(table[1][1]).to eq karaoke_name
    expect(table[6][1]).to eq song_name
  end

  # 現在のパスを検証
  def current_path_is(path)
    expect(current_path).to eq path
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

  # JavaScriptを実行(戻り値を取らないが高速)
  def js(script)
    execute_script script
    wait_for_ajax
  end

  # JavaScriptを実行(戻り値を取るが低速)
  def ejs(script)
    result = evaluate_script script
    wait_for_ajax
    return result
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
