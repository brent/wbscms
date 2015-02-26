$(document).ready(function(){
	
	var colorSpeed = 6000;
		
		var colorize = function() {
			var randomHue = Math.floor(Math.random() * 359),
				randomLightness = (Math.floor(Math.random() * 3) + 10) / 100;
			
			$('body').animate({
				backgroundColor: $.Color({hue: randomHue, saturation: '.5', lightness: randomLightness})
			}, colorSpeed);
		};
		
		colorize();
		
		var interval = setInterval(function(){
			colorize();
	}, colorSpeed);

});
