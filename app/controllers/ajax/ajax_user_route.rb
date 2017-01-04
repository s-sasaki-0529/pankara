require_relative 'ajax_route'

class AjaxUserRoute < AjaxRoute

  # post '/ajax/user/karaoke/recent/?' - ユーザの参加するカラオケの中で最も新しいものを取得
  #--------------------------------------------------------------------
  post '/karaoke/recent/?' do
    @current_user or return error('ログインしてください')
    attends = @current_user.attend_ids(:want_karaoke => true)
    attends.empty? and return error('参加しているカラオケがありません')
    karaoke = Karaoke.new(attends[-1]['karaoke'])
    return success(:id => karaoke['id'] , :name => karaoke['name'])
  end

  # post '/ajax/user/artist/favorite/?' - ログインユーザの主に歌うアーティスト１０組を戻す
  #--------------------------------------------------------------------
  post '/artist/favorite/?' do
    user = User.new(params[:user])
    user or return error('invalid user')
    favorite_artists = user.favorite_artists(:limit => 10, :want_rate => true) or return error('no artists')
    return success(favorite_artists.map { |a| [a['artist_name'] , a['artist_count_rate']] })
  end

  # post '/ajax/user/karaoke/attendance' - ログインユーザの指定したカラオケに対するattendanceを取得
  #---------------------------------------------------------------------
  post '/karaoke/attendance' do
    attendance = @current_user.get_attendance_at_karaoke(params[:id])

    return attendance ? success(attendance) : error('get attendance failed')
  end

  # post '/ajax/user/history/recent/key - 歌ったことがある楽曲ならば最近歌ったときのキーを返す
  #---------------------------------------------------------------------
  post '/history/recent/key' do
    @current_user or return error('never sang')

    song = Song.name_to_id(params[:name], params[:artist]) or return error('never sang')
    key = @current_user.search_songkey(song['song_id'])
    if key
      success(key)
    else
      error('never sang')
    end
  end

end
