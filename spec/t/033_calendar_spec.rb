require_relative '../rbase'
require 'date'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_11_09_04_00`
end

# テスト実行
describe 'カレンダー機能' , :js => true do  

  today = Date.today
  def examine_month(year , month)
    expect(find('.calendar-year-month').text()).to eq "#{year}年#{month}月"
  end
  def move(year , month)
    visit '/'; wait_for_ajax
    while (find('.calendar-year-month').text() != "#{year}年#{month}月")
      find('#last_month_btn').click
      wait_for_ajax
    end
    examine_month(year , month)
  end
  def examine_karaoke_num(selecter , num)
    classNum = all(selecter).count
    expect(classNum).to eq num
  end

  before(:all , &init)
  before do
    login 'heav_destn'
    wait_for_ajax
  end

  describe 'カレンダー表示' do

    it '今月が表示される' do
      examine_month(today.year , today.month)
    end

    it '先月へ移動' do
      find('#last_month_btn').click; wait_for_ajax
      last_month = today << 1
      examine_month(last_month.year , last_month.month)
    end

    it '来月へ移動' do
      5.times {|i| find('#last_month_btn').click; wait_for_ajax}
      4.times {|i| find('#next_month_btn').click; wait_for_ajax}
      last_month = today << 1
      examine_month(last_month.year , last_month.month)
    end

    it '今月へ移動' do
      3.times {|i| find('#next_month_btn').click; wait_for_ajax}
      find('#today_btn').click; wait_for_ajax
      examine_month(today.year , today.month)
    end

    it '2016/01以前は表示されない' do
      24.times {|i| find('#last_month_btn').click; wait_for_ajax}
      examine_month(2016 , 1)
    end

    it '今月以降は表示されない' do
      find('#next_month_btn').click; wait_for_ajax
      examine_month(today.year , today.month)
    end

  end

  describe 'カラオケの表示' do

    it '全てのカラオケが表示される' do
      move(2016 , 9)
      examine_karaoke_num('.calendar-event' , 6)
      examine_karaoke_num('.calendar-label-red' , 1)
      examine_karaoke_num('.calendar-label-blue' , 4)
      examine_karaoke_num('.calendar-label-green' , 1)
    end

    it 'カラオケ１個、メンバー１人の日' do
      move(2016 , 10)
      examine_karaoke_num('#calendar-id11 .calendar-event' , 1)
    end

    it 'カラオケ２個、メンバー１人の日' do
      move(2016 , 11)
      examine_karaoke_num('#calendar-id6 .calendar-event' , 2)
      examine_karaoke_num('#calendar-id6 .calendar-label-blue' , 1)
      examine_karaoke_num('#calendar-id6 .calendar-label-red' , 1)
    end

    it 'カラオケ１個、メンバー２人の日' do
      move(2016 , 9)
      examine_karaoke_num('#calendar-id25 .calendar-event' , 1)
      examine_karaoke_num('#calendar-id25 .calendar-event img' , 2)
    end

    it 'カラオケ２個、メンバー２人の日' do
      login 'sa2knight'
      move(2016 , 5)
      examine_karaoke_num('#calendar-id1 .calendar-event' , 2)
      examine_karaoke_num('#calendar-id1 .calendar-label-red img' , 2)
      examine_karaoke_num('#calendar-id1 .calendar-label-blue img' , 2)
    end

  end

  describe 'カラオケ詳細画面へのリンク' do
    it 'カラオケ１個、メンバー１人の日' do
      move(2016 , 10)
      find('#calendar-id11 .calendar-event').click
      expect(current_path).to eq '/karaoke/detail/90'
    end
    it 'カラオケ２個、メンバー１人の日' do
      move(2016 , 11)
      all('#calendar-id6 .calendar-event')[1].click
      expect(current_path).to eq '/karaoke/detail/113'
    end
    it 'カラオケ１個、メンバー２人の日' do
      move(2016 , 9)
      find('#calendar-id25 .calendar-event').click
      expect(current_path).to eq '/karaoke/detail/87'
    end
    it 'カラオケ２個、メンバー２人の日' do
      move(2016 , 5)
      all('#calendar-id1 .calendar-event')[1].click
      expect(current_path).to eq '/karaoke/detail/42'
    end

  end


end
