require "net/http"

def get(number)
  uri = URI.parse("http://www.gaccom.jp/schools-#{number}/students.html")
  response = nil
  request = Net::HTTP::Get.new(uri.request_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  
  begin
    http.start do |h|
      response = h.request(request)
    end
  rescue
    puts "#{number},retry..."
    `sleep 5`
    return get(number)
  else
    return response.body
  end
end

type_str = ['' , '保育園' , '幼稚園' , '小学校' , '中学校']
83691.upto(200000) do |i|
  html = get(i)
  html.force_encoding("UTF-8")

  match1 = html.scan(%r|<h1 class="primary">(.+?)</h1>|)
  match2 = html.scan(%r|<div class="clearfix type_([1234])">|)
  match3 = html.scan(%r|^\s+<span><span>(.+?[都道府県])の情報</span></span>$|u) or next;
  unless match1.empty? || match2.empty? || match3.empty?
    name = match1[0][0]
    type = type_str[match2[0][0].to_i]
    match = html.scan(%r|^\s+<p class="graph_value">(\d+)</p>|)
    if match.empty?
      num = "-"
    else
      num = match[0][0]
    end
    location = match3[0][0]
    puts [i , location , type , name , num].join(',')
  else
    puts "#{i},warning..."
  end
  `sleep 2`
end
