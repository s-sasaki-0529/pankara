require_relative './march'
require_relative '../models/song'
require_relative '../models/tag'

class SearchRoute < March

  # get '/search/keyword/:search_word' - 楽曲/歌手を検索する
  #--------------------------------------------------------------------
  get '/keyword/?' do
    @search_word = params[:search_word] || ""
    @song_list = []
    @artist_list = []
    @tag_list = []

    if @search_word.size > 0
      # 該当する楽曲、歌手、タグの一覧を取得
      @song_list.concat(Song.list({:name_like => @search_word , :artist_info => true}))
      @artist_list.concat(Artist.list({:name_like => @search_word}))
      @tag_list.concat(Tag.tags(:like => @search_word))

      # 楽曲、歌手、タグ全て合わせて１件しかヒットしなかった場合、そのページにリダイレクト
      if @song_list.size + @artist_list.size + @tag_list.size == 1
        if @song_list.size == 1
          redirect "/song/#{@song_list[0]['song_id']}"
        elsif @artist_list.size == 1
          redirect "/artist/#{@artist_list[0]['id']}"
        else
          redirect "/search/tag/?tag=#{@tag_list[0]}"
        end
      end
    end

    erb :search
  end

  # get '/search/tag/' - タグ検索
  # 現在は楽曲のみにタグが振られていることを想定
  #--------------------------------------------------------------------
  get '/tag/' do
    @tag = params[:tag] || ""
    @song_list = []
    if @tag.size > 0
      song_ids = Tag.search('s' , @tag)
      song_ids.size > 0 and @song_list = Song.list(:artist_info => true, :songs => song_ids , :sort => 'name')
    end
    erb :search_tag
  end

end
