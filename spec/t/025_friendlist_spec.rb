require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# ログインして友達一覧を表示
def show_friend_list(user)
  login user
  visit "/user/friend/list/#{user}"
end

# テスト実行
describe '友達一覧機能' do
  before(:all , &init)
  before do
  end

  it '友達が居ない場合' do
    show_friend_list 'test'
    iscontain '友達がいません'
  end

  it '友達がいる場合' do
    show_friend_list 'sa2knight'
    expect(table_to_array('users_table').length).to eq 4
    iscontain ['ともちん' , 'へたれ' , 'ちゃら' , 'にゃんでれ']
    islack ['ウォーリー' , 'とーまさん' , 'テスト']
    islack '友達がいません'
  end

  describe 'リンク' do
    
    it 'ユーザページ' do
      show_friend_list 'worry'
      link_strictly 'へたれ'
      expect(current_path).to eq '/user/userpage/hetare'
    end

    it '履歴' do
      show_friend_list 'worry'
      link_strictly '履歴'
      iscontain 'へたれさんの歌唱履歴'
    end

    it 'カラオケ' do
      show_friend_list 'worry'
      link_strictly 'カラオケ'
      iscontain 'へたれさんのカラオケ一覧'
    end

    it '持ち歌' do
      show_friend_list 'worry'
      link_strictly '持ち歌'
      iscontain 'へたれ さんの楽曲一覧'
    end

    it '友達' do
      show_friend_list 'worry'
      link_strictly '友達'
      iscontain 'へたれ さんの友達一覧'
    end

  end

end
