# 標準出力の内容をチャットワークにPOSTする

require_relative '../../app/models/chatwork'
chatwork = Chatwork.new
text = []
while line = gets
  text << line.chomp
end
chatwork.sendMessage(text.join("\n"))
