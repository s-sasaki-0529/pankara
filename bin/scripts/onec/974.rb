# Userテーブルに対して、各パスワードをMD5でハッシュ化したものに書き換える
# このスクリプトは本番環境では一度のみの利用を想定

require 'pp'
require_relative '../../../app/models/db'

`zenra mysql -e "alter table user modify password VARCHAR(32) NOT NULL COMMENT 'ハッシュ化したログイン用パスワード';"`

users = DB.new(
  :SELECT => %w(id password) ,
  :FROM => 'user'
).execute_all

users.each do |user|
  id = user['id']
  pw = user['password']
  hashed_pw = Util.md5digest(pw)
  DB.new(
    :UPDATE => ['user' , ['password']],
    :WHERE => 'id = ?',
    :SET => [hashed_pw , id],
  ).execute
end
