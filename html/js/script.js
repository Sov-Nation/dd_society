window.addEventListener('message', function(event) {
	let item = event.data;

	if (item.response == 'openTarget') {
		$('div').hide();
		$('.eye').hide();
		$('.eye-slash').show();

	} else if (item.response == 'closeTarget') {
		$('div').hide();
		$('i').hide();

	} else if (item.response == 'validTarget') {
		$('[actions]').html("");
		$('.radius').show();
		$('.eye').show();
		$('.eye-slash').hide();
		$('.actions-container').show();
		$.each(item.actions, function (index, action) {
			$("[actions]").append("<a class='action "+action.icon+"'></a>");
		});

	} else if (item.response == 'leftTarget') {
		$('div').hide();
		$('.eye').hide();
		$('.eye-slash').show();
	}
});
