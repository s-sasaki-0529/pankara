/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
resetHistory - 歌唱履歴入力欄をリセットする
*/
zenra.resetHistory = function() {
	$('#song').val('');
	$('#artist').val('');
	$('#score').val('');
};

/*
postHistory - 歌唱履歴情報を送信する
*/
zenra.postHistory = function(button) {
	$.ajax({
		type: "POST",
		url: '/history/input',
		async: false,
		data: {
			song: $('#song').val(),
			artist: $('#artist').val(),
			score: $('#score').val(),
			songkey: $('#seekbar').slider('value'),
			score_type: $('#score_type').val(),
		},
	});

	zenra.resetHistory();

	if (button == 'regist') {
		location.href = '/history/regist';
	}
};

/*
postHistory - カラオケ情報を送信する
*/
zenra.postKaraoke = function() {
	$.ajax({
		type: "POST",
		url: '/karaoke/input',
		async: false,
		data: {
			name: $('#name').val(),
			datetime: $('#datetime').val(),
			plan: $('#plan').val(),
			store: $('#store').val(),
			branch: $('#branch').val(),
			product: $('#product').val(),
		},
	});
	
	zenra.transitionInDialog('/_local/dialog' , 'input_history');
};

/*
showDialog - ダイアログを表示する
*/
zenra.showDialog = function(title, url , id , width) {
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
		});
		init_ui();
	});
};

/*
transitionInDialog - ダイアログ内の画面を遷移する
*/
zenra.transitionInDialog = function(url , id) {
	var div = $('#dialog');

	jQuery.removeData(div);
	div.load(url + " #" + id , function(date , status) {
		init_ui();		
	});
};
