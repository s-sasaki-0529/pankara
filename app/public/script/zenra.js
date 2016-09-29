/*全てのページで読み込み時に実行*/
$(function(){
  //テーブルをソート可能に
  $('.sortable').tablesorter();
});

/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
post - 情報を非同期で送信する
*/
zenra.post = function(url , data , opt) {
  var beforeSend = opt['beforeSend'] || function(){};
  var success = opt['success'] || function(){};
  var error = opt['error'] || function(){};
  data['authenticity_token'] = $('#authenticity_token').val();
  $.ajax({
    type: "POST" ,
    url: url ,
    data: data ,
    beforeSend: beforeSend ,
    success: success ,
    error: error ,
  });
};

/*
get - 非同期で通信する
*/
zenra.get = function(url , funcs) {
  var funcs = funcs || {};
  $.ajax({
    type: "GET" ,
    url: url ,
  });
};

/*
parseJSON - JSON文字列をJSオブジェクトに変換する
*/
zenra.parseJSON = function(json) {
  if (window.JSON) {
    return JSON.parse(json);
  } else {
    alert('ブラウザがJSONに対応していません');
  }
  return false;
};

/*
toJSON - JSオブジェクトをJSON文字列に変換する
*/
zenra.toJSON = function(obj) {
  if (window.JSON) {
    return JSON.stringify(obj);
  } else {
    alert('ブラウザがJSONに対応していません');
  }
  return false;
}

/*
createPieChart - 円グラフを生成する
targetSelecter: 描画対象要素のセレクタ
dataSelecter: 対象データのJSONを持つ要素のセレクタ
opt: 拡張オプション
*/
zenra.createPieChart = function(targetSelecter , data, opt) {
  c3.generate({
    bindto: targetSelecter,
    data: {
      columns: data,
      type: 'pie',
      order: null,
    }
  });
}

/*
createStickChart - 棒グラフを生成する
targetSelecter: 病害対象要素のセレクタ
dataSelecter: 対象データのJSONを持つ要素のセレクタ
opt: 拡張オプション
*/
zenra.createBarChart = function(targetSelecter , data , key , values , groups , opt) {
  var param = {rotated: false , max: null , min: null , color: null};
  $.extend(param , opt);
  c3.generate({
    bindto: targetSelecter,
    data: {
      json: data,
      keys: {x: key, value: values},
      type: 'bar',
      groups: groups,
    },
    axis: {
      rotated: param['rotated'],
      x: {type: 'category'},
      y: {
        max: param['max'],
        min: param['min'],
      },
    },
    color: {
      pattern: param['color'],
    },
  });
};

/*
createFavoriteArtistsPieChart - お気に入り歌手ベスト10の構成を円グラフで表示する
targetSelecter: 描画対象要素のセレクタ
*/
zenra.createFavoriteArtistsPieChart = function(targetSelecter , user) {
  zenra.post('/ajax/user/artist/favorite' , {'user': user} , {
    success: function(json) {
      response = zenra.parseJSON(json);
      if (response.result == 'success') {
        zenra.createPieChart(targetSelecter , response.info);
      }
    },
  });
};

/*
createMonthlySangCountBarChart - 対象楽曲(アーティスト)の月ごとの歌われた回数を棒グラフで表示する
song: songID
targetSelecter: 描画対象要素のセレクタ
*/
zenra.createMonthlySangCountBarChart = function(url , id , targetSelecter) {
  zenra.post(url , {id: id} , {
    success: function(json) {
      response = zenra.parseJSON(json);
      if (response.result == 'success') {
        //データを元にユーザ一覧を生成
        var data = response.info;
        users = [];
        data.forEach(function(e) {users = users.concat(Object.keys(e))});
        users = users.filter(function (x, i, self) { return self.indexOf(x) === i && x != '_month';});
      }
      zenra.createBarChart(targetSelecter , data , '_month' , users , [users] , {rotated: true});
      $(targetSelecter + '_json').text(json)
    },
  });
};

/*
createAggregatedScoreBarChart - 対象楽曲の得点集計を棒グラフで表示する
song: songID
scoreType: score_type
targetSelecter: 描画対象のセレクタ
*/
zenra.scoreBarChart = (function() {

  var currentScoreType = 1;
  var targetSelecter;
  var songId;
  var scoreTypeNum;
  var isBusy = false;

  function _create() {
    isBusy = true;
    zenra.post('/ajax/song/tally/score' , {song: songId, score_type: currentScoreType} , {
      success: function(json) {
        var response = zenra.parseJSON(json);
        if (response.result == 'success') {
          var scoreTypeName = response.info.score_type_name;
          var scores = response.info.scores
          var values = [];
          var colors = [];
          if (scores[0]['あなた']) {
            values.push('あなた');
            colors.push('rgb(31,119,180)');
          }
          if (scores[0]['みんな']) {
            values.push('みんな');
            colors.push('rgb(255,127,14)');
          }
          zenra.createBarChart(targetSelecter , scores , 'name' , values , [] , {max: 100 , min: 60 , color: colors});
          $('#score_type_name').text(scoreTypeName);
          $(targetSelecter + '_json').text(json)
        }
        isBusy = false;
      },
    });
  }

  function _init(song , current , num , target) {
    songId = song;
    currentScoreType = current;
    scoreTypeNum = num;
    targetSelecter = target;
    _create();
  }

  function _next() {
    if (isBusy) return;
    currentScoreType++;
    if (currentScoreType == scoreTypeNum + 1) {
      currentScoreType = 1;
    }
    _create();
  }

  function _prev() {
    if (isBusy) return;
    currentScoreType--;
    if (currentScoreType == 0) {
      currentScoreType = scoreTypeNum;
    }
    _create();
  }

  return {
    init: _init,
    next: _next,
    prev: _prev,
  };
})();

