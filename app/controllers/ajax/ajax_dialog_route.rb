require_relative 'ajax_route'

class AjaxDialogRoute < AjaxRoute

  # get '/ajax/dialog/karaoke - カラオケ入力画面を表示
  #---------------------------------------------------------------------
  get '/karaoke' do
    @products = Product.list
    @twitter = @current_user ? @current_user['twitter_info'] : nil
    erb :_input_karaoke
  end

  # get '/ajax/dialog/history - 歌唱履歴の入力画面を表示
  #---------------------------------------------------------------------
  get '/history' do
    @score_type = ScoreType.List
    @twitter = @current_user ? @current_user['twitter_info'] : nil
    erb :_input_history
  end

  # get '/ajax/dialog/song' - 楽曲新規登録の入力画面を表示
  #--------------------------------------------------------------------
  get '/song' do
    erb :_input_song
  end

end
