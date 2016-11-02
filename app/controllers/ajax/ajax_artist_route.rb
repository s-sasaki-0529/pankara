require_relative 'ajax_route'

class AjaxArtistRoute < AjaxRoute

  # post '/ajax/artist/tally/monthly/count/?' - 指定したアーティストの月ごとの歌唱回数を戻す
  #--------------------------------------------------------------------
  post '/tally/monthly/count/?' do
    artist = Artist.new(params['id']) or return error('invalid artist id')
    sang_histories = artist.monthly_sang_count || {}
    monthly_data = Util.create_monthly_data(sang_histories)
    return success(monthly_data)
  end

  # ppost '/ajax/artist/wiki' - 指定したアーティストのWikiページを取得
  #--------------------------------------------------------------------
  post '/wiki' do
    artist = params[:artist]
    wiki = Util.get_wikipedia(artist)
    if wiki
      begin
        return success(:summary => wiki.summary, :url => wiki.fullurl)
      rescue
        wiki = Util.get_wikipedia(wiki.links[0])
        return success(:summary => wiki.summary, :url => wiki.fullurl)
      end
    else
      return error('not found')
    end
  end

end
