/*呼び出して使用するメソッドを定義*/
zenra = {};

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