/*
createThumbnail - youtubeのサムネイルを生成する
*/
zenra.createThumbnail = function(idx , id , image , _width , _height) {
  if (image) {
    var $img = $('<img>').attr('src' , image);
    var song = $('#song_name_' + idx).text();
    var artist = $('#artist_name_' + idx).text();
    var defaultWidth = zenra.ispc ? 160 : 80;
    var defaultHeight = zenra.ispc ? 90 : 45;
    var width = _width || defaultWidth;
    var height = _height || defaultHeight;
    $img.css('width' , width).css('height' , height).css('cursor' , 'pointer');
    $img.attr('info' , song + ' (' + artist + ')');
    $img.click(function() {
      var opt = {title_cursor: 'pointer' , draggable: false}; 
      player_dialog = new dialog($img.attr('info') , 'player_dialog' , 600);
      player_dialog.show('/song/' + id + '/player' , 'player' , opt);
      $('.ui-dialog-title').unbind('click').click(function() {
        location.href = '/song/' + id
      });
    });
    $('#thumbnail_' + idx).append($img)
  } else {
    $('#thumbnail_' + idx).append('<span>未登録</span>');
  }
};

/*
createSeekbar - シークバーを作成する
*/
zenra.createSeekbar = function() {
  $('#seekbar').slider({
    value: 0 ,
    max: 6 ,
    min: -6 ,
    step: 1 ,

    create: function() {
      $("#slidervalue").html($('#seekbar').slider('value'));
    } ,
    change: function(event , ui) {
      $('#slidervalue').html(ui.value);
    } ,
    slide: function(event , ui) {
      $('#slidervalue').html(ui.value);
    } ,
  });
};

zenra.moshikashite = function(id , source) {
  $('#' + id).autocomplete({
    source: source ,
    minLength: 2 ,
  });
};

zenra.setOptionMoshikashite = function(id , opt , value) {
  $('#' + id).autocomplete(
    'option' ,
    opt ,
    value
  );
};

/*
  dialogオブジェクト -ダイアログ制御用オブジェクト-
  title: ダイアログのタイトル
  dialog_id: ダイアログエレメントに割り振るID
*/
var dialog = function(title , dialog_id , width , height) {
    if (!height) height = 'auto';
    this.title = title;
    this.dialog_id = dialog_id;
    this.width = width;
    this.height = height;
    if (! zenra.ispc ) {
      this.width = '100%';
      this.height = document.documentElement.clientHeight;
    }

    /*
    show - ダイアログを表示する
    opt: 拡張オプション
    url: ダイアログの内容を取得するURL
    id: URL内で取得する要素のID
    */
    this.show = function(url , id , opt) {
      opt = opt || {};
      funcs = opt['funcs'] || {};
      func_at_load = opt['func_at_load'] || function(){};
      var position = opt['position'] || 'center';
      var dialog = $('<div>').attr('id' , this.dialog_id);
      var scroll = $(window).scrollTop();
      dialog.dialog({
        title: this.title ,
        modal: true ,
        height: this.height ,
        width: this.width ,
        resizable: opt['resizable'] || false ,
        draggable: opt['draggable'] == false ? false : true ,
        close: function(event) {
          $(this).dialog('destroy');
          $(event.target).remove();
        } ,
        beforeClose: funcs.beforeClose ,
      });
    
      var div = $('<div></div>');
      div.load(url + " #" + id , function(date , status) {
        if (! zenra.ispc) {
          $('.ui-dialog').css({'top' : 0 , 'z-index': 9999}); 
        }
        else if (position == 'center') {
          var margin = div.height() / 2;
          $('.ui-dialog').css({'top': scroll + margin + 'px' , 'z-index': 9999});
          div.css('overflow' , 'hidden');
          $(window).scrollTop(scroll);
        } else if (position == 'head') {
          $('.ui-dialog').css({'top' : 70 , 'z-index': 9999});
          $(window).scrollTop(0);
        }
        func_at_load();
        $('#' + id).tooltip('disable');
      });
    
      //オプション: タイトルバーにオンマウス時のカーソル
      $('.ui-dialog-title').css('cursor' , opt['title_cursor'] || '');
    
      dialog.html(div);
    };
    
    /*
    close - ダイアログを閉じる
    */
    this.close = function() {
      var div = $('#' + this.dialog_id);
      div.dialog('close');
    };

    /*
    transition - ダイアログ内の画面を遷移する
    */
    this.transition = function(url , id , opt) {
      var opt = opt || {};
      var func_at_load = opt['func_at_load'] || function(){};
    
      var div = $('#' + this.dialog_id);
    
      jQuery.removeData(div);
      div.load(url + " #" + id , function(date , status) {
        func_at_load();
        $('#' + id).tooltip('disable');
      });
    };
    
    /*
    setEvent - ダイアログにイベントを設定する
    */
    this.setEvent = function(event_obj) {
      var dialog_events = ['beforeClose' , 'close'];
    
      var events = {};
      Object.keys(event_obj).forEach(function(key) {
        for (var i = 0; i < dialog_events.length; i++) {
          if (key == dialog_events[i]) {
            events[key] = event_obj[key];
            return;
          }
        }
      });
    
      var div = $('#' + this.dialog_id);
      div.dialog(events);
    };
};

