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

  def to_hash(id)
    js = "$('##{id}').text();"
    json = ejs(js)
    return Util.to_hash(json)
  end


  before(:all,&init)
  before do
    login 'sa2knight'
    visit '/history/list'
  end

  describe 'Wikipediaが正常に読み込まれるか' do
    it '記事が存在する' do
      visit '/artist/40' #水樹奈々
      wait_for_ajax
      iscontain '(Wikipedia引用)'
    end
    it '記事が存在する(リダイレクト)' do
      visit '/artist/22' #ST☆RISH
      wait_for_ajax
      iscontain 'うたの☆プリンスさまっ♪'
    end
    it '記事が存在しない' do
      visit '/artist/32' #kemu
      wait_for_ajax
      islack '(Wikipedia引用)'
    end
  end

  describe '歌唱回数' do
    it 'ログイン中' do
      visit '/artist/1'
      expect(find('#sang_count_all').text).to eq '126'
      expect(find('#sang_count_user').text).to eq '115'
    end
    it 'ログインなし' do
      visit '/auth/logout'
      visit '/artist/1'
      expect(find('#sang_count_all').text).to eq '241'
    end
  end

  describe 'よく歌われる楽曲グラフ' do
    it 'その他あり' do
      visit '/artist/1' #BUMP OF CHICKEN
      wait_for_ajax
      result = to_hash('songs_chart_json')
      expect(result[0][1][0]).to eq 8
      expect(result[1][1][0]).to eq 6
      expect(result[2][1][0]).to eq 5
    end
    it 'その他なし' do
      visit '/artist/32' #kemu
      wait_for_ajax
      result = to_hash('songs_chart_json')
      expect(result[0][1][0]).to eq 3
      expect(result[1][1][0]).to eq 2
      expect(result[2][1][0]).to eq 2
    end
  end

  describe '歌唱回数グラフ' do
    it '一人だけ歌っている' do
      visit '/artist/70' #暁切歌
      wait_for_ajax
      result = to_hash('sang_count_chart_json')
      expect(result[-1]["ともちん"]).to eq 4
      expect(result[-3]["ともちん"]).to eq 2
    end
    it '複数人が歌っている' do
      visit '/artist/40' #水樹奈々
      wait_for_ajax
      result = to_hash('sang_count_chart_json')
      expect(result[-1]["ともちん"]).to eq 1
      expect(result[-1]["ウォーリー"]).to eq 2
    end
  end

  it '歌手の楽曲一覧が正常に表示されるか' do
    examine_artistlink 'BUMP OF CHICKEN'
    tables = table_to_hash('artistdetail_table')
    expect(tables.length).to eq 174
    expect(tables[0]['tostring']).to eq ',Hello, world!,8,0'
    expect(tables[15]['tostring']).to eq ',たったひとつの日々,0,2'
  end

  it 'リンクが正常に登録されているか' do
    visit '/history/list'
    examine_artistlink('BUMP OF CHICKEN')
    url = page.current_url
    songs = ['走れ' , '君に届け' , 'ロミオとシンデレラ']
    songs.each do |song|
      examine_songlink(song , 'BUMP OF CHICKEN' , url)
    end
  end

  describe 'URLで歌手名を指定して詳細画面へ移動' do
    def exam(name , result = true)
      visit URI.escape("/artist?name=#{name}")
      if result
        iscontain name
      else
        iscontain 'お探しのページは見つかりませんでした'
      end
    end
    describe '該当あり' do
      it '歌手名がアルファベットのみ' do
        exam('kemu')
      end
      it '歌手名が空白含むアルファベットのみ' do
        exam('BUMP OF CHICKEN')
      end
      it '歌手名が日本語' do
        exam('涼宮ハルヒ')
      end
    end
    describe '該当なし' do
      it '該当する歌手名なし' do
        exam('ずんどこずんどこ' , false)
      end
      it 'パラメータ指定なし' do
        visit '/artist'
        iscontain 'お探しのページは見つかりませんでした'
      end
      it 'パラメータが空' do
        visit '/artist?name='
        iscontain 'お探しのページは見つかりませんでした'
      end
    end
  end

end
