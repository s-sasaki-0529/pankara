require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_12_04_00`
end

# テスト実行
describe 'タグ機能' do
  before(:all , &init)
  before do
  end
end
