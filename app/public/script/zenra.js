/*全てのページで読み込み時に実行*/
$(function(){
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
};

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
    resizable: false ,
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

/*
  bathtowelオブジェクト -バスタオルの制御全般-
*/
bathtowel = {

  /*[Method] バスタオルの初期設定*/
  init : function () {
    $('#slider').simplyScroll({
      autoMode: 'loop',
      speed: 1,
      frameRate: 30,
      horizontal: true,
      pauseOnHover: false,
      pauseOnTouch: true
    });
    self.info = $('<div>').attr('id' , 'bathtowel_info').css('display' , 'none').text('hogehoge');
    self.info.appendTo('body');
  } ,

  /*[Method] 曲情報を通知する*/
  showInfo : function(message) {
    self.info.text(message).css('display' , '');
  } ,

  /*[Method] 曲情報を非表示にする*/
  hideInfo : function() {
    self.info.css('display' , 'none');
  } ,

};

/*
  registerオブジェクト -カラオケ入力制御全般-
*/
var register = (function() {
  var count = 0;
  var closeFlg = false;
  var karaoke_id;
  var store_list = [];
  var branch_list = [];

  /*[Method] 歌唱履歴入力欄をリセットする*/
  function resetHistory() {
    $('#song').val('');
    $('#artist').val('');
    $('#score').val('');
    $('input[name=song]').focus();
  }

  /*[Method] カラオケが正しく入力されているか確認する*/
  function validateKaraoke(data) {
    if (data['name'] == '') {
      return false;
    }

    return true;
  }

  /*[Method] 歌唱履歴が正しく入力されているか確認する*/
  function validateHistory(data) {
    if (data['song'] == '') {
      return false;
    }
    if (data['artist'] == '') {
      return false;
    }

    return true;
  }

  /*[method] 曲名と歌手のもしかしてリストの生成*/
  function createMoshikashite() {
    var list = [];
    
    zenra.post('/local/rpc/songlist' , {} , { 
      success: function(result) {
        list = zenra.parseJSON(result);
        zenra.moshikashite('song' , list);
        
        zenra.post('/local/rpc/artistlist' , {} , { 
          success: function(result) {
            list = zenra.parseJSON(result);
            zenra.moshikashite('artist' , list);
          }
        });
      }
    });
  }

  return {
    /*[Mothod] ここまでの入力内容を破棄しダイアログを閉じる*/
    reset : function() {
      count = 0;
      closeFlg = true;
      
      zenra.closeDialog('caution_dialog');
      zenra.closeDialog('input_dialog');
    } ,

    /*[Method] 履歴入力用ダイアログを作成する*/
    createDialog : function(id) {
      id = id || 0;
      
      zenra.post('/local/rpc/karaokelist?id=1' , {} , {
        success: function(result) {
          console.log(result);
        }  
      });
      
      closeFlg = false;
      var beforeClose = function() {  
        if (!closeFlg) {
          zenra.showDialog('注意' , 'caution_dialog' , '/history/input' , 'caution' , 200);
        }
        
        return closeFlg;
      };

      if (id > 0) {
        karaoke_id = id;
        zenra.showDialog('カラオケ入力' , 'input_dialog' , '/karaoke/input' , 'input_attendance' , 600 , {
          funcs: {
            beforeClose: beforeClose
          }
        });
      }
      else {
        zenra.showDialog('カラオケ入力' , 'input_dialog' , '/karaoke/input' , 'input_karaoke' , 600 , {
          funcs: {
            beforeClose: beforeClose
          } ,
          func_at_load: function() {
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
              zenra.moshikashite('branch' , branch_list[$(this).val()]);
            });

            //日付時刻入力用のカレンダーを生成
            $('#datetime').datetimepicker({
              lang: 'ja' ,
              step: 10 ,
            });

          }
        });
      }
    } ,

    /*[Method] カラオケ情報入力終了後の処理*/
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
 
      if (validateKaraoke(data) == false) {
        return;
      }
      
      zenra.post('/karaoke/input' , data , {
        success: function(result) {
          result_obj = zenra.parseJSON(result);
          karaoke_id = result_obj['karaoke_id'];
          
          zenra.transitionInDialog('input_dialog' , '/history/input' , 'input_history' , {
            func_at_load: function() {
              zenra.createSeekbar();
              createMoshikashite();
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
 
      zenra.post('/karaoke/input/attendance' , data , {});
      zenra.transitionInDialog('input_dialog' , '/history/input' , 'input_history' , {
        func_at_load: function() {
          createMoshikashite();
        }
      });
    } ,

    /*[Method] 歌唱履歴情報入力終了後の処理*/
    onPushedRegisterHistoryButton : function(button) {
      var data = {
        karaoke_id: karaoke_id ,
        song: $('#song').val() ,
        artist: $('#artist').val() ,
        songkey: $('#seekbar').slider('value') ,
        score: $('#score').val() ,
        score_type: $('#score_type').val() ,
      };

      if (validateHistory(data) == false) {
        return;
      }
  
      var funcs = {};
      if (button == 'register') {
        funcs['success'] = function() {
          location.href = ('/karaoke/detail/' + karaoke_id);
        };
      }
      else {
        funcs['success'] = function(result) {
          count += 1;
          $('#result').html('<p>' + count + '件入力されました</p>')
          createMoshikashite();
        };
      }
  
      zenra.post('/history/input' , data , funcs);
      resetHistory();
    } ,
  }
  
})();
