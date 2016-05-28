require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_28_19_02`
end

# ファイルをアップロードする
def upload(filepath)
  
end

# テスト実行
describe 'ユーザアイコンの設定' do
  before(:all , &init)
  before do
    login 'test'
    visit 'config'
  end
  it '正常パターン' do
  end
  it 'jpeg/gif/pngのみ対応' do
  end
  it '256 * 256までのみ対応' do
  end
end
