/*呼び出して使用するメソッドを定義*/
zenra = {};

/*
helloWorld - サンプルメソッド
*/
zenra.helloWorld = function(name) {
	alert('Hello ,' + name);
};

/*
showDialog - ダイアログを表示する
*/
zenra.showDialog = function() {
	$( "#dialog" ).dialog({
		modal: true,
		height: "auto",
		width: 480,
	});
};

/*
ajaxShowDialog - ダイアログを表示する(ajax版)
*/
zenra.ajaxShowDialog = function(id) {
	var div = $('<div>').attr('id' , 'dialog');
	div.load("/_local/dialog" + " #" + id , function(date , status) {
		div.dialog({
			modal: true ,
			height: "auto" ,
			width: 480 ,
		});
	});
};
