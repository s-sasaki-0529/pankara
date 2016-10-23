require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# テスト実行
describe 'エラーページの表示' do

  before(:all , &init)
  message = 'お探しのページは見つかりませんでした'

  describe 'ユーザ' do
    describe 'ユーザページ' do
      it '正常系' do
        visit '/user/userpage/unagipai'
        islack message
      end
      it '異常系' do
        visit '/user/userpage/nouser'
        iscontain message
      end
    end
    describe '歌唱履歴' do
      it '正常系' do
        visit '/history/list/hetare'
        islack message
      end
      it '異常系' do
        visit '/history/list/foobar'
        iscontain message
      end
    end
    describe '持ち歌リスト' do
      it '正常系' do
        visit '/user/songlist/tomotin'
        islack message
      end
      it '異常系' do
        visit '/user/songlist/fugafuga'
        iscontain message
      end
    end
    describe '友達リスト' do
      it '正常系' do
        visit '/user/friend/list/sa2knight'
        islack message
      end
      it '異常系' do
        visit '/user/friend/list/hogehoge'
        iscontain message
      end
    end
  end

  describe '楽曲' do
    it '正常系' do
      visit '/song/315'
      islack message
    end
    it '異常系' do
      visit '/song/1000'
      iscontain message
    end
  end

  describe 'アーティスト' do
    it '正常系' do
      visit '/artist/197'
      islack message
    end
    it '異常系' do
      visit '/artist/5000'
      iscontain message
    end
  end

  describe 'カラオケ' do
    it '正常系' do
      visit '/karaoke/detail/75'
      islack message
    end
    it '異常系' do
      visit '/karaoke/detail/80'
      iscontain message
    end
  end

  it 'ルーティング該当なし' do
    visit '/'
    islack message
    visit '/hogehoge'
    iscontain message
  end

end

