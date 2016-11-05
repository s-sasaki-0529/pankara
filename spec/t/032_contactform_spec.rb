require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_11_05_22_17`
end

# テスト実行
describe 'お問い合わせフォーム' , :js => true do
  def send(name , mail , title , contact)
    fill_in 'name' , with: name
    fill_in 'email' , with: mail
    fill_in 'title' , with: title
    fill_in 'contact' , with: contact
    click_on '送信'
    wait_for_ajax
  end
  def is_contact_form
    iscontain 'お問い合わせ内容を入力し、「送信」ボタンをクリックしてください。'
  end
  def is_contacted_form
    iscontain 'お問い合わせ内容を送信しました'
  end
  before(:all , &init)
  before do
    login 'sa2knight'
    visit '/contact'
  end
  it '正常入力' do
    send('ないと' , 'hogehoge@fugafuga.com' , 'テストです' , 'よろしく')
    is_contacted_form
  end
  describe '以上入力' do
    it '名前無し' do
      send('' , 'メール' , 'タイトル' , '本文')
      is_contact_form
    end
    it 'タイトルなし' do
      send('名前' , 'メール' , '' , '本文')
      is_contact_form
    end
    it 'メールアドレスなし' do
      send('名前' , '' , 'タイトル' , '本文')
      is_contact_form
    end
    it '本文なし' do
      send('名前' , 'メール' , 'タイトル' , '')
      is_contact_form
    end
  end
end
