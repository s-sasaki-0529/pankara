require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('march_user' , 'march_user' , 'マーチユーザ')
end

def register_user(sname , name , pwd , repwd)
  fill_in 'screenname', with: sname
  fill_in 'username', with: name
  fill_in 'password', with: pwd
  fill_in 'repassword', with: repwd
  find('#registration_button').click
end

# 定数定義
url = '/user/registration'
message = 'ユーザの新規登録'

# テスト実行
describe 'ユーザ登録機能' do
  before(:all , &init)
  
  it '画面表示' do
    visit url
    iscontain message
  end

  it 'ユーザ登録' do
    visit url
    register_user('全裸ユーザ' , 'zenra_user' , 'zenra_user' , 'zenra_user')
    iscontain '全裸ユーザさんを登録しました'

    link 'ログインする'
    login 'zenra_user'
    iscontain 'ユーザ名 全裸ユーザ'
  end

  describe '失敗パターン' do
    describe 'ニックネーム' do
      it 'ニックネームの文字数が多すぎて失敗' do
        visit url
        register_user('全裸ユーザ全裸ユーザ全裸ユーザ全裸ユーザ' , 'zenra_user' , 'zenra_user' , 'zenra_user')
        iscontain 'ニックネームは2文字以上16文字以下で入力してください。'
      end
      it 'ニックネームに特殊文字を使用して失敗' do
        visit url
        register_user('<全裸ユーザ>' , 'zenra_user' , 'zenra_user' , 'zenra_user')
        iscontain '<>$#%&"\'!はニックネームに使用できません。'
      end
    end

    describe 'ユーザ名' do
      it 'すでに存在するユーザ名で登録しようとして失敗' do
        visit url
        register_user('マーチユーザ' , 'march_user' , 'march_user' , 'march_user')
        iscontain 'そのユーザ名はすでに使われています。'
      end
      it 'ユーザ名の文字数が少なすぎて失敗' do
        visit url
        register_user('全裸ユーザ' , 'zenra_userzenra_userzenra_user' , 'zenra_user' , 'zenra_user')
        iscontain 'ユーザ名は4文字以上16文字以下の半角英数字で入力してください。'
      end
      it 'ユーザ名に全角文字を使用して失敗' do
        visit url
        register_user('全裸ユーザ' , '全裸ユーザ' , 'zenra_user' , 'zenra_user')
        iscontain 'ユーザ名は4文字以上16文字以下の半角英数字で入力してください。'
      end
    end

    describe 'パスワード' do
      it 'パスワードの文字数が少なすぎて失敗' do
        visit url
        register_user('全裸ユーザ' , 'zenra_user' , 'zen' , 'zen')
        iscontain 'パスワードは4文字以上の半角英数字で入力してください。'
      end
      it 'パスワードに全角文字を使用して失敗' do
        visit url
        register_user('全裸ユーザ' , 'zenra_user' , '全裸ユーザ' , '全裸ユーザ')
        iscontain 'パスワードは4文字以上の半角英数字で入力してください。'
      end
      it '異なるパスワードを再入力して失敗' do
        visit url
        register_user('全裸ユーザ' , 'zenra_user' , 'zenra_user' , 'zenra')
        iscontain '再入力したパスワードが異なっています。'
      end
    end
  end
end

