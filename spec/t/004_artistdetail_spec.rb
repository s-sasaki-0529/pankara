require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_14_21_21`
  `zenra mysql -e "update song set artist = 1 where id > 100"`
  `zenra mysql -e "update song set url = NULL where id = 115"`
end

# テスト実行
describe '歌手詳細ページ' , :js => true do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit '/history'
  end

  describe 'Wikipediaが正常に読み込まれるか' do
    it '記事が存在する' do
      visit '/artist/40' #水樹奈々
      wait_for_ajax
      iscontain '(Wikipedia引用)'
    end
    it '記事が存在しない' do
      visit '/artist/32' #kemu
      wait_for_ajax
      islack '(Wikipedia引用)'
    end
  end

  describe 'よく歌われる楽曲グラフ' do
    it 'その他あり' do
      visit '/artist/1' #BUMP OF CHICKEN
      wait_for_ajax
      json = '[[["Hello, world!"],[8]],[["ray"],[6]],[["MISTAKE"],[5]],[["さよならのかわりに、花束を"],[4]],[["BAYONET CHARGE"],[4]],[["吉原ラメント"],[3]],[["オーバーキルサイズ・ヘル"],[3]],[["tomorrow"],[3]],["その他",205]]'
      expect(evaluate_script("$('#songs_chart_json').text();")).to eq json
    end
    it 'その他なし' do
      visit '/artist/32' #kemu
      wait_for_ajax
      expect(evaluate_script("$('#songs_chart_json').text();")).to eq '[[["地球最後の告白を"],[3]],[["敗北の少年"],[2]],[["カミサマネジマキ"],[2]]]'
    end
  end

  describe '歌唱回数グラフ' do
    it '一人だけ歌っている' do
      visit '/artist/70' #暁切歌
      wait_for_ajax
      json = evaluate_script("$('#sang_count_chart_json').text();")
      expect(json).to eq '{"result":"success","info":[{"_month":"2016-08"},{"_month":"2016-07"},{"_month":"2016-06"},{"_month":"2016-05"},{"_month":"2016-04"},{"ともちん":2,"_month":"2016-03"},{"_month":"2016-02"},{"ともちん":4,"_month":"2016-01"}]}'
    end
    it '複数人が歌っている' do
      visit '/artist/40' #水樹奈々
      wait_for_ajax
      json = evaluate_script("$('#sang_count_chart_json').text();")
      expect(json).to eq '{"result":"success","info":[{"_month":"2016-08"},{"_month":"2016-07"},{"_month":"2016-06"},{"_month":"2016-05"},{"_month":"2016-04"},{"_month":"2016-03"},{"_month":"2016-02"},{"ウォーリー":2,"ともちん":1,"_month":"2016-01"}]}'
    end
  end

  it '歌手の楽曲一覧が正常に表示されるか' do
    examine_artistlink 'BUMP OF CHICKEN'
    tables = table_to_hash('artistdetail_table')
    expect(tables.length).to eq 174
    expect(tables[0]['tostring']).to eq ',オンリーロンリーグローリー,2,0'
    expect(tables[18]['tostring']).to eq '未登録,たったひとつの日々,0,2'
  end

  it 'リンクが正常に登録されているか' do
    visit '/history'
    examine_artistlink('BUMP OF CHICKEN')
    url = page.current_url
    songs = ['走れ' , '君に届け' , 'ロミオとシンデレラ']
    songs.each do |song|
      examine_songlink(song , 'BUMP OF CHICKEN' , url)
    end
  end
end
