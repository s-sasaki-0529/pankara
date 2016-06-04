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
  var param = {rotated: false , max: null , min: null};
  $.extend(param , opt);
  c3.generate({
    bindto: targetSelecter,
    data: {
      json: data,
      keys: {x: key, value: values},
      type: 'bar',
      groups: [values],
    },
    axis: {
      rotated: param['rotated'],
      x: {type: 'category'},
      y: {
        max: param['max'],
        min: param['min'],
      },
    },
  });
};

/*
createFavoriteArtistsPieChart - お気に入り歌手ベスト10の構成を円グラフで表示する
targetSelecter: 描画対象要素のセレクタ
*/
zenra.createFavoriteArtistsPieChart = function(targetSelecter) {
  zenra.post('/ajax/user/artist/favorite' , {} , {
    success: function(json) {
      response = zenra.parseJSON(json);
      if (response.result == 'success') {
        zenra.createPieChart(targetSelecter , response.info);
      }
    },
  });
};

/*
createMonthlySangCountBarChart - 対象楽曲の月ごとの歌われた回数を棒グラフで表示する
song: songID
targetSelecter: 描画対象要素のセレクタ
*/
zenra.createMonthlySangCountBarChart = function(song , targetSelecter) {
  zenra.post('/ajax/song/tally/monthly/count' , {song: song} , {
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
    },
  });
};

/*
createAggregatedScoreBarChart - 対象楽曲の得点集計を棒グラフで表示する
song: songID
scoreType: score_type
targetSelecter: 描画対象のセレクタ
*/
zenra.createAggregatedScoreBarChart = function(song, scoreType, targetSelecter) {
  zenra.post('/ajax/song/tally/score' , {song: song, score_type: scoreType} , {
    success: function(json) {
      var response = zenra.parseJSON(json);
      if (response.result == 'success') {
        var data = response.info;
        console.log(data);
        var values = ['あなた' , 'みんな'];
        var g1 = ['あなた'];
        var g2 = ['みんな'];
        zenra.createBarChart(targetSelecter , data , 'name' , values , [g1 , g2] , {max: 100 , min: 60});
      }
    },
  });
};

/*
showDialog - ダイアログを表示する
title: ダイアログのタイトル
dialog_id: ダイアログエレメントに割り振るID
url: ダイアログの内容を取得するURL
id: URL内で取得する要素のID
opt: 拡張オプション
*/
zenra.showDialog = function(title , dialog_id , url , id , width , opt) {
  var opt = opt || {}
  var funcs = opt['funcs'] || {};
  var func_at_load = opt['func_at_load'] || function(){};

  var dialog = $('<div>').attr('id' , dialog_id);
  var scroll = $(window).scrollTop();
  dialog.dialog({
    title: title ,
    modal: true ,
    height: "auto" ,
    width: width ,
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
    var margin = div.height() / 2;
    $('.ui-dialog').css({'top': scroll + margin + 'px' , 'z-index': 9999});
    div.css('overflow' , 'hidden');
    $(window).scrollTop(scroll);

    func_at_load();
    $('#' + id).tooltip('disable');
  });

  //オプション: タイトルバーにオンマウス時のカーソル
  $('.ui-dialog-title').css('cursor' , opt['title_cursor'] || '');

  dialog.html(div);
};

/*
closeDialog - ダイアログを閉じる
*/
zenra.closeDialog = function(id) {
  var div = $('#' + id);
  div.dialog('close');
};

/*
transitionInDialog - ダイアログ内の画面を遷移する
*/
zenra.transitionInDialog = function(dialog_id , url , id , opt) {
  var opt = opt || {};
  var func_at_load = opt['func_at_load'] || function(){};

  var div = $('#' + dialog_id);

  jQuery.removeData(div);
  div.load(url + " #" + id , function(date , status) {
    func_at_load();
    $('#' + id).tooltip('disable');
  });
};

/*
dialogSetEvent - ダイアログにイベントを設定する
*/
zenra.dialogSetEvent = function(dialog_id , event_obj) {
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

  var div = $('#' + dialog_id);
  div.dialog(events);
};

