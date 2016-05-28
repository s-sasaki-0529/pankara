require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_28_19_02`
end

# ファイルをアップロードする
def upload(filepath)
  post_file = Rack::Test::UploadedFile.new(filepath)
  post "icon", "icon_file" => post_file
end

# テスト実行
describe 'ユーザアイコンの設定' do
  before(:all , &init)
  before do
    login 'test'
    visit 'config'
  end
  describe '正常パターン' do
    it 'jpeg' do
    end
    it 'png' do
    end
    it 'gif' do
    end
  end
  describe '256 * 256 以上のファイルはダメ' do
    it 'jpeg' do
    end
    it 'png' do
    end
    it 'gif' do
    end
  end
  describe 'jpeg/png/gif以外のファイルはダメ' do
    it 'テキストファイル' do
    end
    it '拡張子偽装' do
    end
  end
end
