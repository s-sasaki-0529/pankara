# アップデート履歴がJSON形式で格納されたファイルを参照し、
# そこに新しいアップデート履歴を追加するスクリプト
# ex) ruby addUpdateInfo.rb 'バグ修正' 'バグ直しました'
# 実行時時点での日付で、アップデート内容をJSONに記述する
#-----------------------------------------------------------------------

require 'json'
UPDATES = 'updates.json'
DATE = Date.today.strftime('%Y/%m/%d')
CATEGORY = ARGV[0]
TEXT = ARGV[1]

updates = open(UPDATES) do |io|
  JSON.load(io)
end

today = updates.select {|j| j['date'] == DATE}
if today.size > 0
  today[0]['update'].push('category' => CATEGORY , 'text' => TEXT)
else
  updates.unshift(:date => DATE)
  updates[0]['update'] = [{'category' => CATEGORY , 'text' => TEXT}]
end

open(UPDATES , 'w') do |io|
  JSON.dump(updates , io)
end