/*
createThumbnail - youtubeのサムネイルを生成する
*/
zenra.createThumbnail = function(idx , id , song , artist , image) {
  if (image) {
    var $img = $('<img>').attr('src' , image);
    $img.css('width' , 160).css('height' , 90).css('cursor' , 'pointer');
    $img.attr('info' , song + ' (' + artist + ')');
    $img.click(function() {
      var opt = {title_cursor: 'pointer' , draggable: false};
      zenra.showDialog($img.attr('info') , 'player_dialog' , '/player/' + id , 'player' , 600 , opt);
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
  bathtowelオブジェクト -バスタオルの制御全般-
*/
var bathtowel = {

  /*[Method] バスタオルの初期設定*/
  init : function () {

    //楽曲情報表示用
    self.info = $('<div>').attr('id' , 'bathtowel_info').css('display' , 'none');
    self.info.appendTo('body');

    //オンマウス時に曲名を通知
    $('.bathtowel-li').each(function() {
      var text = $(this).children('img').attr('info');
      $(this).hover(
        function() { self.info.text(text).css('display' , ''); } ,
        function() { self.info.css('display' , 'none'); }
      );
    });

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
  var count = 0;
  var close_flg = false;
  var store_list = [];
  var branch_list = [];
  var song_obj = [];
  var song_list = [];
  var artist_list = [];

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
      count = 0;

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
    $('#url').val(history['url']);
    
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
    button3.attr('onclick' , 'zenra.closeDialog("input_dialog");').val('キャンセル');

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

    cancel_button.attr('onclick' , 'zenra.closeDialog("input_dialog");').val('キャンセル');
    var buttons = $('#buttons');
    buttons.append(action_button);
    buttons.append(cancel_button);
  }
  
  /*[method] 歌唱履歴編集画面用の要素を作成する*/
  function createElementForEditHistory(karaoke_id , history_id) {
    var label = $('<label></label>').attr('for' , 'score').html('URL:');
    var input = $('<input id="url" type="url" name="url" size="50" title="曲の動画を変更する場合はURLを変更してください。">');
    $('#url_area').html(label).append(input);
    
    $('#button1').attr('onclick' , 'register.submitHistoryEditRequest(' + karaoke_id + ' , ' + history_id + ');').val('保存');
    $('#button2').attr('onclick' , 'register.submitHistoryDeleteRequest(' + karaoke_id + ' , ' + history_id + ');').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'zenra.closeDialog("input_dialog");').val('キャンセル');
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
      url: $('#url').val()
    };

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
      zenra.showDialog('カラオケ入力' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_karaoke' , 600 , {
        funcs: {
          beforeClose: beforeClose
        } ,
        func_at_load: function() {
          createWidgetForKaraoke();
          $('#button1').attr('onclick' , 'register.submitKaraokeRegistrationRequest();').val('次へ');
        }
      });
    } ,

    /*[Method] 参加情報登録画面を表示する*/
    createAttendance : function(karaoke_id) {
      zenra.showDialog('参加情報登録' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_attendance' , 600 , {
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
      zenra.showDialog('歌唱履歴入力' , 'input_dialog' , '/ajax/history/dialog' , 'input_history' , 600 , {
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

    /*[Method] カラオケ編集画面を表示する*/
    editKaraoke : function(karaoke_id) {
      zenra.post('/ajax/karaokelist/' , {id: karaoke_id} , {
        success: function(result) {
          var karaoke = zenra.parseJSON(result);

          zenra.showDialog('カラオケ編集' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_karaoke' , 600 , {
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
      
          zenra.showDialog('参加情報編集' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_attendance' , 600 , {
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

          zenra.showDialog('歌った曲の編集' , 'input_dialog' , '/ajax/history/dialog' , 'input_history' , 600 , {
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
      
      if ($('#tweet-checkbox').prop('checked')) {
        data.twitter = 1;
      }
      
      zenra.post('/ajax/karaoke/create' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          
          if (response['result'] == 'success') {
            var karaoke_id = response['karaoke_id'];

            zenra.transitionInDialog('input_dialog' , '/ajax/history/dialog' , 'input_history' , {
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

    /*[Method] 歌唱履歴登録リクエストを送信する*/
    submitHistoryRegistrationRequest : function(action , karaoke_id) {
      var data = getHistoryData();
      data.karaoke_id = karaoke_id;

      if ($('#tweet-checkbox').prop('checked')) {
        data.twitter = 1;
      }

      // 参加情報の登録リクエストを送信する
      register.submintAttendanceRegistrationRequest(karaoke_id);
      
      zenra.post('/ajax/history/create' , data , {
        success: function(json_response) {
          var response = zenra.parseJSON(json_response);
          
          if (response['result'] == 'success') {
            count += 1;
            $('#result').html('<p>' + count + '件入力されました</p>');
            
            if (action == 'end') {
              count = 0;
              
              zenra.dialogSetEvent('input_dialog' , {
                beforeClose: function() { return true; } ,
              });
              zenra.closeDialog('input_dialog');
             
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
  }

})();