/*
  bathtowelオブジェクト -バスタオルの制御全般-
*/
var bathtowel = {

  /*[Method] バスタオルの初期設定*/
  init : function () {

    //楽曲情報表示用
    self.info = $('<div>').attr('id' , 'bathtowel_info').css('display' , 'none');
    self.info.appendTo('body');

    //オンマウス時に曲名を通知
    if (zenra.ispc) {
      $('.bathtowel-li').each(function() {
        var text = $(this).children('img').attr('info');
        $(this).hover(
          function() { self.info.text(text).css('display' , ''); } ,
          function() { self.info.css('display' , 'none'); }
        );
      });
    }

    //バスタオルを再生
    $('#slider').simplyScroll({
      autoMode: 'loop' ,
      speed: 1 ,
      frameRate: 30 ,
      horizontal: true ,
      pauseOnHover: false ,
      pauseOnTouch: true
    });

  },

};

/*
  cookieオブジェクト -クッキーに関する制御全般-
*/
var cookie = {
 
  /*[Method] クッキーを設定する*/
  setCookie : function(name , value) {
    document.cookie = name + '=' + encodeURIComponent(value);
  } ,

  /*[Method] クッキーを連想配列にして取得する*/
  getCookies : function() {
    var result = new Array();
  
    var all_cookies = document.cookie;
    if (all_cookies == '') {
      return;
    }
  
    var cookies = all_cookies.split('; ');
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i].split('=');
  
      result[cookie[0]] = decodeURIComponent(cookie[1]);
    }
  
    return result;
  } ,

  /*[Method] 指定したクッキーが設定されているか返す*/
  isExist : function(name) {
    var all_cookies = document.cookie;
    if (all_cookies == '') {
      return false;
    }
  
    cookies = all_cookies.split('; ');
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i].split('=');
  
      if (cookie[0] == name) {
        return true;
      }
    }
  
    return false;
  }

};

