#----------------------------------------------------------------------
# 友達登録を自動化
# 第一引数に対象ユーザ、第二引数以降に登録するユーザ名を登録
#----------------------------------------------------------------------
require_relative "../../app/models/user"
require_relative "../../app/models/friend"

user = User.new(ARGV.shift)
friends = ARGV

friends.each do |f|
  friend = User.new(f)
  user.addfriend(friend['id'])
  friend.addfriend(user['id'])
end
