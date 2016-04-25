#----------------------------------------------------------------------
# Twitter - ツイッターとの認証連携全般
#----------------------------------------------------------------------
require_relative 'util'
class Twitter < Base

  attr_reader :authed

  # initialize - usernameでインスタンスを生成する
  #---------------------------------------------------------------------
  def initialize(username)

    # 本番環境のみで動作
    Util.run_mode == 'yshirt' or return nil

    @username = username
    twitter_api = Util.read_secret('twitter_api')
    key = twitter_api['key']
    secret = twitter_api['secret']
    a_token = nil
    a_secret = nil

    if @access_token = Util.read_secret(@username)
      a_token = @access_token[:token] || nil
      a_secret = @access_token[:secret] || nil
    end

    @twitter = TwitterOAuth::Client.new(
      :consumer_key => key,
      :consumer_secret => secret,
      :token => a_token,
      :secret => a_secret
    )
    @authed = @twitter && @twitter.info['screen_name'] ? true : false
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
    token = @twitter.authorize(req_token , req_secret , :oauth_verifier => verifier)
    Util.write_secret(@username , {:token => token.token , :secret => token.secret})
  end

  # username - ユーザ名を取得する
  #--------------------------------------------------------------------
  def username
    @authed and return @twitter.info['screen_name']
  end

  # icon - ユーザのアイコンを取得する
  #--------------------------------------------------------------------
  def icon
    @authed and return @twitter.info['profile_image_url']
  end

  # tweet - ツイートする
  #-------------------------------------------------------------------
  def tweet(text)
    @twitter.update(text)
  end
end
