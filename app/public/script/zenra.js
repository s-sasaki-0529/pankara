/*全てのページで読み込み時に実行*/
$(function(){
  //テーブルをソート可能に
  $('.sortable').tablesorter();
  $('input[type=submit],button[type=submit]').click(function () { zenra.getLoader().show(); });
  $("a").click(function() {
    if ($(this).attr('href')[0] != '#') {
      zenra.getLoader().show();
    }
  });
  zenra.getLoader().hide();
});

/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
nop - 空の関数
*/
zenra.nop = function() {};

/*
post - 情報を非同期で送信する
*/
zenra.post = function(url , data , opt) {
  var success = opt.success || zenra.nop;
  var complete = opt.complete || zenra.nop;
  var error = opt.error || function (error) {
    console.log(error);
  };
  var nwError = opt.nwError || function (error) { 
    console.log(error);
  };
  var sync = opt.sync === true ? true : false;
  if (sync) {
    zenra.getLoader().show();
  }
  data.authenticity_token = $('#authenticity_token').val();
  $.ajax({
    type: "POST" ,
    url: url ,
    data: data ,
    success: function (json) {
      var response = zenra.parseJSON(json);
      if (response.result == 'success') {
        success(response.info);
      } else {
        error(response.info);
      }
    },
    error: nwError ,
    complete: function () {
      complete();
      zenra.getLoader().hide();
    }
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
};

/*
confirm - PC版ではjConfirm,スマフォ版ではconfirmを呼び出す
ただし、jConfirmは非同期になってしまうので使い方に注意が必要
*/
zenra.confirm = function (message , callback) {
  if (zenra.ispc) {
    jConfirm(message , "確認" , function(r) {
      if (r) {
        callback();
      }
    });
  } else {
    if (confirm(message)) {
      callback();
    }
  }
};

/*
prompt - PC版ではjPrompt,スマフォ版ではpromptを呼び出す
ただし、jPromptは非同期になってしまうので使い方に注意が必要
*/
zenra.prompt = function (message , initValue , title , callback) {
  if (zenra.ispc) {
    jPrompt(message , initValue , title , function(r) {
      callback(r);
    });
  } else {
    var r = prompt(message , initValue);
    callback(r);
  }
};

/*
loader - 読み込み中画面を生成
zenra.getLoader().show() - 画面を表示
zenra.getLoader().hide() - 画面を非表示
*/
zenra.getLoader = function () {
  return (function () {
    var $screen = $('<div>').prop('id' , 'loading-view');
    var imageWidth = zenra.ispc ? 128 : 64;
    var imageHeight = zenra.ispc ? 128 : 64;
    var imageLeft = (window.innerWidth / 2) - (imageWidth / 2);
    var imageTop = (window.innerHeight / 2) - (imageHeight / 2);
    var $image = $('<img src="/image/loading_image.png" alt="loading">')
      .addClass('rotate-image')
      .css('position' , 'fixed')
      .css('left' , imageLeft + 'px')
      .css('top' , imageTop + 'px')
      .css('width' , imageWidth + 'px')
      .css('height' , imageHeight + 'px');
    $screen.append($image).hide();
    $('body').append($screen);
    return {
      show: function () {
        $('#loading-view').show();
      } ,
      hide: function () {
        $('#loading-view').hide();
      }
    };
  })();
};

/*
visit - 指定したURLに移動
移動前にローディングビューを描画する
*/
zenra.visit = function (url) {
  zenra.getLoader().show();
  location.href = url;
};

/*
createPieChart - 円グラフを生成する
targetSelecter: 描画対象要素のセレクタ
dataSelecter: 対象データのJSONを持つ要素のセレクタ
opt: 拡張オプション
*/
zenra.createPieChart = function(targetSelecter , data, opt) {
  opt = opt || {};
  c3.generate({
    // グラグを表示するセレクタ
    bindto: targetSelecter,
    // グラフに表示するデータ
    data: {
      columns: data,
      type: 'pie',
      order: null,
    },
    // 項目クリックで関連ページに移動(オプション)
    legend: {
      item: opt.links ? {
        onclick: function (id) {
          if (! opt.links) {
            return;
          } else if (opt.links[id]) {
            zenra.visit(opt.links[id]);
          }
        }
      } : {}
    }
  });
};

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
      rotated: param.rotated,
      x: {type: 'category'},
      y: {
        max: param.max,
        min: param.min,
      },
    },
    color: {
      pattern: param.color,
    },
  });
};

