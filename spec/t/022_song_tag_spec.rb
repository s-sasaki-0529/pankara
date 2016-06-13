require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_13_00_24`
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
    it '削除' do
      visit '/search/tag/?tag=%E5%B7%A1%E9%9F%B3%E3%83%AB%E3%82%AB' #巡音ルカ
      iscontain 'タグ "巡音ルカ" が登録された楽曲一覧(7件)'
      examine_songlink 'Reboot' , 'ジミーサムP'; wait_for_ajax
      all('#tag_list_table > tbody > tr > td > img')[2].click; wait_for_ajax
      iscontain 'タグ [巡音ルカ] を削除します。よろしいですか？'
      find('#popup_ok').click; wait_for_ajax
      islack '巡音ルカ'
      visit '/search/tag/?tag=%E5%B7%A1%E9%9F%B3%E3%83%AB%E3%82%AB' #巡音ルカ
      iscontain 'タグ "巡音ルカ" が登録された楽曲一覧(6件)'
    end
    it 'キャンセル' do
      visit '/song/270'; wait_for_ajax
      iscontain 'がくっぽいど'
      all('#tag_list_table > tbody > tr > td > img')[1].click; wait_for_ajax
      find('#popup_cancel').click; wait_for_ajax
      iscontain 'がくっぽいど'
    end
  end

  describe 'タグ検索' do
    it 'タグ検索へのリンク' do
      visit '/song/231'
      iscontain ['VOCALOID' , '初音ミク']
      link 'VOCALOID'
      iscontain 'タグ "VOCALOID" が登録された楽曲一覧(103件)'
    end
    it '楽曲ページヘのリンク' do
      visit '/search/tag/?tag=VOCALOID'
      examine_songlink 'カミサマネジマキ' , 'kemu'
    end
    it '歌手ページヘのリンク' do
      visit '/search/tag/?tag=VOCALOID'
      examine_artistlink 'ジミーサムP'
    end
  end
end
