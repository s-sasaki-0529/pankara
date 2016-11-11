/*
 * jQuery Mini Calendar
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2016, k.ishiwata
 * http://www.webopixel.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

 /*
  * 上記のjQueryプラグインを、パンダリンのカラオケランドに合わせて改造
  * JSON読み込みから、カレンダー生成時に各種パラメータを与えられるように変更し、
  * イベントに画像やリンクを含めるようにする
  */

;(function($) {
  $.wop = $.wop || {};
  $.wop.miniCalendar = function(targets,option){
    this.opts = $.extend({},$.wop.miniCalendar.defaults,option);
    this.ele = targets;

    // jsonファイルから読み込んだデータを入れる変数
    this.events = {};
    this.date = new Date();
    this.month = "";
    this.year = "";
    this.holiday = "";

    //表示する年月
    this.year = this.opts.year;
    this.month = this.opts.month;

    this.createFrame();
    this.printType(this.year, this.month);
    // 取得したイベントを表示
    this.events = this.opts.events;
    this.setEvent();
  };
  $.wop.miniCalendar.prototype = {

    /**
     * 枠を作成
     */
    createFrame : function() {
      var $header = $('<div>').addClass('calendar-head').css('text-align' , 'left');
      var $title = $('<p>').addClass('calendar-year-month').css('display' , 'inline-block');
      var $prevBtn = $('<button>').text('先月').addClass('mini-calendar-btn btn btn-default').css('float' , 'right');
      var $todayBtn = $('<button>').text('今月').addClass('mini-calendar-btn btn btn-default').css('float' , 'right');
      var $nextBtn = $('<button>').text('来月').addClass('mini-calendar-btn btn btn-default').css('float' , 'right');
      $header.append($nextBtn).append($todayBtn).append($prevBtn).append($title);
      this.ele.append($header);

      var outText = '<table><thead><tr>';
      for (var i = 0; i < this.opts.weekType.length; i++) {
        if (i === 0) {
          outText += '<th class="calendar-sun">';
        } else if (i === this.opts.weekType.length-1) {
          outText += '<th class="calendar-sat">';
        } else {
          outText += '<th>';  
        }
        outText += this.opts.weekType[i] +'</th>';
      }
      outText += '</thead><tbody></tbody></table>';
      this.ele.find('.calendar-head').after(outText);
    },

    /**
     * 日付・曜日の配置
     */
    printType : function(thisYear, thisMonth) {

      $(this.ele).find('.calendar-year-month').text(thisYear + '年' + thisMonth　+ '月');
      var thisDate = new Date(thisYear, thisMonth-1, 1);

      // 開始の曜日
      var startWeek = thisDate.getDay();

      var lastday = new Date(thisYear, thisMonth, 0).getDate();
      // 縦の数
      //var rowMax = Math.ceil((lastday + (startWeek+1)) / 7);
      var rowMax = Math.ceil((lastday + startWeek) / 7);

      var outText = '<tr>';
      var countDate = 1;
      // 最初の空白を出力
      for (var i = 0; i < startWeek; i++) {
        outText += '<td class="calendar-none">&nbsp;</td>';
      }
      for (var row = 0; row < rowMax; row++) {
        // 最初の行は曜日の最初から
        if (row == 0) {
          for (var col = startWeek; col < 7; col++) {
            outText += printTD(countDate, col);
            countDate++;
          }
        } else {
          // 2行目から
          outText += '<tr>';
          for (var col = 0; col < 7; col++) {
            if (lastday >= countDate) {
              outText += printTD(countDate, col);
            } else {
              outText += '<td class="calendar-none">&nbsp;</td>';
            }
            countDate++;
          }
        }
        outText += '</tr>';
      }
      $(this.ele).find('tbody').html(outText);

      function printTD(count, col) {
        var dayText = "";
        var tmpId = ' id="calender-id'+ count + '"';
        // 曜日classを割り当てる
        if (col === 0) tmpId += ' class="calendar-sun"';
        if (col === 6) tmpId += ' class="calendar-sat"';
        return '<td' + tmpId + '><i class="calendar-day-number">' + count + '</i>'+dayText+'</td>';
      }

      //今日の日付をマーク
      var toDay = new Date();
      if (thisYear === toDay.getFullYear()) {
        if (thisMonth === (toDay.getMonth()+1)) {
          var dateID = 'calender-id' + toDay.getDate();
          $(this.ele).find('#' + dateID).addClass('calendar-today');
        }
      }
    },
    /**
     * イベントの表示
     */
    setEvent : function() {
      for(var i = 0; i < this.events.length; i++) {
        var dateID = 'calender-id' + this.events[i].day;
        var labelClass = "calendar-label";
        if (this.events[i].type) {
          labelClass += '-' + this.events[i].type;
        }
        var calendarLabel = $('<span>').addClass(labelClass);
        if (this.events[i].link) {
          (function(url) {
            calendarLabel.addClass('pointer').click(function() {
              location.href = url;
            });
          })(this.events[i].link);
        }

        $(this.ele).find('#' + dateID).append(calendarLabel);
        this.events[i].images.forEach(function(i) {
          calendarLabel.append($('<img src="' + i + '">').prop('width' , '32'));
        });
      }
    },
  };

  $.wop.miniCalendar.defaults = {
    weekType : ["日", "月", "火", "水", "木", "金", "土"],
    year : new Date().getFullYear(),
    month : new Date().getMonth()+1,
  };
  $.fn.miniCalendar = function(option){
    option = option || {};
    var api = new $.wop.miniCalendar(this,option);
    return option.api ? api : this;
  };
})(jQuery);
