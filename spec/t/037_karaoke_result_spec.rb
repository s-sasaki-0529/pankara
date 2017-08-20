require_relative '../rbase'
include Rbase

# カラオケを作成
def createKaraoke(option_params = {})
  params = {
    name:      'テスト用カラオケ',
    datetime:  '2017-07-10 10:00',
    plan:      '02時間00分',
    store:     'カラオケ館',
    branch:    '亀戸店',
    product:   'JOYSOUND MAX',
  }.merge(option_params)
  js 'register.createKaraoke()'
  fill_in 'name', with: params[:name]
  js("$('#datetime').val('#{params[:datetime]}')")
  select params[:plan], from: 'plan'
  fill_in 'store', with: params[:store]
  fill_in 'branch', with: params[:branch]
  select params[:product], from: 'product'
  js('register.submitKaraokeRegistrationRequest();')
end

# ボタンをクリックする
def click_buttons(*buttons)
  buttons.each do |b|
    click_on b; wait_for_ajax
  end
end

# テスト用データベース構築
init = proc do
  `zenra init -d 2017_08_19_04_00`
end

# テスト実行
describe 'カラオケ登録結果', :js => true do

  # テスト実行時にデータベースを初期化
  before(:all , &init)

  # テストグループごとに、wait_for_ajaxを実行
  after :each do
    wait_for_ajax
  end

  before do
    login 'sa2knight'
  end

  describe '登録情報' do
    it '通常入力' do
      createKaraoke
      examine_text_by_class('name', 'テスト用カラオケ')
      examine_text_by_class('datetime', '2017-07-10 10:00:00')
      examine_text_by_class('plan', '2 時間')
      examine_text_by_class('store', 'カラオケ館 亀戸店')
      examine_text_by_class('product', 'JOYSOUND(MAX)')
    end
    it 'デフォルト値' do
      empty_params = {
        name: '',
        store: '',
        branch: '',
      }
      createKaraoke(empty_params)
      examine_text_by_class('store', '未登録')
      expect(page.find('.name').text.scan(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2} のカラオケ$/).count).to eq 1
    end
  end

  describe 'ボタン押下' do
    it '歌唱履歴を登録する' do

    end
    it '閉じる' do

    end
  end

  describe '集計情報' do

  end

end