/*
  registerオブジェクト -カラオケ入力制御全般-
*/
var register = (function() {
  //var count = 0;
  var close_flg = false;
  var store_list = [];
  var branch_list = [];
  var song_obj = [];
  var song_list = [];
  var artist_list = [];
  var input_dialog;

  /*[Method] 歌唱履歴入力欄をリセットする*/
  function resetHistory() {
    $('#song').val('');
    $('#artist').val('');
    $('#seekbar').slider('value' , 0);
    $('#score').val('');
    $('#song').focus();
    
    zenra.setOptionMoshikashite('artist' , 'minLength' , 2);
    zenra.setOptionMoshikashite('artist' , 'source' , artist_list);
    
    zenra.setOptionMoshikashite('song' , 'minLength' , 2);
    zenra.setOptionMoshikashite('song' , 'source' , song_list);
  }

  /*[Method] ダイアログを閉じる時に実施する処理*/
  function beforeClose() {
    if (window.confirm('終了してもよろしいですか')) {
      //count = 0;

      return true;
    }
    
    return false;
  };

  /*[method] カラオケ入力欄にカラオケ情報をセットする*/
  function setKaraokeToInput(karaoke) {
    $('#name').val(karaoke['name']);
    $('#datetime').val(karaoke['datetime']);
    $('#plan').val(karaoke['plan']);
    $('#store').val(karaoke['store_name']);
    $('#branch').val(karaoke['branch_name']);
    $('#product').val(karaoke['product']);
  }

  /*[method] 歌唱履歴入力欄に歌唱履歴情報をセットする*/
  function setHistoryToInput(history) {
    $('#song').val(history['song_name']);
    $('#artist').val(history['artist_name']);
    $('#seekbar').slider('value' , history['songkey']);
    $('#score_type').val(history['score_type']);
    $('#score').val(history['score']);
    
    if (history['score_type'] > 0) {
      $('#score_area').show();
    }
  }

  /*[method] 参加入力欄に情報をセットする*/
  function setAttendanceToInput(attendance) {
    $('#price').val(attendance['price']);
    $('#memo').val(attendance['memo']);
  }
  
  /*[method] カラオケ入力画面用ウィジェットを作成する*/
  function createWidgetForKaraoke() {
    // お店のもしかしてリスト作成
    zenra.post('/ajax/storelist' , {} , {
      success: function(result) {
        var branch_list = zenra.parseJSON(result);

        // オブジェクトのキーをお店リストとして取得
        store_list = [];
        for (key in branch_list) {
          store_list.push(key);
        }

        zenra.moshikashite('store' , store_list);
      }
    });

    // お店を入力すると店舗のもしかしてリストが作成される
    $('#store').blur(function() {
      if ($(this).val() in branch_list) {
        zenra.moshikashite('branch' , branch_list[$(this).val()]);
      }
    });

    //日付時刻入力用のカレンダーを生成
    $('#datetime').datetimepicker({
      lang: 'ja' ,
      step: 10 ,
    });

    //ツイートするチェックボックスのイベントを定義
    $('#tweet-checkbox').change(function() {
      if ($(this).prop('checked')) {
        $('#tweet_text_area').removeClass('hidden');
      } else {
        $('#tweet_text_area').addClass('hidden');
      }
    });
  }

  /*[method] 歌唱履歴入力画面用ウィジェットを作成する*/
  function createWidgetForHistory() {
    zenra.createSeekbar();

    // 曲名と歌手名の対応表を取得
    zenra.post('/ajax/songlist' , {} , {
      success: function(result) {
        song_obj = zenra.parseJSON(result);

        // オブジェクトを曲名リストと歌手名リストに分割
        song_list = [];
        artist_list = [];
        for (key in song_obj) {
          song_list.push(key);

          if (artist_list.indexOf(song_obj[key]) < 0) {
            artist_list.push(song_obj[key]);
          }
        }

        zenra.moshikashite('song' , song_list);
        zenra.moshikashite('artist' , artist_list);
      }
    });

    createInputSongEvent();
    createInputArtistEvent();

    $('#score_type').change(function() {
      if ($('#score_type').val() == 0) {
        $('#score_area').hide();
      }
      else {
        $('#score_area').show();
      }
    });

    $('#tweet-checkbox').change(function() {
      if ($(this).prop('checked')) {
        $('#tweet_text_area').removeClass('hidden');
      } else {
        $('#tweet_text_area').addClass('hidden');
      }
    });

  }

  /*[method] 曲名入力に関するイベントを作成する*/
  function createInputSongEvent() {
    $('#song').blur(function() {
      // 曲名を入力すると歌手名を自動入力する
      if ($(this).val() in song_obj) {
        $('#artist').val(song_obj[$(this).val()]);
      }

      autoInputSongKey();
    });

    $('#artist').focus(function() {
      var temp_artist_list = [];

      // 入力された曲を歌っている歌手名でもしかしてリストを生成
      if ($('#song').val() in song_obj) {
        for (key in song_obj) {
          if (key == $('#song').val()) {
            temp_artist_list.push(song_obj[key]);
          }
        }

        zenra.setOptionMoshikashite('artist' , 'minLength' , 0);
        zenra.setOptionMoshikashite('artist' , 'source' , temp_artist_list);
      }
      else {
        zenra.setOptionMoshikashite('artist' , 'minLength' , 2);
        zenra.setOptionMoshikashite('artist' , 'source' , artist_list);
      }
    });
  }

  /*[method] 歌手名入力に関するイベントを作成する*/
  function createInputArtistEvent() {
    // 歌手名が入力されるとその歌手が歌っている曲でもしかしてリストを生成
    $('#artist').blur(function() {
      var temp_song_list = [];

      for (key in song_obj) {
        if (song_obj[key] === $('#artist').val()) {
          temp_song_list.push(key);
        }
      }

      if (temp_song_list.length > 0) {
        zenra.setOptionMoshikashite('song' , 'minLength' , 0);
        zenra.setOptionMoshikashite('song' , 'source' , temp_song_list);
      }
      else {
        zenra.setOptionMoshikashite('song' , 'minLength' , 2);
        zenra.setOptionMoshikashite('song' , 'source' , song_list);
      }
      
      autoInputSongKey();
    });
  }

  /*[method] キーをajaxで取得して自動で入力する*/
  function autoInputSongKey() {
    // 曲名とアーティスト名が入力されたらキーを自動入力する
    if ($('#song').val() != '' && $('#artist').val() != '') {
      var song = {
        name: $('#song').val() ,
        artist: $('#artist').val()
      }

      zenra.post('/ajax/key' , song , {
        success: function(result) {
          var result_obj = zenra.parseJSON(result);
          
          if (result_obj['result'] == 'success') {
            var songkey = result_obj['songkey'];

            $('#seekbar').slider('value' , songkey);
          }
        }
      });
    }
  }

  /*[method] カラオケ編集画面用の要素を作成する*/
  function createElementForEditKaraoke(karaoke_id) {
    $('#button1').attr('onclick' , 'register.submitKaraokeEditRequest(' + karaoke_id + ');').val('保存');
    var button2 = $('<input>').attr('id' , 'button2').attr('type' , 'button');
    button2.attr('onclick' , 'register.submitKaraokeDeleteRequest(' + karaoke_id + ');').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'register.closeDialog();').val('キャンセル');

    $('#buttons').append(button2);
    $('#buttons').append(button3);
  }
  
  /*[method] 参加情報入力画面用の要素を作成する*/
  function createElementForEditAttendance(karaoke_id , action) {
    var action_button = $('<input>').attr('id' , 'action_button').attr('type' , 'button');
    var cancel_button = $('<input>').attr('id' , 'cancel_button').attr('type' , 'button');

    if (action == 'registration') {
      action_button.attr('onclick' , 'register.submintAttendanceRegistrationRequest(' + karaoke_id + ');').val('次へ');
    }
    else {
      action_button.attr('onclick' , 'register.submintAttendanceEditRequest(' + karaoke_id + ');').val('保存');
    }

    cancel_button.attr('onclick' , 'register.closeDialog();').val('キャンセル');
    var buttons = $('#buttons');
    buttons.append(action_button);
    buttons.append(cancel_button);
  }
  
  /*[method] 歌唱履歴編集画面用の要素を作成する*/
  function createElementForEditHistory(karaoke_id , history_id) {
    $('#button1').attr('onclick' , 'register.submitHistoryEditRequest(' + karaoke_id + ' , ' + history_id + ');').val('保存');
    $('#button2').attr('onclick' , 'register.submitHistoryDeleteRequest(' + karaoke_id + ' , ' + history_id + ');').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'register.closeDialog();').val('キャンセル');
    $('#buttons').append(button3);
  }
    
  /*[method] 入力されたカラオケデータを取得する*/
  function getKaraokeData() {
    var data = {
      name: $('#name').val() ,
      datetime: $('#datetime').val() ,
      plan: $('#plan').val() ,
      store_name: $('#store').val() ,
      store_branch: $('#branch').val() ,
      product: $('#product').val() ,
      price: $('#price').val() ,
      memo: $('#memo').val() ,
    };
    if ($('#tweet-checkbox').prop('checked')) {
      data.twitter = 1;
      if ($('#tweet_textbox').val() != "") {
        data.tweet_text = '\n\n' + $('#tweet_textbox').val();
      }
    }
    return data;
  }
    
  /*[method] 入力された歌唱履歴データを取得する*/
  function getHistoryData() {
    var data = {
      song_name: $('#song').val() ,
      artist_name: $('#artist').val() ,
      songkey: $('#seekbar').slider('value') ,
      score: $('#score').val() ,
      score_type: $('#score_type').val() ,
    };
    if ($('#tweet-checkbox').prop('checked')) {
      data.twitter = 1;
      if ($('#tweet_textbox').val() != "") {
        data.tweet_text = '\n\n' + $('#tweet_textbox').val();
        $('#tweet_textbox').val("");
      }
    }
    return data;
  }
  
  /*[method] 入力された参加情報データを取得する*/
  function getAttendanceData() {
    var data = {
      price: $('#price').val() ,
      memo: $('#memo').val() ,
    };

    return data;
  }
  
  /*[method] 採点方法にクッキーの値を設定する*/
  function setScoreTypeFromCookie() {
    if (cookie.isExist('score_type')) {
      var cookies = cookie.getCookies();
      $('#score_type').val(cookies['score_type']);
      $('#score_area').show();
    }
  }

  return {
    /*[Method] カラオケ入力画面を表示する*/
    createKaraoke : function() {
      input_dialog = new dialog('カラオケ新規作成' , 'input_dialog' , 450);
      
      input_dialog.show('/ajax/karaoke/dialog' , 'input_karaoke' , {
        funcs: {
          beforeClose: beforeClose
        } ,
        func_at_load: function() {
          s = zenra.formatDate(new Date , 'YYYY/MM/DD hh:mm');
          createWidgetForKaraoke();
          $('#button1').attr('onclick' , 'register.submitKaraokeRegistrationRequest();').val('次へ')
          $('#datetime').val(s);
        }
      });
    } ,

    /*[Method] 参加情報登録画面を表示する*/
    createAttendance : function(karaoke_id) {
      input_dialog = new dialog('参加情報登録' , 'input_dialog' , 600)
      input_dialog.show('/ajax/karaoke/dialog' , 'input_attendance' , {
        funcs: {
          beforeClose: beforeClose
        } ,
        func_at_load: function() {
          createElementForEditAttendance(karaoke_id , 'registration');
        }
      });
    } ,
    
    /*[Method] 歌唱履歴入力画面を表示する*/
    createHistory : function(karaoke_id) {
      input_dialog = new dialog('歌唱履歴追加' , 'input_dialog' , 450)
      input_dialog.show('/ajax/history/dialog' , 'input_history' , {
        func_at_load: function() {
          createWidgetForHistory();
          setScoreTypeFromCookie();

          $('#button1').attr('onclick' , 'register.submitHistoryRegistrationRequest("continue" , ' + karaoke_id + ');').val('続けて登録');
          $('#button2').attr('onclick' , 'register.submitHistoryRegistrationRequest("end" , ' + karaoke_id + ');').val('登録して終了');
        } ,
        funcs: {
          beforeClose: beforeClose
        }
      });
    } ,

    /*[Method] 楽曲新規登録画面を表示する*/
    createSong : function() {
      input_dialog = new dialog('楽曲登録' , 'input_dialog' , 450);
      input_dialog.show('/ajax/song/dialog' , 'input_song' , {
        funcs: {
          beforeClose: beforeClose
        },
        func_at_load: function() {
          createWidgetForHistory();
          $('#button1').attr('onclick' , 'register.submitCreateSongRequest()').val('登録');
          $('#button2').attr('onclick' , 'register.closeDialog()').val('キャンセル');
          $('#url_area').hide();
        }
      });
    },

    /*[Method] 楽曲編集画面を表示する*/
    editSong : function(song_id , youtube_id) {
      var song_name = $("#song_name").text();
      var artist_name = $("#artist_name").text();
      input_dialog = new dialog('楽曲編集' , 'input_dialog' , 450);
      input_dialog.show('/ajax/song/dialog' , 'input_song' , {
        func_at_load: function() {
          createWidgetForHistory();
          $('#button1').attr('onclick' , 'register.submitSongEditRequest(' + song_id + ')').val('登録');
          $('#button2').attr('onclick' , 'register.closeDialog()').val('キャンセル');
          $('#song').val(song_name);
          $('#artist').val(artist_name);
          $('#url').val('https://www.youtube.com/watch?v=' + youtube_id);
        }
      });
    },

    /*[Method] カラオケ編集画面を表示する*/
    editKaraoke : function(karaoke_id) {
      zenra.post('/ajax/karaokelist/' , {id: karaoke_id} , {
        success: function(result) {
          var karaoke = zenra.parseJSON(result);

          input_dialog = new dialog('カラオケ編集' , 'input_dialog' , 450)
          input_dialog.show('/ajax/karaoke/dialog' , 'input_karaoke' , {
            func_at_load: function() {
              createWidgetForKaraoke();
              setKaraokeToInput(karaoke);
              createElementForEditKaraoke(karaoke['id']);
            } ,
            funcs: {
              beforeClose: beforeClose
            }
          });
        }
      });
    } ,
    
    /*[Method] 参加情報編集画面を表示する*/
    editAttendance : function(karaoke_id) {
      zenra.post('/ajax/attendance' , {id: karaoke_id} , {
        success: function(result) {
          var attendance = zenra.parseJSON(result);
      
          input_dialog = new dialog('参加情報編集' , 'input_dialog' , 600)
          input_dialog.show('/ajax/karaoke/dialog' , 'input_attendance' , {
            funcs: {
              beforeClose: beforeClose
            } ,
            func_at_load: function() {
              createElementForEditAttendance(karaoke_id , 'edit');

              setAttendanceToInput(attendance);
            }
          });
        }
      });
    } ,

    /*[Method] 歌唱履歴編集画面を表示する*/
    editHistory : function(karaoke_id , history_id) {
      zenra.post('/ajax/historylist/' , {id: history_id} , {
        success: function(result) {
          var history = zenra.parseJSON(result);

          input_dialog = new dialog('歌唱履歴編集' , 'input_dialog' , 450)
          input_dialog.show('/ajax/history/dialog' , 'input_history' , {
            func_at_load: function() {
              createWidgetForHistory();
              createElementForEditHistory(karaoke_id , history_id);
              setHistoryToInput(history);
            } ,
            funcs: {
              beforeClose: beforeClose
            }
          });
        }
      });
    } ,
    
    /*[Method] カラオケ情報登録リクエストを送信する*/
    submitKaraokeRegistrationRequest : function() {
      var data = getKaraokeData();

      zenra.post('/ajax/karaoke/create' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          
          if (response['result'] == 'success') {
            var karaoke_id = response['karaoke_id'];

            input_dialog.transition('/ajax/history/dialog' , 'input_history' , {
              func_at_load: function() {
                createWidgetForHistory();

                $('#button1').attr('onclick' , 'register.submitHistoryRegistrationRequest("continue" , ' + karaoke_id + ');').val('続けて登録');
                $('#button2').attr('onclick' , 'register.submitHistoryRegistrationRequest("end" , ' + karaoke_id + ');').val('登録して終了');
              } ,
            });
          }
          else {
            alert('カラオケの登録に失敗しました。');
          }
        } ,
        error: function() {
          alert('カラオケの登録に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] カラオケ情報編集リクエストを送信する*/
    submitKaraokeEditRequest : function(karaoke_id) {
      var json_data = zenra.toJSON(getKaraokeData());

      zenra.post('/ajax/karaoke/modify/' , {id: karaoke_id , params: json_data} , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          
          if (response['result'] == 'success') {
            location.href = ('/karaoke/detail/' + karaoke_id);
          }
          else {
            alert('カラオケの編集に失敗しました');
          }
        } ,
        error: function() {
          alert('カラオケの編集に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] 参加情報登録リクエストを送信する*/
    submintAttendanceRegistrationRequest : function(karaoke_id) {
      var data = {karaoke_id: karaoke_id};
      zenra.post('/ajax/attendance/create' , data , {async: false});
    } ,

    /*[Method] 参加情報編集リクエストを送信する*/
    submintAttendanceEditRequest : function(karaoke_id) {
      var json_data = zenra.toJSON(getAttendanceData());
      
      zenra.post('/ajax/attendance/modify/', {id: karaoke_id, params: json_data} , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);

          if (response['result'] == 'success') {
            location.href = ('/karaoke/detail/' + karaoke_id);
          }
          else {
            alert('参加情報の編集に失敗しました');
          }
        }
      });
    } ,

    /*[Method] 楽曲情報編集リクエストを送信する*/
    submitSongEditRequest : function(song_id) {
      var youtubeID = $('#url').val().match(/watch\?v=(.+)$/);
      if (! youtubeID) {
        alert('URLに誤りがあります');
        return false;
      }
      var data = {song: $('#song').val(), artist: $('#artist').val(), url: youtubeID[1], song_id: song_id};
      zenra.post('/ajax/song/modify' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          if (response['result'] == 'success') {
            location.href = ('/song/' + song_id);
          } else {
            alert('楽曲情報の編集に失敗しました。');
          }
        } ,
        error: function() {
          alert('楽曲情報の編集にしっぱいしました。サーバにアクセスできません。');
        }
      });
    },

    /*[Method] 歌唱履歴登録リクエストを送信する*/
    submitHistoryRegistrationRequest : function(action , karaoke_id) {
      var data = getHistoryData();
      data.karaoke_id = karaoke_id;

      // 参加情報の登録リクエストを送信する
      register.submintAttendanceRegistrationRequest(karaoke_id);
      
      zenra.post('/ajax/history/create' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          if (response['result'] == 'success') {
            //count += 1;
            var sangInfo = response['info'];
            var mes = sangInfo['song'] + '(' + sangInfo['artist'] + ')' + 'を登録しました。</br>';
            mes += 'あなたがこの曲を歌うのは ' + sangInfo['sang_count'] + ' 回目です。';
            $('#result').html('<p>' + mes + '</p>');
            //$('#result').html('<p>' + count + '件入力されました</p>');
            
            if (action == 'end') {
              //count = 0;
              
              input_dialog.setEvent({
                beforeClose: function() { return true; } ,
              });
              input_dialog.close();
             
              location.href = ('/karaoke/detail/' + karaoke_id);
            }
          }
          else {
            alert('歌唱履歴の登録に失敗しました。');
          }
        } ,
        error: function() {
          alert('歌唱履歴の登録に失敗しました。サーバにアクセスできません。');
        }
      });

      cookie.setCookie('score_type' , $('#score_type').val());
      resetHistory();
      
    } ,

    /*[Method] 楽曲新規登録リクエストを送信する*/
    submitCreateSongRequest : function(opt) {
      var data = {song: $('#song').val(), artist: $('#artist').val()};
      zenra.post('/ajax/song/create' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          if (response['result'] == 'success') {
            location.href = '/song/' + response['info'];
          } else {
            alert('楽曲の新規登録に失敗しました');
          }
        },
      });
    } ,
    /*[Method] 歌唱履歴編集リクエストを送信する*/
    submitHistoryEditRequest : function(karaoke_id , history_id) {
      var json_data = zenra.toJSON(getHistoryData());

      zenra.post('/ajax/history/modify/', {id: history_id, params: json_data} , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          
          if (response['result'] == 'success') {
            location.href = ('/karaoke/detail/' + karaoke_id);
          }
          else {
            alert('歌唱履歴の編集に失敗しました。');
          }
        } ,
        error: function() {
          alert('歌唱履歴の編集に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] カラオケ削除リクエストを送信する*/
    submitKaraokeDeleteRequest : function(karaoke_id) {
      if (! confirm('カラオケを削除します。よろしいですか？')) {
        return;
      }
      zenra.post('/ajax/karaoke/delete/' , {id: karaoke_id} , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);

          if (response['result'] == 'success') {
            location.href = '/';
          } else {
            alert('カラオケの削除に失敗しました。');
          }
        } ,
        error: function() {
          alert('カラオケの削除に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] 歌唱履歴削除リクエストを送信する*/
    submitHistoryDeleteRequest : function(karaoke_id , history_id) {
      zenra.post('/ajax/history/delete/' , {id: history_id} , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);

          if (response['result'] == 'success') {
            location.href = ('/karaoke/detail/' + karaoke_id);
          } else {
            alert('歌唱履歴の削除に失敗しました。');
          }
        } ,
        error: function() {
          alert('歌唱履歴の削除に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,
    
    /*[Method] 入力ダイアログを閉じる*/
    closeDialog : function() {
      input_dialog.close();
    } ,
  }

})();

zenra.showAggregateDialog = function(user) {
  var url = '/ajax/user/' + user + '/aggregate/dialog';
  var input_dialog = new dialog('集計情報' , 'aggregate_dialog' , 600 , 500);
  input_dialog.show(url , 'aggregate' , {
    func_at_load: function() {
    } ,
    position: zenra.ispc ? 'auto' : 'head' ,
    resizable: true
  });
};

zenra.showSongTagList = function(id , user) {
  var url = '/ajax/song/tag/list';
  var data = {song: id};
  function resetTagElements() {
    $('.song-tag').remove();
  }
  function addTagElement(tag) {
    var $td1 = $('<td><a href="/search/tag/?tag=' + tag['name'] + '">' + tag['name'] + '</a></td>');
    var $removeIcon;
    if (tag['created_by'] == user) {  //自身が登録したタグの場合のみ、削除アイコンを表示
      $removeIcon = $("<img src='/image/delete_tag.png' width=16px'>").click(function() {
        zenra.removeSongTag(user , id , tag);
      });
    } else {
      $removeIcon = $("<span>");
    }
    var $td2 = $('<td>').append($removeIcon);
    var $tr = $('<tr class="song-tag">').append($td1).append($td2);
    $('#tag_list_table').append($tr);
  }
  zenra.post(url , data , {
    success: function(json) {
      var response = zenra.parseJSON(json);
      if (response.result == 'error') return;
      var tags = response.info;
      resetTagElements();
      tags.forEach(function(tag) { addTagElement(tag) });
      var title = tags.length > 0 ? '登録済みタグ' : 'タグが登録されていません';
      $('#tag_list_header').text(title);
      if (tags.length < 10) {
        $('#add_tag').removeClass('hidden');
      } else {
        $('#add_tag').addClass('hidden');
      }
    },
  });
};

zenra.addSongTag = function(user , id) {
  var url_from = '/song/' + id;
  var url_to = url_from + '/tag/add';
  jPrompt('追加するタグ名を入力してください。空白区切りで複数のタグを一度に登録できます', '', 'タグを新規登録', function(r) {
    var data = {tag_name: r};
    var opt = {success: function() { zenra.showSongTagList(id , user) }};
    zenra.post(url_to , data , opt);
  });
};

zenra.removeSongTag = function(user , id , tag) {
  var url_from = '/song/' + id;
  var url_to = url_from + '/tag/remove';
  var mes = 'タグ [' + tag['name'] + '] を削除します。よろしいですか？';
  jConfirm(mes, '確認', function(r) {
    if (!r) return;
    var data = {tag_name: tag['name'] , created_by: tag['created_by']};
    var opt = {success: function() { zenra.showSongTagList(id , user) }};
    zenra.post(url_to , data , opt);
  });
};

/*プレイリストオブジェクト*/
zenra.playlist = (function() {

  var element_id;
  var player_width;
  var player_height;
  var yt;
  var target;
  var list
  var songs;

  /*[Event] プレイヤーのステータス変化を検知*/
  function onStateChange(e) {
    state = e.data;
    if (state == -1) {        //再生前
    } else if (state == 0) {  //再生終了
    } else if (state == 1) {  //再生中
      rewriteSongInfo();
    } else if (state == 2) {  //一時停止
    } else if (state == 3) {  //バッファ中
    } else if (state == 5) {  //ビデオがキューに入った
    }
  }

  /*[Method] 再生リストを設定する(チェックされていない動画を除外)*/
  function cuePlaylist(index_id) {
    var index = 0;
    var playlist = [];
    Object.keys(list).forEach(function(k) {
      if(list[k]) {
        playlist.push(k);
      }
    });
    if (index_id) {
      index = playlist.indexOf(index_id);
    }
    target.cuePlaylist(playlist , index);
    setTimeout(_play , 1000);  //タイムラグ
  }

  /*[Method] 再生リストを作成する*/
  function _init(id , width , height) {
    element_id = id;
    player_width = width;
    player_height = height;
    songs = zenra.parseJSON($('#songs_json').text());
    list = {};
    Object.keys(songs).forEach(function(k) {
      list[k] = true;
    });
    yt = new YT.Player(element_id , {
      width: player_width ,
      height: player_height,
      playerVars: {
        autoplay: 1,
        loop: 1,
        listType: 'playlist',
        list: 'playlist',
        rel: 0
      },
      events: {
        'onReady' : function(event) {
          target = event.target;
          cuePlaylist();
        } ,
        'onStateChange' : onStateChange
      }
    });

    //再生可否チェックボックスのイベント
    $('.playlist-checked').on('change' , function() {
      var element_id = $(this).attr('id');
      var youtube_id = element_id.match(/playlist_checked_(.+)/)[1];
      var checked = $(this).prop('checked');
      var $parent_row = $(this).parent().parent();
      if (checked) {$parent_row.removeClass('translucent');}
      else { $parent_row.addClass('translucent');}
      list[youtube_id] = checked;
      cuePlaylist();
    });
  }

   /*[Method] 指定したインデックスの楽曲を再生する*/
  function _set(index_id) {
    if (list[index_id]) {
      cuePlaylist(index_id);
    }
  }

  /*[Method] プレイヤーを再生*/
  function _play() {
    if (target) {
      target.playVideo();
    }
  }

  /*[Method] プレイヤーを一時停止*/
  function _pause() {
    if (target) {
      target.pauseVideo();
    }
  }

  /*[Method] 再生中の楽曲情報を更新する*/
  function rewriteSongInfo() {
    var url = yt.getVideoUrl();
    var id = url.match(/^.+v=(.+)$/)[1];
    var song_id = songs[id].song_id;
    $('#song_name').text(songs[id].song_name);
    $('#artist_name').text(songs[id].artist_name);
    $(".song-rows").removeClass('current-song');
    $("#song_row_" + song_id).addClass('current-song');
  }

  return {
    init: _init ,
    set: _set ,
    play: _play ,
    pause: _pause ,
  };
})();

zenra.formatDate = function (date, format) {
  if (!format) format = 'YYYY-MM-DD hh:mm:ss.SSS';
  format = format.replace(/YYYY/g, date.getFullYear());
  format = format.replace(/MM/g, ('0' + (date.getMonth() + 1)).slice(-2));
  format = format.replace(/DD/g, ('0' + date.getDate()).slice(-2));
  format = format.replace(/hh/g, ('0' + date.getHours()).slice(-2));
  format = format.replace(/mm/g, ('0' + date.getMinutes()).slice(-2));
  format = format.replace(/ss/g, ('0' + date.getSeconds()).slice(-2));
  if (format.match(/S/g)) {
    var milliSeconds = ('00' + date.getMilliseconds()).slice(-3);
    var length = format.match(/S/g).length;
    for (var i = 0; i < length; i++) format = format.replace(/S/, milliSeconds.substring(i, i + 1));
  }
  return format;
}
