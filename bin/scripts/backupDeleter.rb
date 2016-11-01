# 全てのバックアップファイルの一覧を取得
def getAllFiles
  files = `find backup/ -type f | awk -F/ '{print $NF}'`.lines.each {|l| l.chomp!}
  return files.sort
end

# 現在より１４日以上前のバックアップファイルの一覧を取得
def getOldFiles
  base = `date +"%Y_%m_%d_%H_%M" -d "14 days ago"`
  getAllFiles.select { |f| f < base }
end

# テスト内で使用されているバックアップファイルの一覧を取得
def getUsedFiles
  used_files = []
  grep_result = `grep -sr "zenra init -d" spec/t/`.lines.each {|l| l.chomp!}
  grep_result.each do |gr|
    filename = gr.match(/zenra init -d (\d{4}_\d{2}_\d{2}_\d{2}_\d{2})/)[1]
    used_files.push filename
  end
  return used_files.uniq!
end

# テスト内で使用されていないバックアップファイルの一覧を取得
def getUnUsedOldFiles
  return getOldFiles - getUsedFiles
end

# 指定したバックアップファイルを削除する
def removeFile(filename)
  `rm backup/#{filename}`
end

getUnUsedOldFiles.each { |f| removeFile f }
