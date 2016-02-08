/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
resetHistory - 歌唱履歴入力欄をリセットする
*/
zenra.resetHistory = function() {
	$('#song').val("");
	$('#artist').val("");
	$('#score').val("");
};

/*
postHistory - 歌唱履歴情報を送信（現在は画面のリセットのみ）
*/
zenra.postHistory = function() {
	zenra.resetHistory();
};

/*
showDialog - ダイアログを表示する
*/
zenra.showDialog = function(id) {
	var div = $('<div>').attr('id' , 'dialog');
	div.load("/_local/dialog" + " #" + id , function(date , status) {
		div.dialog({
			modal: true ,
			height: "auto" ,
			width: 480 ,
		});
		init_ui();
	});
};
