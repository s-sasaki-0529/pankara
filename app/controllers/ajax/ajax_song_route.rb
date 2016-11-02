require_relative 'ajax_route'

class AjaxSongRoute < AjaxRoute

  # post '/ajax/song/create/?' 楽曲を新規登録
  #---------------------------------------------------------------------
  post '/create/?' do
    user = @current_user or return error('invalid current user')
    song = params[:song]
    artist = params[:artist]
    # 歌手名 / 曲名は必須
    if song.nil? || song == ''
      return error('曲名を入力してください')
    elsif artist.nil? || artist == ''
      return error('歌手名を入力してください')
    end
    register = Register.new(user)
    artist_id = register.create_artist(artist)
    song_id = register.create_song(artist_id , artist , song)
    if artist_id && song_id
      return success(song_id)
    else
      return error('fails create song')
    end
  end

  # post '/ajax/song/list/names' - 全ての楽曲を取得し、曲名→歌手名のハッシュをJSONで戻す
  #---------------------------------------------------------------------
  post '/list/names' do
    hash = Hash.new
    song_list = Song.list({:artist_info => true})
    song_list.each do |s|
      hash[s['song_name']] = s['artist_name']
    end
    return success(hash)
  end

  # post '/ajax/song/list/details' - SongIDのリストをPOSTすると、該当する楽曲情報のリストを戻す
  #--------------------------------------------------------------------
  post '/list/details' do
    songs = params[:songs]
    (songs && songs.size > 0) or return error('invalid songs')
    songs_info = Song.list(:songs => songs)
    (songs_info && songs_info.size > 0) or return error('failed get songs info')
    return success(songs_info)
  end

  # post '/ajax/song/modify/?' - 楽曲情報を編集する
  #--------------------------------------------------------------------
  post '/modify/?' do
    @current_user or return error('invalid user')
    song_id = params[:song_id]
    song_name = params[:song]
    artist_name = params[:artist]
    song_name == "" and return error('曲名を入力してください')
    artist_name == "" and return error('歌手名を入力してください')
    artist_id = Artist.name_to_id(artist_name , :create => 1)
    url = params[:url]
    song = Song.new(song_id)
    song or return error('no song')
    result = song.modify('name' => song_name, 'artist' => artist_id, 'url' => url)
    return result ? success : error('invalid params')
  end

  # post '/song/tag/list' - 指定した楽曲のタグ一覧を戻す
  #--------------------------------------------------------------------
  post '/tag/list/?' do
    song = Song.new(params['song']) or return error('invalid song id')
    tags = song.tags or return error('fails get tags')
    return success(tags)
  end


  # post '/ajax/song/:id/tag/add' - 楽曲にタグを追加する
  #--------------------------------------------------------------------
  post '/:id/tag/add' do
    @current_user or return error('ログインしてください')
    id = params[:id]
    tag = params[:tag_name]
    song = Song.new(id)
    song and tag and tag != "" and tag.split(/[\s　]/).each do |t|
      song.add_tag(@current_user['id'] , t)
    end
    return success
  end

  # post '/ajax/song/:id/tag/remove' - 楽曲に登録されているタグを削除
  #--------------------------------------------------------------------
  post '/:id/tag/remove' do
    @current_user or return error('ログインしてください')
    @current_user['id'].to_s == params[:created_by] or return error('タグを削除できません')
    id = params[:id]
    tag = params[:tag_name]
    song = Song.new(id)
    song and tag and tag != "" and song.remove_tag(tag)
    return success
  end

  # post '/ajax/song/tally/monthly/count/?' - 指定した楽曲の月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/tally/monthly/count/?' do
    song = Song.new(params['id']) or return error('invalid song id')
    sang_histories = song.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # post '/ajax/song/tally/score/?' - 指定した楽曲、採点モードの採点集計を戻す
  #--------------------------------------------------------------------
  post '/tally/score/?' do
    song = Song.new(params[:song]) or return error('no song')
    score_type = params[:score_type].to_i or return error('no score type')
    user = @current_user ? @current_user.params['id'] : nil

    # ScoreTypeとScoreTypeNameの対応を取得
    score_type_name = ScoreType.id_to_name(score_type , :hash => true).values.join(' ')

    # みんなの得点集計を取得
    agg_score = song.tally_score(:score_type => score_type, :without_user => user)
    # 得点を小数点以下第二位で四捨五入
    agg_score.keys.each { |k| agg_score[k] and agg_score[k] = sprintf('%.2f' , agg_score[k]) }

    # あなたの得点集計を取得
    agg_myscore = {'score_max' => nil, 'score_min' => nil, 'score_avg' => nil}
    if user
      agg_myscore = song.tally_score(:score_type => score_type, :target_user => user)
      agg_myscore.keys.each { |k| agg_myscore[k] and agg_myscore[k] = sprintf('%.2f' , agg_myscore[k]) }
    end

    # グラフ生成用にデータを加工
    avg_data = {:name => '平均', :みんな => agg_score['score_avg'], :あなた => agg_myscore['score_avg']}
    max_data = {:name => '最高', :みんな => agg_score['score_max'], :あなた => agg_myscore['score_max']}
    min_data = {:name => '最低', :みんな => agg_score['score_min'], :あなた => agg_myscore['score_min']}

    # まとめてJSONで返却
    return success(:score_type_name => score_type_name, :scores => [min_data , avg_data , max_data])
  end

end
