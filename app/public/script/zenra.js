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
  beforeSend = opt['beforeSend'] || function(){};
  success = opt['success'] || function(){};
  error = opt['error'] || function(){};
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
_ajaxsample - JSONを用いたAjax通信のサンプル
*/
zenra._ajaxsample = function() {
  this.post('/local/rpc/storelist' , {} , {
    success: function(result) {
      storeList = zenra.parseJSON(result);
      console.log(storeList);
    }
  });
};

/*
get - 非同期で通信する
*/
zenra.get = function(url , funcs) {
  funcs = funcs || {};
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
showDialog - ダイアログを表示する
*/
zenra.showDialog = function(title , dialog_id , url , id , width , opt) {
  opt = opt || {}
  funcs = opt['funcs'] || {};
  func_at_load = opt['func_at_load'] || function(){};

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
  opt = opt || {};
  func_at_load = opt['func_at_load'] || function(){};

  var div = $('#' + dialog_id);

  jQuery.removeData(div);
  div.load(url + " #" + id , function(date , status) {
    func_at_load();
  });
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
bathtowel = {

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
  registerオブジェクト -カラオケ入力制御全般-
*/
var register = (function() {
  var count = 0;
  var close_flg = false;
  var karaoke_id = 0;
  var history_id = 0;
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
      history_id = 0;
      karaoke_id = 0;

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

  /*[method] カラオケ入力画面用ウィジェットを作成する*/
  function createWidgetForKaraoke() {
    // お店のもしかしてリスト作成
    zenra.post('/local/rpc/storelist' , {} , {
      success: function(result) {
        branch_list = zenra.parseJSON(result);

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
    zenra.post('/local/rpc/songlist' , {} , {
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

    // 曲名を入力すると歌手名が自動入力される
    $('#song').blur(function() {
      if ($(this).val() in song_obj) {
        $('#artist').val(song_obj[$(this).val()]);
      }
    });

    $('#artist').focus(function() {
      var temp_artist_list = [];

      // 現在の曲名をキーとして持つ値をリスト化する
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
    });
    
    $('#score_type').change(function() {
      if ($('#score_type').val() == 0) {
        $('#score_area').hide();
      }
      else {
        $('#score_area').show();
      }
    });
  }

  /*[method] カラオケ編集画面用の要素を作成する*/
  function createElementForEditKaraoke() {
    $('#button1').attr('onclick' , 'register.onPushedEditKaraokeButton();').val('保存');
    var button2 = $('<input>').attr('id' , 'button2').attr('type' , 'button');
    button2.attr('onclick' , 'register.onPushedDeleteKaraokeButton();').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'zenra.closeDialog("input_dialog");').val('キャンセル');

    $('#buttons').append(button2);
    $('#buttons').append(button3);
  }
  
  /*[method] 歌唱履歴編集画面用の要素を作成する*/
  function createElementForEditHistory() {
    var label = $('<label></label>').attr('for' , 'score').html('URL:');
    var input = $('<input>').attr('id' , 'url').attr('type' , 'url').attr('name' , 'url').attr('size' , '50');
    $('#url_area').html(label).append(input);
    
    $('#button1').attr('onclick' , 'register.onPushedEditHistoryButton();').val('保存');
    $('#button2').attr('onclick' , 'register.onPushedDeleteHistoryButton();').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'zenra.closeDialog("input_dialog");').val('キャンセル');
    $('#buttons').append(button3);
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
          $('#button1').attr('onclick' , 'register.onPushedRegisterKaraokeButton();').val('次へ');
        }
      });
    } ,

    /*[Method] 歌唱履歴入力画面を表示する*/
    createHistory : function(karaoke) {
      karaoke_id = karaoke;

      // 既にカラオケに参加済みか確認する
      zenra.post('/ajax/attended' , {karaoke_id: karaoke_id} , {
        success: function(result) {
          var attended = zenra.parseJSON(result);
         
          if (attended['attended']) {
            zenra.showDialog('歌唱履歴入力' , 'input_dialog' , '/ajax/history/dialog' , 'input_history' , 600 , {
              func_at_load: function() {
                createWidgetForHistory();

                $('#button1').attr('onclick' , 'register.onPushedRegisterHistoryButton("register");').val('登録');
                $('#button2').attr('onclick' , 'register.onPushedRegisterHistoryButton("end");').val('終了');
              } ,
              funcs: {
                beforeClose: beforeClose
              }
            });
          }
          // まだ参加していない場合出席情報を入力する
          else {
            zenra.showDialog('出席情報入力' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_attendance' , 600 , {
              funcs: {
                beforeClose: beforeClose
              }
            });
          }
        }
      });
    } ,

    /*[Method] カラオケ編集画面を表示する*/
    editKaraoke : function(karaoke) {
      karaoke_id = karaoke;
      zenra.post('/local/rpc/karaokelist/' , {id: karaoke_id} , {
        success: function(result) {
          var karaoke = zenra.parseJSON(result);

          zenra.showDialog('カラオケ編集' , 'input_dialog' , '/ajax/karaoke/dialog' , 'input_karaoke' , 600 , {
            func_at_load: function() {
              createWidgetForKaraoke();
              setKaraokeToInput(karaoke);
              createElementForEditKaraoke();
            } ,
            funcs: {
              beforeClose: beforeClose
            }
          });
        }
      });
    } ,

    /*[Method] 歌唱履歴編集画面を表示する*/
    editHistory : function(karaoke , history) {
      karaoke_id = karaoke;
      history_id = history;

      zenra.post('/local/rpc/historylist/' , {id: history_id} , {
        success: function(result) {
          var history = zenra.parseJSON(result);

          zenra.showDialog('歌った曲の編集' , 'input_dialog' , '/ajax/history/dialog' , 'input_history' , 600 , {
            func_at_load: function() {
              createWidgetForHistory();
              createElementForEditHistory();
              setHistoryToInput(history);
            } ,
            funcs: {
              beforeClose: beforeClose
            }
          });
        }
      });
    } ,

    /*[Method] カラオケ登録ボタン押下時の処理*/
    onPushedRegisterKaraokeButton : function() {
      var data = {
        name: $('#name').val() ,
        datetime: $('#datetime').val() ,
        plan: $('#plan').val() ,
        store: $('#store').val() ,
        branch: $('#branch').val() ,
        product: $('#product').val() ,
        price: $('#price').val() ,
        memo: $('#memo').val()
      };

      zenra.post('/ajax/karaoke/create' , data , {
        success: function(result) {
          result_obj = zenra.parseJSON(result);
          karaoke_id = result_obj['karaoke_id'];

          zenra.transitionInDialog('input_dialog' , '/ajax/history/dialog' , 'input_history' , {
            func_at_load: function() {
              createWidgetForHistory();

              $('#button1').attr('onclick' , 'register.onPushedRegisterHistoryButton("register");').val('登録');
              $('#button2').attr('onclick' , 'register.onPushedRegisterHistoryButton("end");').val('終了');
            }
          });
        }
      });
    } ,

    /*[Method] 出席情報入力終了後の処理*/
    onPushedRegisterAttendanceButton : function() {
      var data = {
        karaoke_id: karaoke_id ,
        price: $('#price').val() ,
        memo: $('#memo').val()
      };

      zenra.post('/ajax/attendance/create' , data , {});
      zenra.transitionInDialog('input_dialog' , '/ajax/history/dialog' , 'input_history' , {
        func_at_load: function() {
          createWidgetForHistory();

          $('#button1').attr('onclick' , 'register.onPushedRegisterHistoryButton("register");').val('登録');
          $('#button2').attr('onclick' , 'register.onPushedRegisterHistoryButton("end");').val('終了');
        }
      });
    } ,

    /*[Method] 歌唱履歴情報入力終了後の処理*/
    onPushedRegisterHistoryButton : function(action) {
      var data = {
        karaoke_id: karaoke_id ,
        song: $('#song').val() ,
        artist: $('#artist').val() ,
        songkey: $('#seekbar').slider('value') ,
        score: $('#score').val() ,
        score_type: $('#score_type').val() ,
      };

      if (action == 'register') {
        zenra.post('/ajax/history/create' , data , {
          success: function(result) {
            count += 1;
            $('#result').html('<p>' + count + '件入力されました</p>')
          }
        });

        resetHistory();
      }
      else if (action == 'end') {
        if (count > 0) {
          location.href = ('/karaoke/detail/' + karaoke_id);
        }

        zenra.closeDialog('input_dialog');
      }
    } ,

    /*[Method] カラオケ編集ボタン押下時の処理*/
    onPushedEditKaraokeButton : function() {
      var json_data = zenra.toJSON({
        name: $('#name').val() ,
        datetime: $('#datetime').val() ,
        plan: $('#plan').val() ,
        store_name: $('#store').val() ,
        store_branch: $('#branch').val() ,
        product: $('#product').val()
      });

      zenra.post('/local/rpc/karaoke/modify/' , {id: karaoke_id , params: json_data} , {
        success: function(json_result) {
          result = zenra.parseJSON(json_result);
          if (result['result'] == 'success') {
            location.href = ('/karaoke/detail/' + karaoke_id);
          }
        }
      });
    } ,

    /*[Method] 歌唱履歴編集ボタン押下時の処理*/
    onPushedEditHistoryButton : function() {
      var json_data = zenra.toJSON({
        song_name: $('#song').val() ,
        artist_name: $('#artist').val() ,
        songkey: $('#seekbar').slider('value') ,
        score: $('#score').val() ,
        score_type: $('#score_type').val() ,
        url: $('#url').val()
      });

      zenra.post('/local/rpc/history/modify/', {id: history_id, params: json_data} , {
        success: function() {
          location.href = ('/karaoke/detail/' + karaoke_id);
        }
      });
    } ,

    /*[Method] カラオケ削除ボタン押下時の処理*/
    onPushedDeleteKaraokeButton : function() {
      zenra.post(('/local/rpc/karaoke/delete/') , {id: karaoke_id} , {
        success: function(result) {
          location.href = '/'
        }
      });
    } ,

    /*[Method] 歌唱履歴削除ボタン押下時の処理*/
    onPushedDeleteHistoryButton : function() {
      zenra.post('/local/rpc/history/delete/' , {id: history_id} , {
        success: function(result) {
          location.href = ('/karaoke/detail/' + karaoke_id);
        }
      });
    } ,
  }

})();
