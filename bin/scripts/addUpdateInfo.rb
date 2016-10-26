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
(CATEGORY and TEXT) or return

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

new_json = JSON.pretty_generate(updates)
File.open(UPDATES , 'w') do |f|
  f.puts new_json
end
