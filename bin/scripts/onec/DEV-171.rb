# productレコードにJOYSOUND MAX2 の列を追加挿入する
# ただし、出力の都合で、末尾に追加でなくID=5で挿入する
# そのため、既存のID5以降のレコードを順次繰り下げ、
# productレコードを参照しているkaraokeレコードの修正も行う

require 'pp'
require_relative '../../../app/models/db'

# karaokeレコードからの外部キー制約があるので、先にID(8)を作成
DB.new(
  INSERT: ['product', ['brand', 'product']],
  SET:    ['その他', 'その他'],
).execute_insert_id

# product(5,6,7)を参照するkaraoke一覧を取得
karaoke_list = DB.new(
  SELECT: ['id', 'product'],
  FROM:   'karaoke',
  WHERE:  'product >= ?',
  SET:    [5],
).execute_all

# それぞれのkaraokeレコードが参照するproductをスライド
karaoke_list.each do |karaoke|
  DB.new(
    UPDATE: ['karaoke', ['product']],
    WHERE:  'id = ?',
    SET:    [karaoke['product'] + 1, karaoke['id']]
  ).execute
end

# productレコードの名称をスライドする
DB.new(UPDATE: ['product', ['brand', 'product']], WHERE: 'id = ?', SET: ['JOYSOUND', 'MAX2', 5]).execute
DB.new(UPDATE: ['product', ['brand', 'product']], WHERE: 'id = ?', SET: ['DAM', 'Premier DAM', 6]).execute
DB.new(UPDATE: ['product', ['brand', 'product']], WHERE: 'id = ?', SET: ['DAM', 'LIVE DAM', 7]).execute
