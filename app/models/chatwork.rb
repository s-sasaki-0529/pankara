require 'net/http'
require 'uri'
require 'json'
require 'date'

class Chatwork

  @@API_BASE = 'https://api.chatwork.com/v2'

  # tokenを指定してオブジェクトを生成
  # tokenを省略した場合、環境変数を参照する
  def initialize(token = nil)
    @token = token || ENV['CHATWORKAPI']
  end

  # 自身のユーザ情報を取得する
  def me
    url = '/me'
    res = createHttpObject(url, :get)
    return JSON.parse(res.body)
  end

  # 自身の未読数、未読To数、未完了タスク数を取得する
  def myStatus
    url = '/my/status'
    res = createHttpObject(url, :get)
    return JSON.parse(res.body)
  end

  # 自身のタスク一覧を取得する(最大100件)
  # assigned_by_account_id: タスク依頼者のID
  # status: タスクステータス('open' or 'done')
  def myTasks(params = {})
    url = '/my/tasks'
    res = createHttpObject(url, :get, params)
    return res.body ? JSON.parse(res.body) : []
  end

  # 自身のコンタクト一覧を取得
  def myContacts
    url = '/contacts'
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # 自身のチャットルーム一覧を取得
  def myRooms
    url = '/rooms'
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームを新規作成
  # name:                 作成するルームの名称
  # members_admin_ids:    作成するルームの管理者ユーザ一覧
  # members_member_ids:   作成するルームの通常ユーザ一覧
  # members_readonly_ids: 作成するルームの閲覧のみユーザ一覧
  # description:          ルームの概要
  # icon_preset:          アイコン一覧
  def createRoom(name, members_admin_ids, params = {})
    url = '/rooms'
    params[:name] = name
    params[:members_admin_ids] = members_admin_ids.join(',')
    res = createHttpObject(url, :post, params)
    return res.body ? JSON.parse(res.body) : {}
  end

  # ルームの情報を取得
  # room_id 取得対象のID
  def getRoom(room_id)
    url = '/rooms/' + room_id
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : {}
  end

  # ルームの情報を更新
  # room_id:     更新対象のID
  # description: 更新後のルーム概要
  # icon_preset: 更新後のルームのアイコンセット
  # name:        更新後のルーム名
  def updateRoom(room_id, params = {})
    url = '/rooms/' + room_id
    res = createHttpObject(url, :put, params)
    return res.body ? JSON.parse(res.body) : {}
  end

  # ルームを退席する
  # room_id: 退席対象のID
  def leaveRoom(room_id)
    raise '未実装'
  end

  # ルームを削除する
  # room_id: 削除対象のID
  def deleteRoom(room_id)
    raise '未実装'
  end

  # ルームのメンバー一覧を取得
  # room_id: 対象のID
  def getRoomMembers(room_id)
    url = '/rooms/' + room_id + '/members'
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームのメンバーを更新
  # room_id: 対象のID
  def updateRoomMembers(room_id, params = {})
    raise '未実装'
  end

  # ルームのメッセージ一覧を取得(最大100件)
  # room_id: 対象のroomID
  # force:   常に最新100件のみ取得する場合は1
  def getRoomMessages(room_id, params = {})
    url = '/rooms/' + room_id + '/messages'
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームの特定のメッセージを取得
  # room_id:    対象のroomID
  # message_id: 対象のmessageID
  def getMessage(room_id, message_id)
    url = '/rooms/' + room_id + '/messages/' + message_id
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームに新規メッセージを送信
  # room_id: 対象のroomID
  # body:    投稿する本文
  def sendMessage(room_id, body)
    url = '/rooms/' + room_id + '/messages'
    res = createHttpObject(url, :post, {:body => body})
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームのタスク一覧を取得
  # room_id:     対象のroomID
  # account_id:  タスクの担当者IDでフィルタリング
  # assigned_by_account_id: タスクの依頼者IDでフィルタリング
  # status:      タスクのステータスでフィルタリング(open or done)
  def getRoomTasks(room_id, params = {})
    url = '/rooms/' + room_id + '/tasks'
    res = createHttpObject(url, :get, params)
    return res.body ? JSON.parse(res.body) : []
  end

  # ルームにタスクを追加
  # room_id: 対象のroomID
  # body:    タスクの内容
  # to_ids:  担当者のアカウント(array)
  # limit:   タスクの期限(Time)
  def createTask(room_id, body, to_ids = [], params = {})
    url = '/rooms/' + room_id + '/tasks'
    params[:body] = body
    params[:to_ids] = to_ids.join(',')
    params[:limit] = params[:limit].to_i if params[:limit].class == Time
    res = createHttpObject(url, :post, params)
    return res.body ? JSON.parse(res.body) : []
  end

  # タスク情報を取得
  # room_id: 対象のroomID
  # task_id: 対象のtaskID
  def getTask(room_id, task_id)
    url = '/rooms/' + room_id + '/tasks/' + task_id
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : {}
  end

  # アップロードされたファイル一覧を取得(最大100件)
  # room_id: 対象のroomID
  def getRoomFiles(room_id)
    url = '/rooms/' + room_id + '/files'
    res = createHttpObject(url, :get)
    return res.body ? JSON.parse(res.body) : []
  end

  # アップロードされたファイルの情報を取得
  # room_id: 対象のroomID
  # file_id: 対象のfileID
  # create_download_url: 30秒だけファイルをダウンロードできるURLを生成
  def getFile(room_id, file_id, params = {})
    url = '/rooms/' + room_id + '/files/' + file_id
    res = createHttpObject(url, :get, params)
    return res.body ? JSON.parse(res.body) : []
  end

  # 自分の対するコンタクト承認要求一覧を取得
  def incomingRequests
    raise '未実装'
  end

  # 自分に対するコンタクト承認要求を承認する
  # request_id: 対象のrequestID
  def approveRequest(request_id)
    raise '未実装'
  end

  # 自分に対するコンタクト承認要求を拒否する
  # request_id: 対象のrequestID
  def denyRequest(request_id)
    raise '未実装'
  end

  private
    # HTTPリクエストを送信する
    def createHttpObject(url, method, params = {})
      api_uri = URI.parse(@@API_BASE + url)
      https = Net::HTTP.new(api_uri.host, api_uri.port)
      https.use_ssl = true
      api_uri.query = URI.encode_www_form(params) if method == :get
      req = createRequestObject(method, api_uri)
      req["X-ChatWorkToken"] = @token
      req.set_form_data(params) unless method == :get
      https.request(req)
    end
    # リクエストオブジェクトを生成する
    def createRequestObject(method, uri)
      case method
        when :get
          return Net::HTTP::Get.new(uri.request_uri)
        when :post
          return Net::HTTP::Post.new(uri.request_uri)
        when :put
          return Net::HTTP::Put.new(uri.request_uri)
        when :delete
          return Net::HTTP::Delete.new(uri.request_uri)
      end
    end
end
