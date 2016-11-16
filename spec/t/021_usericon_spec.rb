require_relative '../rbase'
include Rbase

# 定数を定義
USER = 'test'
SUCCESS = 'アイコンファイルを変更しました'
TYPEERROR = 'アップロードできるファイルは、jpg/png/gifのみです'

# ファイルをアップロードする
def upload(filename , type)
  file = Rack::Test::UploadedFile.new("spec/common/#{filename}" , type)
  image = {:type => file.content_type, :tempfile => file.tempfile}
  return Util.save_icon_file(image , USER)
end

# テスト実行
describe 'ユーザアイコンの設定' do

  context '正常アップロード' do
    example 'jpegファイルをアップロード' do
      expect(upload('jpg.jpg' , 'image/jpeg')).to eq SUCCESS
    end
    example 'pngファイルをアップロード' do
      expect(upload('png.png' , 'image/png')).to eq SUCCESS
    end
    example 'gifファイルをアップロード' do
      expect(upload('gif.gif' , 'image/gif')).to eq SUCCESS
    end
    example '巨大ファイルをアップロード' do
      expect(upload('bigimage.jpg' , 'image/jpeg')).to eq SUCCESS
    end
  end

  context 'ファイルタイプチェック' do
    example 'テキストファイル' do
      expect(upload('text.txt' , 'text/plain')).to eq TYPEERROR
    end
  end
end