/*
createFavoriteArtistsPieChart - お気に入り歌手ベスト10の構成を円グラフで表示する
targetSelecter: 描画対象要素のセレクタ
*/
zenra.createFavoriteArtistsPieChart = function(targetSelecter , user) {
  zenra.post('/ajax/user/artist/favorite' , {'user': user} , {
    success: function(data) {
        var links = {};
        data.forEach(function(o) {
          var artist = o[0];
          links[artist] = '/artist?name=' + encodeURIComponent(artist);
        });
        zenra.createPieChart(targetSelecter , data , {links: links});
        $(targetSelecter + '_json').text(zenra.toJSON(data));
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
    success: function(data) {
      var users = [];
      data.forEach(function(e) { users = users.concat(Object.keys(e)); });
      users = users.filter(function (x, i, self) { return self.indexOf(x) === i && x != '_month';});
      zenra.createBarChart(targetSelecter , data , '_month' , users , [users] , {rotated: true});
      $(targetSelecter + '_json').text(zenra.toJSON(data));
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
      success: function(data) {
        var scoreTypeName = data.score_type_name;
        var scores = data.scores;
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
        $(targetSelecter + '_json').text(zenra.toJSON(data));
      },
      error: function(score_type_name) {
        $('#score_type_name').text(score_type_name);
        $(targetSelecter).html('<p id="no_scores" class="center">採点情報がありません</p>');
        $(targetSelecter + '_json').text('no scores');
      } ,
      complete: function() {
        isBusy = false;
      }
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
    if (currentScoreType === 0) {
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
  var defaultWidth = zenra.ispc ? 160 : 80;
  var defaultHeight = zenra.ispc ? 90 : 45;
  var width = _width || defaultWidth;
  var height = _height || defaultHeight;
  if (image != "未登録") {
    var $img = $('<img>').attr('src' , image);
    var song = $('#song_name_' + idx).text();
    var artist = $('#artist_name_' + idx).text();
    $img.css('width' , width).css('height' , height).css('cursor' , 'pointer');
    $img.attr('id' , 'thumbnails_' + idx).attr('info' , song + ' (' + artist + ')');

    // iPhoneでのclickイベントについて
    // http://blog.webcreativepark.net/2012/12/25-134858.html
    $img.on('click' , function(){});
    $("body").on("click" , '#thumbnails_' + idx , function() {
      var opt = {title_cursor: 'pointer' , draggable: false}; 
      var player_dialog = new dialog($img.attr('info') , 'player_dialog' , 600);
      player_dialog.show('/song/' + id + '/player' , 'player' , opt);
      $('.ui-dialog-title').unbind('click').click(function() {
        zenra.visit('/song/' + id);
      });
    });
    $('#thumbnail_' + idx).append($img);
  } else {
    var $altText = $("<div>").text('未登録').css('width' , width).css('height' , height).css('line-height' , height + 'px');
    $('#thumbnail_' + idx).append($altText);
  }
};

/*
createSeekbar - シークバーを作成する
*/
zenra.createSeekbar = function() {
  var $seekBar = $('#seekbar');
  $seekBar.slider({
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
  $('.slider-btn').click(function() {
    var currentValue = $seekBar.slider('value');
    var newValue = currentValue + Number($(this).data('value'));
    $seekBar.slider('value' , newValue);
  });
};

/*
createNameGuideLines - 曲名/歌手名の入力指針画面を生成
*/
zenra.createNameGuideLines = function () {

  // 表示中のポップを保持するためのクロージャ
  var $currentElement = $('');
  (function() {
    // 入力画面を非表示にし、ガイド画面を表示する
    $('#song').autocomplete("close");
    $('#artist').autocomplete("close");
    $('#main_content').addClass('hidden');
    $('#guideline').removeClass('hidden');
    $('.popover-guideline').popover('hide');
    $('.popover-guideline').attr('title' , '<p class="center">例</p>').popover({
      trigger: 'manual',
      html: true,
    });
    // 要素ごとににポップするメッセージを定義
    $('#guide1').attr('data-content' ,"<p>⭕ メリッサ</p><p>❌ メリッサ 〜ガイドボーカル入り〜</p><p>❌ メリッサ 〜アニメ映像入り〜</p>");
    $('#guide2').attr('data-content' ,"<p>⭕ さよならのかわりに花束を</p><p>❌ さよならのかわりに、花束を arranged version</p>");
    $('#guide3').attr('data-content' ,"<p>⭕ ryo</p><p>❌ ryo feat.初音ミク</p><p>❌ 初音ミク</p>");
    $('#guide4').attr('data-content' ,"<p>⭕ 涼宮ハルヒ</p><p>❌ 平野綾</p><p>❌ 涼宮ハルヒ(CV. 平野綾)</p>");
    $('#guide5').attr('data-content' ,"<p>⭕ JAM Project</p><p>❌ JAM Project featuring 影山ヒロノブ</p>");
    $('#guide6').attr('data-content' ,"<p>⭕ 涼宮ハルヒ、朝比奈みくる、長門有希</p><p>❌ 涼宮ハルヒ / 朝比奈みくる / 長門有希</p><p>❌ 平野綾、ゴットゥーザ様、茅原実里</p>");
    $('#guide7').attr('data-content' ,"<p>⭕ ST☆RISH</p><p>❌ 一十木音也、聖川真斗、四ノ宮那月...</p><p>❌ 寺島拓篤、聖川真斗、四ノ宮那月...</p>");
    $('#guide8').attr('data-content' ,"<p>⭕ 中島みゆき / 宙船</p><p>❌ TOKIO / 宙船</p>");
    // 各要素クリック時に、メッセージをポップする
    $('.popover-guideline').click(function (evt) {
      // 既に表示中の場合閉じる
      if ($(this).prop('id') == $currentElement.prop('id')) {
        $(this).popover('hide');
        $currentElement = $('');
      }
      // メッセージの表示
      else {
        $currentElement.popover('hide');
        $currentElement = $(this);
        $currentElement.popover('show');
      }
    });
    // 「戻る」ボタンクリック時に、ガイトを非表示に、元の画面を表示する
    $('#close_guide_btn').unbind().click(function () {
      $currentElement.popover('hide');
      $currentElement = $('');
      $('#main_content').removeClass('hidden');
      $('#guideline').addClass('hidden');
    });
    // スマフォの場合画面をスクロール
    if (! zenra.ispc) {
      zenra.scrollToTop();
    }
  })();
};

/*
  moshikashiteオブジェクト -もしかしてリスト制御用オブジェクト-
  id: InputエレメントのID
  source: もしかしてリストのソース用配列
*/
var moshikashite = function(arg_id , arg_source) {
  var id = arg_id;
  var source = arg_source;
  var minLength = 2;
  
  $('#' + id).autocomplete({
    source: source ,
    minLength: minLength
  });

  $('#' + id)
    .keyup(function() {
      if ($(this).val().length == 1) {
        var extractedSource = extractSoruce($(this).val());

        $(this).autocomplete('option' , 'source' , extractedSource);
        $(this).autocomplete('option' , 'minLength' , 1);
      }
      else {
        if ($(this).autocomplete('option' , 'minLength') == 1) {
          $(this).autocomplete('option' , 'source' , source);
          $(this).autocomplete('option' , 'minLength' , minLength);
        }
      }
    })
    .focus(function() {
      //! keydownを発火させて、もしかしてリストを自動で表示する
      $('#' + id).trigger(
        $.Event( 'keydown' , { keyCode: 65 , which: 65 })
      );
    });

  /*
  setOption - もしかしてリストのオプションを設定する
  opt: オプションの種類
  value: オプションの設定値 
  */
  this.setOption = function(opt , value) {
    $('#' + id).autocomplete(
      'option' ,
      opt ,
      value
    );
  };

  /*
  setSource - もしかしてリストのソースを設定する
  source: もしかしてリストのソース用配列
  */
  this.setSource = function(arg_source) {
    source = arg_source;
    
    $('#' + id).autocomplete(
      'option' ,
      'source' ,
      source
    );
  };

  /*
  setStandardMoshikashite - もしかしてリストを標準設定にする　必要ならSourceも設定する
  arg_source: もしかしてリストのソース用配列
  */
  this.setStandardMoshikashite = function(arg_source) {
    if (arg_source)
      this.setSource(arg_source);
   
    minLength = 2;
    this.setOption('minLength' , minLength);
  };
  
  /*
  setNoNeedInputMoshikashite - 文字の入力がなくてももしかしてリストを表示できるように設定する　必要ならSourceも設定する
  source: もしかしてリストのソース用配列
  */
  this.setNoNeedInputMoshikashite = function(arg_source) {
    if (arg_source)
      this.setSource(arg_source);
    
    minLength = 0;
    this.setOption('minLength' , minLength);
  };
  
  function extractSoruce(input_value) {
    var extractedSource = [];
    
    for (var i = 0; i < source.length; i++) {
      if (source[i].charAt(0) == input_value.toLowerCase() || 
          source[i].charAt(0) == input_value.toUpperCase()) {
        extractedSource.push(source[i]);
      }
    }

    return extractedSource;
  }
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
      zenra.getLoader().show();
      opt = opt || {};
      var funcs = opt.funcs || {};
      var func_at_load = opt.func_at_load || function(){};
      var position = opt.position || 'center';
      var dialog = $('<div>').attr('id' , this.dialog_id);
      var scroll = $(window).scrollTop();
      dialog.dialog({
        title: this.title ,
        modal: true ,
        height: this.height ,
        width: this.width ,
        resizable: opt.resizable || false ,
        draggable: opt.draggable === false ? false : true ,
        close: function(event) {
          $(this).dialog('destroy');
          $(event.target).remove();
        } ,
        beforeClose: funcs.beforeClose ,
      });
      console.log(position);
      var div = $('<div></div>');
      div.load(url + " #" + id , function(date , status) {
        if (! zenra.ispc) {
          $('ui-dialog').addClass('hidden');
          zenra.scrollToTop();
          $('.ui-dialog').css({'top' : 0 , 'z-index': 9999});
          $('ui-dialog').removeClass('hidden');
        }
        else if (position == 'center') {
          var margin = div.height() / 2;
          $('.ui-dialog').css({'top': scroll + margin + 'px' , 'z-index': 9999});
          div.css('overflow' , 'hidden');
          $(window).scrollTop(scroll);
        } else if (position == 'head') {
          $('.ui-dialog').css({'top' : 70 , 'z-index': 9999});
          zenra.scrollToTop();
        } else {
          $('.ui-dialog').css('top' , position);
          zenra.scrollToTop();
        }
        func_at_load();
        $('#' + id).tooltip('disable');
        zenra.getLoader().hide();
      });
    
      //オプション: タイトルバーにオンマウス時のカーソル
      $('.ui-dialog-title').css('cursor' , opt.title_cursor || '');
    
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
      opt = opt || {};
      var func_at_load = opt.func_at_load || function(){};
    
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
    var result = [];
  
    var all_cookies = document.cookie;
    if (all_cookies === '') {
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
    if (all_cookies === '') {
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
  var store_list = [];
  var branch_list = [];
  var song_obj = [];
  var song_list = [];
  var artist_list = [];
  var input_dialog;
  var song_moshikashite;
  var artist_moshikashite;
  var store_moshikashite;
  var branch_moshikashite;

  /*[Method] 歌唱履歴入力欄をリセットする*/
  function resetHistory() {
    $('#song').val('');
    $('#artist').val('');
    $('#seekbar').slider('value' , 0);
    $('#score').val('');
    $('#tweet-checkbox').prop('checked' , false);
    $('#tweet_text_area').addClass('hidden');
    song_moshikashite.setStandardMoshikashite(song_list);
    artist_moshikashite.setStandardMoshikashite(artist_list);
  }

  /*[Method] ダイアログを閉じる時に実施する処理*/
  function beforeClose() {
    if (window.confirm('終了してもよろしいですか')) {
      //count = 0;

      return true;
    }
    
    return false;
  }

  /*[method] カラオケ入力欄にカラオケ情報をセットする*/
  function setKaraokeToInput(karaoke) {
    $('#name').val(karaoke.name);
    $('#datetime').val(karaoke.datetime);
    $('#plan').val(karaoke.plan);
    $('#store').val(karaoke.store_name);
    $('#branch').val(karaoke.branch_name);
    $('#product').val(karaoke.product);
  }

  /*[method] 歌唱履歴入力欄に歌唱履歴情報をセットする*/
  function setHistoryToInput(history) {
    $('#song').val(history.song_name);
    $('#artist').val(history.artist_name);
    $('#seekbar').slider('value' , history.songkey);
    $('#score_type').val(history.score_type);
    $('#score').val(history.score);
    
    if (history.score_type > 0) {
      $('#score_area').show();
    }
  }

  /*[method] 参加入力欄に情報をセットする*/
  function setAttendanceToInput(attendance) {
    $('#price').val(attendance.price);
    $('#memo').val(attendance.memo);
  }
  
  /*[method] カラオケ入力画面用ウィジェットを作成する*/
  function createWidgetForKaraoke() {
    
    // お店のもしかしてリスト作成
    zenra.post('/ajax/store/list' , {} , {
      success: function(response) {
        // オブジェクトのキーをお店リストとして取得
        branch_list = response;
        store_list = [];
        for (var key in branch_list) {
          if (branch_list.hasOwnProperty(key)) {
            store_list.push(key);
          }
        }
        store_moshikashite = new moshikashite('store' , store_list);
      }
    });

    // お店を入力すると店舗のもしかしてリストが作成される
    $('#store').blur(function() {
      if ($(this).val() in branch_list) {
        branch_moshikashite = new moshikashite('branch' , branch_list[$(this).val()]);
        branch_moshikashite.setNoNeedInputMoshikashite();
      }
    });

    //日付時刻入力用のカレンダーを生成
    if (zenra.runMode != 'ci') {
      $.datetimepicker.setLocale('ja');
      $('#datetime').datetimepicker({
        lang: 'ja' ,
        step: 30 ,
        timepickerScrollbar: false,
        scrollMonth: false,
        scrollTime: false,
        scrollInput: false,
        format: 'Y-m-d H:i',
        validateOnBlur: true,
        onGenerate: function(ct) {
          console.log('hoge');
          $('.xdsoft_disabled').removeClass('xdsoft_disabled');
        },
      });
    }

    //ツイートするチェックボックスのイベントを定義
    $('#tweet-checkbox').change(function() {
      if ($(this).prop('checked')) {
        $('#tweet_text_area').removeClass('hidden');
      } else {
        $('#tweet_text_area').addClass('hidden');
      }
    });

    //ツイート内容が書き換わったとき、残り文字数を更新
    $('#tweet_textbox').keyup(function() {
      var usernameSize = zenra.currentUser.screenname.length;
      var urlSize = 'http://tk2-255-37407.vs.sakura.ne.jp/karaoke/detail/'.length;
      var textSize = "さんがカラオケに行きました".length + $(this).val().length;
      var currentSize = usernameSize + urlSize + textSize + 1 + 3;
      var len = 140 - currentSize;
      $('#tweet_text_count').text(len);
      if (len < 0) {
        $('#tweet_text_count').addClass('red');
        $('#button1').prop('disabled' , true);
      } else {
        $('#tweet_text_count').removeClass('red');
        $('#button1').prop('disabled' , false);
      }
    });
    $('#tweet_text_count').text('');
  }

  /*[method] 歌唱履歴入力画面用ウィジェットを作成する*/
  function createWidgetForHistory(defaultValue) {
    zenra.createSeekbar();

    // 曲名と歌手名の対応表を取得
    zenra.post('/ajax/song/list/names' , {} , {
      success: function(response) {
        // オブジェクトを曲名リストと歌手名リストに分割
        song_obj = response;
        song_list = [];
        artist_list = [];
        
        for (var id in song_obj) {
          if (song_obj.hasOwnProperty(id)) {
            if (song_list.indexOf(song_obj[id].song) < 0) {
              song_list.push(song_obj[id].song);
            }
            
            if (artist_list.indexOf(song_obj[id].artist) < 0) {
              artist_list.push(song_obj[id].artist);
            }
          }
        
        }
        song_moshikashite = new moshikashite('song' , song_list);
        artist_moshikashite = new moshikashite('artist' , artist_list);
      }
    });

    createInputSongEvent();
    createInputArtistEvent();

    $('#score_type').change(function() {
      console.log('tori');
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

    //ツイート内容が書き換わったとき、残り文字数を更新
    $('.tweet-text').keyup(function() {
      var url = 'http://tk2-255-37407.vs.sakura.ne.jp/karaoke/detail/';
      var song = $('#song').val();
      var artist = $('#artist').val();
      var text = $('#tweet_textbox').val();
      var len = 140 - ((song + '(' + artist + ')' + 'を歌いました ' +  url + text).length + 3 + 1);
      $('#tweet_text_count').text(len);
      if (len < 0) {
        $('#tweet_text_count').addClass('red');
        $('#button1').prop('disabled' , true);
        $('#button2').prop('disabled' , true);
      } else {
        $('#tweet_text_count').removeClass('red');
        $('#button1').prop('disabled' , false);
        $('#button2').prop('disabled' , false);
      }
    });
    $('#tweet_text_count').text('');

    // デフォルト値の設定
    if (defaultValue) {
      $('#song').val(defaultValue.song);
      $('#artist').val(defaultValue.artist);
      autoInputSongKey();
    }
  }

  /*[method] 曲名入力に関するイベントを作成する*/
  function createInputSongEvent() {
    $('#song').blur(function() {
      var temp_artist_list = [];
      
      // 曲名を入力すると歌手名を自動入力する
      if ($('#artist').val() === '') {
        for (var id in song_obj) {
          if (song_obj.hasOwnProperty(id)) {
            if ($('#song').val() === song_obj[id].song) {
              temp_artist_list.push(song_obj[id].artist);
            }
          }
        }
        
        if (temp_artist_list.length === 1) {
          $('#artist').val(temp_artist_list[0]);
        }
      }

      autoInputSongKey();
    });

    $('#artist').focus(function() {
      var temp_artist_list = [];

      // 入力された曲を歌っている歌手名でもしかしてリストを生成
      for (var id in song_obj) {
        if (song_obj.hasOwnProperty(id)) {
          if ($('#song').val() === song_obj[id].song) {
            temp_artist_list.push(song_obj[id].artist);
          }
        }
      }
      
      if (temp_artist_list.length > 0) {
        artist_moshikashite.setNoNeedInputMoshikashite(temp_artist_list);
      }
      else {
        artist_moshikashite.setStandardMoshikashite(artist_list);
      }
    });
  }

  /*[method] 歌手名入力に関するイベントを作成する*/
  function createInputArtistEvent() {
    // 歌手名が入力されるとその歌手が歌っている曲でもしかしてリストを生成
    $('#artist').blur(function() {
      var temp_song_list = [];

      for (var id in song_obj) {
        if (song_obj.hasOwnProperty(id)) {
          if ($('#artist').val() === song_obj[id].artist) {
            temp_song_list.push(song_obj[id].song);
          }
        }
      }

      if (temp_song_list.length > 0) {
        song_moshikashite.setNoNeedInputMoshikashite(temp_song_list);
      }
      else {
        song_moshikashite.setStandardMoshikashite(song_list);
      }
      
      autoInputSongKey();
    });
  }

  /*[method] キーをajaxで取得して自動で入力する*/
  function autoInputSongKey() {
    // 曲名とアーティスト名が入力されたらキーを自動入力する
    if ($('#song').val() !== '' && $('#artist').val() !== '') {
      var song = {
        name: $('#song').val() ,
        artist: $('#artist').val()
      };

      zenra.post('/ajax/user/history/recent/key' , song , {
        success: function(songkey) {
          $('#seekbar').slider('value' , songkey);
        }
      });
    }
  }

  /*[method] カラオケ編集画面用の要素を作成する*/
  function createElementForEditKaraoke(karaoke_id) {
    $('#button1').attr('onclick' , 'register.submitKaraokeEditRequest(' + karaoke_id + ');').val('保存').addClass('form-control btn btn-default');
    var button2 = $('<input>').attr('id' , 'button2').attr('type' , 'button');
    button2.attr('onclick' , 'register.submitKaraokeDeleteRequest(' + karaoke_id + ');').val('削除').addClass('form-control btn btn-default');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'register.closeDialog();').val('キャンセル').addClass('form-control btn btn-default');

    $('#buttons').append(button2);
    $('#buttons').append(button3);
  }
  
  /*[method] 参加情報入力画面用の要素を作成する*/
  function createElementForEditAttendance(karaoke_id , action) {
    var action_button = $('<input>').attr('id' , 'action_button').attr('type' , 'button');
    var cancel_button = $('<input>').attr('id' , 'cancel_button').attr('type' , 'button');

    if (action == 'registration') {
      action_button.attr('onclick' , 'register.submintAttendanceRegistrationRequest(' + karaoke_id + ');')
      .val('次へ').addClass('form-control btn btn-default');
    }
    else {
      action_button.attr('onclick' , 'register.submintAttendanceEditRequest(' + karaoke_id + ');')
      .val('保存').addClass('form-control btn btn-default');
    }
    cancel_button.attr('onclick' , 'register.closeDialog();').val('キャンセル').addClass('btn btn-default');
    action_button.addClass('form-control');
    cancel_button.addClass('form-control');
    var buttons = $('#buttons');
    buttons.append(action_button);
    buttons.append(cancel_button);
  }
  
  /*[method] 歌唱履歴編集画面用の要素を作成する*/
  function createElementForEditHistory(karaoke_id , history_id) {
    $('#button1').attr('onclick' , 'register.submitHistoryEditRequest(' + karaoke_id + ' , ' + history_id + ');').val('保存');
    $('#button2').attr('onclick' , 'register.submitHistoryDeleteRequest(' + karaoke_id + ' , ' + history_id + ');').val('削除');
    var button3 = $('<input>').attr('id' , 'button3').attr('type' , 'button');
    button3.attr('onclick' , 'register.closeDialog();').val('キャンセル').addClass('form-control btn btn-default');
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
      if ($('#tweet_textbox').val() !== "") {
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
      if ($('#tweet_textbox').val() !== "") {
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
      $('#score_type').val(cookies.score_type);
      if (cookies.score_type != 0) {
        $('#score_area').show();
      }
    }
  }

  return {
    /*[Method] カラオケ入力画面を表示する*/
    createKaraoke : function() {
      input_dialog = new dialog('カラオケ新規作成' , 'input_dialog' , 450);

      input_dialog.show('/ajax/dialog/karaoke' , 'input_karaoke' , {
        funcs: {
          beforeClose: beforeClose
        } ,
        func_at_load: function() {
          var s = zenra.formatDate(new Date() , 'YYYY-MM-DD hh:mm');
          createWidgetForKaraoke();
          $('#button1').attr('onclick' , 'register.submitKaraokeRegistrationRequest();')
          .val('次へ').addClass('form-control btn btn-default');
          $('#datetime').val(s);
        } ,
        position: '50px',
      });
    } ,

    /*[Method] 参加情報登録画面を表示する*/
    createAttendance : function(karaoke_id) {
      input_dialog = new dialog('参加情報登録' , 'input_dialog' , 600);
      input_dialog.show('/ajax/dialog/karaoke' , 'input_attendance' , {
        funcs: {
          beforeClose: beforeClose
        } ,
        func_at_load: function() {
          createElementForEditAttendance(karaoke_id , 'registration');
        }
      });
    } ,
    
    /*[Method] 歌唱履歴入力画面を表示する*/
    createHistory : function(karaoke_id , opt) {
      opt = opt || {};
      input_dialog = new dialog('歌唱履歴追加' , 'input_dialog' , 450);
      input_dialog.show('/ajax/dialog/history' , 'input_history' , {
        func_at_load: function() {
          createWidgetForHistory(opt.defaultValue);
          setScoreTypeFromCookie();

          $('#button1').attr('onclick' , 'register.submitHistoryRegistrationRequest("continue" , ' + karaoke_id + ');').val('登録');
          $('#button2').val('終了').on('click' , function() {
            if (opt.callback && opt.callback == '#') {
              input_dialog.close();
            } else if (opt.callback) {
              zenra.visit(opt.callback);
            } else {
              zenra.visit("/karaoke/detail/" + karaoke_id);
            }
          });
          zenra.getLoader().hide();
        } ,
        funcs: {
          beforeClose: beforeClose
        } ,
      });
    } ,

    /*[Method] 楽曲新規登録画面を表示する*/
    createSong : function() {
      input_dialog = new dialog('楽曲登録' , 'input_dialog' , 450);
      input_dialog.show('/ajax/dialog/song' , 'input_song' , {
        funcs: {
          beforeClose: beforeClose
        },
        func_at_load: function() {
          createWidgetForHistory();
          $('#button1').attr('onclick' , 'register.submitCreateSongRequest()').val('登録');
          $('#button2').attr('onclick' , 'register.closeDialog()').val('キャンセル').addClass('from-control btn btn-default');
          $('#url_area').hide();
        }
      });
    },

    /*[Method] 楽曲編集画面を表示する*/
    editSong : function(song_id , youtube_id) {
      var song_name = $("#song_name").text();
      var artist_name = $("#artist_name").text();
      input_dialog = new dialog('楽曲編集' , 'input_dialog' , 450);
      input_dialog.show('/ajax/dialog/song' , 'input_song' , {
        func_at_load: function() {
          createWidgetForHistory();
          $('#button1').attr('onclick' , 'register.submitSongEditRequest(' + song_id + ')').val('登録');
          $('#button2').attr('onclick' , 'register.closeDialog()').val('キャンセル').addClass('form-control btn btn-default');
          $('#song').val(song_name);
          $('#artist').val(artist_name);
          $('#url').val('https://www.youtube.com/watch?v=' + youtube_id);
        }
      });
    },

    /*[Method] カラオケ編集画面を表示する*/
    editKaraoke : function(karaoke_id) {
      zenra.post('/ajax/karaoke/detail' , {id: karaoke_id} , {
        sync: true,
        success: function(karaoke) {
          input_dialog = new dialog('カラオケ編集' , 'input_dialog' , 450);
          input_dialog.show('/ajax/dialog/karaoke' , 'input_karaoke' , {
            func_at_load: function() {
              createWidgetForKaraoke();
              setKaraokeToInput(karaoke);
              createElementForEditKaraoke(karaoke.id);
            } ,
            funcs: {
              beforeClose: beforeClose
            } ,
            position: '60px',
          });
        }
      });
    } ,
    
    /*[Method] 参加情報編集画面を表示する*/
    editAttendance : function(karaoke_id) {
      zenra.post('/ajax/user/karaoke/attendance' , {id: karaoke_id} , {
        sync: true,
        success: function(attendance) {
          input_dialog = new dialog('参加情報編集' , 'input_dialog' , 600);
          input_dialog.show('/ajax/dialog/karaoke' , 'input_attendance' , {
            funcs: {
              beforeClose: beforeClose
            } ,
            func_at_load: function() {
              createElementForEditAttendance(karaoke_id , 'edit');

              setAttendanceToInput(attendance);
            },
            position: '80px',
          });
        }
      });
    } ,

    /*[Method] 歌唱履歴編集画面を表示する*/
    editHistory : function(karaoke_id , history_id) {
      zenra.getLoader().show();
      zenra.post('/ajax/history/detail' , {id: history_id} , {
        success: function(history) {
          input_dialog = new dialog('歌唱履歴編集' , 'input_dialog' , 470);
          input_dialog.show('/ajax/dialog/history' , 'input_history' , {
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
      zenra.getLoader().show();
      zenra.post('/ajax/karaoke/create' , data , {
        success: function(karaoke) {
          var karaoke_id = karaoke.karaoke_id;
          input_dialog.transition('/ajax/dialog/history' , 'input_history' , {
            func_at_load: function() {
              createWidgetForHistory();
              if (! zenra.ispc) {
                zenra.scrollToTop();
              }
              $('#button1').attr('onclick' , 'register.submitHistoryRegistrationRequest("continue" , ' + karaoke_id + ');').val('登録');
              $('#button2').on('click' , function() { zenra.visit("/karaoke/detail/" + karaoke_id); }).val('終了');
            } ,
          });
        } ,
        error: function(data) {
          alert(data);
        } ,
        nwError: function() {
          alert('カラオケの登録に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] カラオケ情報編集リクエストを送信する*/
    submitKaraokeEditRequest : function(karaoke_id) {
      var json_data = zenra.toJSON(getKaraokeData());

      zenra.getLoader().show();
      zenra.post('/ajax/karaoke/modify/' , {id: karaoke_id , params: json_data} , {
        success: function() {
          zenra.visit('/karaoke/detail/' + karaoke_id);
        } ,
        error: function(error) {
          alert(error);
        } ,
        nwError: function() {
          alert('カラオケの編集に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] 参加情報登録リクエストを送信する*/
    submintAttendanceRegistrationRequest : function(karaoke_id) {
      var data = {karaoke_id: karaoke_id};
      zenra.post('/ajax/attendance/create' , data , {sync: true , async: false});
    } ,

    /*[Method] 参加情報編集リクエストを送信する*/
    submintAttendanceEditRequest : function(karaoke_id) {
      var json_data = zenra.toJSON(getAttendanceData());
      
      zenra.post('/ajax/attendance/modify/', {id: karaoke_id, params: json_data} , {
        sync: true,
        success: function() {
          zenra.visit('/karaoke/detail/' + karaoke_id);
        } ,
        error: function(error) {
          alert(error);
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
        sync: true,
        success: function(json_response) {
          zenra.visit('/song/' + song_id);
        } ,
        error: function(error) {
          alert(error);
        } ,
        nwError: function() {
          alert('楽曲情報の編集に失敗しました。サーバにアクセスできません。');
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
        sync: true,
        success: function(sangInfo) {
          var mes = sangInfo.song + '(' + sangInfo.artist + ')' + 'を登録しました。</br>';
          mes += 'あなたがこの曲を歌うのは ' + sangInfo.sang_count + ' 回目です。';
          $('#result').html('<p>' + mes + '</p>');
          if (! zenra.ispc) {
            zenra.scrollToTop();
            $('#song').blur();
          }
        } ,
        error: function(error) {
          alert(error);
        } ,
        nwError: function() {
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
        sync: true,
        success: function(songID) {
          zenra.visit('/song/' + songID);
        } ,
        error: function(error) {
            alert(error);
        },
        nwError: function () {
          alert('楽曲の登録に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,
    /*[Method] 歌唱履歴編集リクエストを送信する*/
    submitHistoryEditRequest : function(karaoke_id , history_id) {
      var json_data = zenra.toJSON(getHistoryData());

      zenra.post('/ajax/history/modify/', {id: history_id, params: json_data} , {
        sync: true,
        success: function() {
          zenra.visit('/karaoke/detail/' + karaoke_id);
        } ,
        error: function(error) {
            alert(error);
        } ,
        nwError: function() {
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
        sync: true,
        success: function() {
            zenra.visit('/');
        } ,
        error: function() {
            alert('カラオケの削除に失敗しました。');
        } ,
        nwError: function() {
          alert('カラオケの削除に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,

    /*[Method] 歌唱履歴削除リクエストを送信する*/
    submitHistoryDeleteRequest : function(karaoke_id , history_id) {
      zenra.post('/ajax/history/delete/' , {id: history_id} , {
        sync: true,
        success: function() {
          zenra.visit('/karaoke/detail/' + karaoke_id);
        } ,
        error: function () {
          alert('歌唱履歴の削除に失敗しました。');
        } ,
        nwError: function() {
          alert('歌唱履歴の削除に失敗しました。サーバにアクセスできません。');
        }
      });
    } ,
    
    /*[Method] 入力ダイアログを閉じる*/
    closeDialog : function() {
      input_dialog.close();
    } ,
  };

})();

/* 楽曲詳細画面から、最近のカラオケに対して歌唱履歴を登録する */
zenra.addHistoryToRecentKaraoke = function(opt) {

  // パラメータに合わせて、DOMから対象の曲名/歌手名を取り出す
  opt = opt || {};
  var suffix = opt.idx ? ('_' + opt.idx) : '';
  var params = {
    defaultValue: {
      song: $('#song_name' + suffix).text(),
      artist: $('#artist_name' + suffix).text()
    } ,
    callback: '#'
  };

  // ユーザの最近のカラオケを取得し、それを対象に歌唱履歴登録ダイアログを開く
  zenra.post('/ajax/user/karaoke/recent' , {} , {
    success: function(karaoke) {
      var mes = 'カラオケ [' + karaoke.name + ']' + 'に、この曲の歌唱履歴を登録しますか？';
      if (confirm(mes)) {
        register.createHistory(karaoke.id , params);
      }
    } ,
    error: function(error) {
      alert(error);
    }
  });
};

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
    var link = '/search/tag?tag=' + tag.name;
    var $td1 = $('<td>').text(zenra.htmlescape(tag.name)).click(function () { zenra.visit(link); }).addClass('link');
    var $removeIcon;
    if (tag.created_by == user) {  //自身が登録したタグの場合のみ、削除アイコンを表示
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
    success: function(tags) {
      resetTagElements();
      tags.forEach(function(tag) { addTagElement(tag); });
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
  var url_from = '/ajax/song/' + id;
  var url_to = url_from + '/tag/add';
  zenra.prompt('追加するタグ名を入力してください。空白区切りで複数のタグを一度に登録できます', '', 'タグを新規登録', function(r) {
    var data = {tag_name: r};
    var opt = {success: function() {
      zenra.showSongTagList(id , user);
      $('html, body').animate({scrollTop: $(this).height()},'fast');
    }};
    zenra.post(url_to , data , opt);
  });
};

zenra.removeSongTag = function(user , id , tag) {
  var url_from = '/ajax/song/' + id;
  var url_to = url_from + '/tag/remove';
  var mes = 'タグ [' + tag.name + '] を削除します。よろしいですか？';
  zenra.confirm(mes,  function() {
    var data = {tag_name: tag.name , created_by: tag.created_by};
    var opt = {success: function() { zenra.showSongTagList(id , user); }};
    zenra.post(url_to , data , opt);
  });
};

/*お問い合わせメールを送信する*/
zenra.sendContactMail = function () {
  var params = {
    name: $('#name').val() ,
    title: $('#title').val() ,
    mail: $('#email').val() ,
    contact: $('#contact').val()
  };
  if (params.name == '' || params.mail == '' || params.title == '' || params.contact == '') {
    if (params.name == '') alert('お名前を入力してください');
    else if (params.mail == '') alert('メールアドレスを入力してください');
    else if (params.title == '') alert('題名を入力してください');
    else if (params.contact == '') alert('お問い合わせ内容を入力してください');
    return false;
  }
  zenra.post('/ajax/contact' , params , {
    sync: true,
    success: function () {
      zenra.visit("/contact");
    } ,
    nwError: function () {
      alert('お問い合わせメールの送信に失敗しました');
    }
  });
};

/*プレイリストオブジェクト*/
zenra.playlist = (function() {

  var element_id;
  var player_width;
  var player_height;
  var yt;
  var target;
  var list;
  var songs;

  /*[Event] プレイヤーのステータス変化を検知*/
  function onStateChange(e) {
    state = e.data;
    if (state === -1) {        //再生前
    } else if (state === 0) {  //再生終了
    } else if (state === 1) {  //再生中
      rewriteSongInfo();
    } else if (state === 2) {  //一時停止
    } else if (state === 3) {  //バッファ中
    } else if (state === 5) {  //ビデオがキューに入った
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
    if (zenra.ispc) {
      setTimeout(_play , 1000);  //タイムラグ
    }
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

/*カレンダー表示*/
zenra.calendar = (function() {

  var today = new Date();
  var year;
  var month;

  /*URLから表示する年月を取得*/
  function setCalendarParams () {
    year = Number(year || today.getFullYear());
    month = Number(month || today.getMonth() + 1);
  }

  /*翌月を設定*/
  function setNextMonth () {
    if (year == today.getFullYear() && month == today.getMonth() + 1) return false;
    month += 1;
    if (month > 12) {
      year += 1;
      month = 1;
    }
    return true;
  }

  /*前月を設定*/
  function setPrevMonth () {
    if (year == 2016 && month == 1) return false;
    month -= 1;
    if (month <= 0) {
      year -= 1;
      month = 12;
    }
    return true;
  }

  /*サーバから取得したカラオケ情報よりカレンダーイベントを作成*/
  function karaokeToCalendarEvents (karaoke) {
    var events = [];
    karaoke.forEach(function(k) {
      var icons = [];
      k.members.forEach(function(m) {
        icons.push(m.user_icon);
      });
      events.push({
        day: k.karaoke_day,
        images: icons,
        onclick: function() { zenra.visit('/karaoke/detail/' + k.karaoke_id); } ,
        type: k.color
      });
    });
    return events;
  }

  /*カレンダーを生成*/
  function create(events) {

    $('#mini-calendar').html('').miniCalendar({
      year: year ,
      month: month,
      events: events
    });
    $('.mini-calendar-btn').click(function() {
      var btnName = $(this).text();
      var changeMonthFlag = false;
      if (btnName == '先月') {
        changeMonthFlag = setPrevMonth();
      } else if (btnName == '来月') {
        changeMonthFlag = setNextMonth();
      } else {
        year = month = undefined;
        changeMonthFlag = true;
      }
      changeMonthFlag && init();
    });
  }

  function init () {
    setCalendarParams();
    zenra.post('/ajax/calendar' , {year: year , month: month} , {
      success: function (karaoke) {
        var events = karaokeToCalendarEvents(karaoke);
        create(events);
      }
    });
  }
  return init;
})();

/*スクロールを強制的に先頭へ移動する*/
zenra.scrollToTop = function () {
  if (zenra.ispc) {
    $(window).scrollTop(0);
  } else {
    $('html, body').animate({scrollTop:0},'fast');
  }
};

/*スクロールを強制的に一番下へ移動する*/
zenra.scrollToBottom = function () {
  $('html, body').animate({scrollTop: $(this).height()},'fast');
};

/*GETパラメータをキーを取得して取得*/
zenra.getParam = function (key) {
  var matched = location.search.match(new RegExp(key + '=(.*?)(&|$)'));
  if (matched) {
    return matched[1];
  } else {
    return false;
  }
};

zenra.htmlescape = function (string) {
  return string.replace(/[&'`"<>]/g, function(match) {
      return {
        '&': '&amp;',
        "'": '&#x27;',
        '`': '&#x60;',
        '"': '&quot;',
        '<': '&lt;',
        '>': '&gt;',
      }[match];
  });
};

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
};
