require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# テスト実行
describe '集計情報表示機能' , :js => true do
  
  before(:all , &init)
  
  describe '各種リンク' do
    it '曲名' do
    end
    it '歌手名' do
    end
    it '最終歌唱日' do
    end
  end

  describe 'ページング' do
    it '次へ' do
    end
    it '前へ' do
    end
    it '最後へ' do
    end
    it '先頭へ' do
    end
    it '表示件数変更' do
    end
  end

  describe '検索' do
    it '曲名' do
    end
    it '歌手名' do
    end
    it 'タグ' do
    end
    it 'ヒット無し' do
    end
  end

  describe '並び順' do
    it '最後に歌った日' do
    end
    it '初めて歌った日' do
    end
    it '歌唱回数' do
    end
    it '曲名' do
    end
    it '歌手名' do
    end
    it '昇順' do
    end
    it '降順' do
    end
  end

end
