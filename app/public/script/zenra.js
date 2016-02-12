/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
post - 情報を非同期で送信する
*/
zenra.post = function(url , data , funcs) {
	funcs = funcs || {};
	$.ajax({
		type: "POST" ,
		url: url ,
		data: data ,
		beforeSend: funcs.beforeSend ,
		complete: funcs.complete ,
	});
};

/*
showDialog - ダイアログを表示する
*/
zenra.showDialog = function(title, url , id , width , funcs) {
	funcs = funcs || {};
	var div = $('<div>').attr('id' , 'dialog');
	div.load(url + " #" + id , function(date , status) {
		div.dialog({
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
	});
};

/*
transitionInDialog - ダイアログ内の画面を遷移する
*/
zenra.transitionInDialog = function(url , id) {
	var div = $('#dialog');

	jQuery.removeData(div);
	div.load(url + " #" + id , function(date , status) {
		zenra.createSeekbar();
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
			$("#slidervalue").html('キー: ' + $('#seekbar').slider('value'));
		} ,
		change: function() {
			$('#slidervalue').html('キー: ' + $('#seekbar').slider('value'));
		} ,
	});
}

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
	registerクラス -カラオケ入力制御全般-
*/
var register = (function() {
	var count = 0;

	/*[Method] 歌唱履歴入力欄をリセットする*/
	function resetHistory() {
		$('#song').val('');
		$('#artist').val('');
		$('#score').val('');
		$('input[name=song]').focus();
	}

	return {
		/*[Method] 履歴入力用ダイアログを作成する*/
		createDialog : function() {
			funcs = {}
			funcs.beforeClose = function() {
				count = 0;
				return true;
			};

			zenra.showDialog('カラオケ入力' , '/_local/dialog' , 'input_karaoke' , 600 , funcs);
		} ,

		/*[Method] カラオケ情報入力終了後の処理*/
		execInputKaraoke : function() {
			data = {
				name: $('#name').val() ,
				datetime: $('#datetime').val() ,
				plan: $('#plan').val() ,
				store: $('#store').val() ,
				branch: $('#branch').val() ,
				product: $('#product').val() ,
			};
	
			zenra.post('/karaoke/input' , data);
			zenra.transitionInDialog('/_local/dialog' , 'input_history');
		} ,
	
		/*[Method] 歌唱履歴情報入力終了後の処理*/
		execInputHistory : function(button) {
			count += 1;

			data = {
				song: $('#song').val() ,
				artist: $('#artist').val() ,
				score: $('#score').val() ,
				songkey: $('#seekbar').slider('value') ,
				score_type: $('#score_type').val() ,
			};
	
			funcs = {};
			if (button == 'regist') {
				funcs.beforeSend = function() {
					zenra.transitionInDialog('/_local/dialog' , 'loading');
				};
				funcs.complete = function() {
					location.href = '/history/regist';
				};
			}
			else {
				funcs.complete = function() {
					$('#result').html('<p>' + count + '件入力されました</p>')
				};
			}
	
			zenra.post('/history/input' , data , funcs);
			resetHistory();
		} ,
	}
	
})();
