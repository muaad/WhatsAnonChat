/***************** Waypoints ******************/

$(document).ready(function() {

	// $('.wp1').waypoint(function() {
	// 	$('.wp1').addClass('animated fadeInLeft');
	// }, {
	// 	offset: '75%'
	// });
	// $('.wp2').waypoint(function() {
	// 	$('.wp2').addClass('animated fadeInUp');
	// }, {
	// 	offset: '75%'
	// });
	// $('.wp3').waypoint(function() {
	// 	$('.wp3').addClass('animated fadeInDown');
	// }, {
	// 	offset: '55%'
	// });
	// $('.wp4').waypoint(function() {
	// 	$('.wp4').addClass('animated fadeInDown');
	// }, {
	// 	offset: '75%'
	// });
	// $('.wp5').waypoint(function() {
	// 	$('.wp5').addClass('animated fadeInUp');
	// }, {
	// 	offset: '75%'
	// });
	// $('.wp6').waypoint(function() {
	// 	$('.wp6').addClass('animated fadeInDown');
	// }, {
	// 	offset: '75%'
	// });

	 $(".naver.animated").naver({
          animated: true, // CSS transition
          label: true , // Display text with mobile handle
          // labelClosed: "<a href="http:'//'www.jqueryscript.net/tags.php?/Navigation/">Navigation</a>", // Default 'closed' label
          labelOpen: "Close" // Default 'open' label
          });

});

/***************** Slide-In Nav ******************/

// $(window).load(function() {

// 	// $('.menu-open').click(function() {
// 	// 	$('.top-nav').slideToggle();
// 	// });

// });

/***************** Smooth Scrolling ******************/


$(function() {

	$('a[href*=#]:not([href=#])').click(function() {

		// Check height of the header
		var header_height = $('.naver').outerHeight();

		if (location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') && location.hostname === this.hostname) {

			var target = $(this.hash);
			target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
			if (target.length) {
				$('html,body').animate({
					// scrollTop(90) }, 2000);
					scrollTop: (target.offset().top) - header_height + 2  }, 2000);
				return false;
			}
		}
	});

});

/***************** Nav Transformicon ******************/

// document.querySelector("#nav-toggle").addEventListener("click", function() {
// 	this.classList.toggle("active");
// });

/***************** Overlays ******************/

// $(document).ready(function(){
//     // if (Modernizr.touch) {
//     //     // show the close overlay button
//     //     $(".close-overlay").removeClass("hidden");
//     //     // handle the adding of hover class when clicked
//     //     $(".img").click(function(e){
//     //         if (!$(this).hasClass("hover")) {
//     //             $(this).addClass("hover");
//     //         }
//     //     });
//     //     // handle the closing of the overlay
//     //     $(".close-overlay").click(function(e){
//     //         e.preventDefault();
//     //         e.stopPropagation();
//     //         if ($(this).closest(".img").hasClass("hover")) {
//     //             $(this).closest(".img").removeClass("hover");
//     //         }
//     //     });
//     // } else {
//     //     // handle the mouseenter functionality
//     //     $(".img").mouseenter(function(){
//     //         $(this).addClass("hover");
//     //     })
//     //     // handle the mouseleave functionality
//     //     .mouseleave(function(){
//     //         $(this).removeClass("hover");
//     //     });
//     // }
// });

// Close the mobile menu on clicking a link

$(".naver a").on("click", function (e) {
	$(".naver").naver("close");
});


/***************** Flexsliders ******************/

// $(window).load(function() {

	// $('#portfolioSlider').flexslider({
	// 	animation: "slide",
	// 	directionNav: false,
	// 	controlNav: true,
	// 	touch: false,
	// 	pauseOnHover: true
	// 	// start: function() {
	// 	// 	$.waypoints('refresh');
	// 	// }
	// });

// 	// $('#servicesSlider').flexslider({
// 	// 	animation: "slide",
// 	// 	directionNav: false,
// 	// 	controlNav: true,
// 	// 	touch: true,
// 	// 	pauseOnHover: true,
// 	// 	start: function() {
// 	// 		$.waypoints('refresh');
// 	// 	}
// 	// });

	// $('#teamSlider').flexslider({
	// 	animation: "slide",
	// 	directionNav: false,
	// 	controlNav: true,
	// 	touch: true,
	// 	pauseOnHover: true
	// 	// start: function() {
	// 	// 	$.waypoints('refresh');
	// 	// }
	// });

// });