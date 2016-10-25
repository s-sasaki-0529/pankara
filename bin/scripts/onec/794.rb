require 'json'
updates = []

while (line = STDIN.gets)
  line.chomp!
  line == '' and next
  if line.match %r|[0-9]{4}/[0-9]{2}/[0-9]{2}|
    updates.push(:date => line , :update => [])
  else
    matches = line.scan %r|^[0-9]\. \[(.+?)\] (.+)$|
    category = matches[0][0]
    text = matches[0][1]
    updates[-1][:update].push(:category => category , :text => text)
  end
end

puts JSON.generate(updates)
