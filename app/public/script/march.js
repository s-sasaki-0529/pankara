/*起動時に自動実行*/
function init_ui() {
		/*youtube垂れ流し開始*/
		$('#slider').simplyScroll({
			autoMode: 'loop',
			speed: 1,
			frameRate: 30,
			horizontal: true,
			pauseOnHover:	false,
			pauseOnTouch: false
		});

		/*シークバーの表示*/
		$(function() {
			$('#seekbar').slider({
				value: 0,
				max: 6,
				min: -6,
				step: 1,
				
				create: function(event, ui) {
					$("#slidervalue").html("キー: " + $(this).slider("value"));
				},
				change: function(event, ui) {
					$('#slidervalue').html("キー: " + ui.value);
				},
			});
		});
}

(function($){
	init_ui();
})(jQuery);
