require_relative '../rbase'
include Rbase


init = proc do
  `zenra init -d 2016_04_29_04_00`
end

def table_string(row)
  table_to_hash('karaoke_detail_history_all')[row]['tostring']
end

# テスト実行
describe 'Historyの編集/削除' , :js => true do

  before(:all,&init)

  describe '正常系' do
    url = '/karaoke/detail/8'
    before do
      login 'sa2knight'
      visit url
    end
    after :each do
      wait_for_ajax
    end

    it '編集と削除' do
      #編集
      iscontain('祝本番環境リリース')
      expect(table_string(8)).to eq '9,ないと,,1/3の純情な感情,SIAM SHADE,0,その他,82.00,'
      find('#karaoke_detail_history_all').all('tr')[9].all('td')[8].find('img').click
      wait_for_ajax
      fill_in 'song' , with: '変更後の曲名'
      fill_in 'artist' , with: '変更後の歌手名'
      select 'DAM その他' , from: '採点方法'
      fill_in '採点' , with: '100'
      wait_for_ajax
      click_on '保存'
      wait_for_ajax
      visit url
      iscontain('変更後の曲名')
      islack('1/3の純情な感情')
      expect(table_string(8)).to eq '9,ないと,未登録,変更後の曲名,変更後の歌手名,0,その他,100.00,'

      #削除
      login 'unagipai'
      visit url
      expect(table_to_hash('karaoke_detail_history_all').length).to eq 75
      expect(table_string(10)).to eq '11,ちゃら,,DAN DAN心魅かれてく,FIELD OF VIEW,0,その他,73.00,'
      find('#karaoke_detail_history_all').all('tr')[11].all('td')[8].find('img').click
      wait_for_ajax
      click_on '削除'
      wait_for_ajax
      visit url
      expect(table_to_hash('karaoke_detail_history_all').length).to eq 74
      islack('DAN DAN心惹かれてく')
    end
  end

  describe '編集(異常値)' do
    url = '/karaoke/detail/18'
    before do
      login 'sa2knight'
      visit url
    end
    it '得点未入力' do
      js('register.editHistory(18 , 520)')
      fill_in 'score' , with: ''
      click_on '保存'; wait_for_ajax
      expect(table_string(0)).to eq '1,ないと,,ray,BUMP OF CHICKEN,0,,,'
    end
    it '得点0' do
      js('register.editHistory(18 , 523)')
      fill_in 'score' , with: '0'
      click_on '保存'; wait_for_ajax
      expect(table_string(3)).to eq '4,ないと,,さぁ,surface,-3,,,'
    end
    it '採点方法なし' do
      js('register.editHistory(18 , 525)')
      fill_in 'score' , with: '100'
      select '', from: 'score_type'
      click_on '保存'; wait_for_ajax
      expect(table_string(5)).to eq '6,ないと,,人生リセットボタン,kemu,5,,,'
    end
    #Todo 編集できてしまう問題を解決するのが先
    it '自分が歌った曲しか編集不可' do
      js('register.editHistory(18 , 524)')
      fill_in 'score' , with: '100'
      select '', from: 'score_type'
      click_on '保存'; wait_for_ajax
    end
  end
end
