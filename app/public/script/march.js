/*起動時に自動実行*/
(function($){
		/*youtube垂れ流し開始*/
		$('#slider').simplyScroll({
			autoMode: 'loop',
			speed: 1,
			frameRate: 24,
			horizontal: true,
			pauseOnHover:	false,
			pauseOnTouch: false
		});

		$(function() {
			$( "#dialog" ).dialog({
				modal: true,
				buttons: {
					"OK": function(){
						$(this).dialog('close');
					}
				}
			});
		});
})(jQuery);

zenra = {};

/*
helloWorld - サンプルメソッド
*/
zenra.helloWorld = function(name) {
	alert('Hello ,' + name);
};
