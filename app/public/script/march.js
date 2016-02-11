/*起動時に自動実行*/
function init_ui() {
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
