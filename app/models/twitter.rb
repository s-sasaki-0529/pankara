#----------------------------------------------------------------------
# Twitter - ツイッターとの認証連携全般
#----------------------------------------------------------------------
require_relative 'util'
class Twitter < Base

  # initialize - usernameでインスタンスを生成する
  #---------------------------------------------------------------------
  def initialize(username)
    @username = username
    twitter_api = Util.read_secret('twitter_api')
    key = twitter_api['key']
    secret = twitter_api['secret']

    if false
    else
      @twitter = TwitterOAuth::Client.new(
        :consumer_key => key, 
        :consumer_secret => secret
      )
    end
  end

  # request_token - Twitter認証用のURLを生成する
  #--------------------------------------------------------------------
  def request_token(callback)
    request_token = @twitter.request_token(:oauth_callback => callback)
    return request_token
  end

  # get_access_token - Twitter連携用のアクセストークンを取得する
  #--------------------------------------------------------------------
  def get_access_token(req_token , req_secret , verifier)
    @twitter.authorize(req_token , req_secret , :oauth_verifier => verifier)
  end

  # tweet - ツイートする
  #-------------------------------------------------------------------
  def tweet(text)
    @twitter.update(text)
  end
end
