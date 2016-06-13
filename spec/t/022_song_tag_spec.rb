require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_12_04_00`
end

# テスト実行
describe 'タグ機能' , :js => true do
  before(:all , &init)
  before do
  end

  describe 'タグ表示' do
    it 'タグなし' do
    end
    it 'タグが１個以上５個未満' do
    end
    it 'タグが５個' do
    end
  end

  describe 'タグ登録' do
    it '単一登録' do
    end
    it '複数登録' do
    end
    it '複数登録(５個以上)' do
    end
  end

  describe 'タグ削除' do
  end

  describe 'タグ検索' do
    it 'タグ検索へのリンク' do
    end
    it '楽曲ページヘのリンク' do
    end
    it '歌手ページヘのリンク' do
    end
  end
end
