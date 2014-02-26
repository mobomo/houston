$(function(){
	$(".docs").click(function(e) {
		$(this).toggleClass("active");
		$(".wrapper").toggleClass("active");
		$(".extrabig").fitText(0.6, { minFontSize: '36px', maxFontSize: '96px' });
	    return false;
	});

	$(".extrabig").fitText(0.6, { minFontSize: '36px', maxFontSize: '96px' });
})
