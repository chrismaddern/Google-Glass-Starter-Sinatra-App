$(document).ready(function(){

	/* ---------------------------------------------------------------------- */
	/*  Set Min Height
	/* ---------------------------------------------------------------------- */

	$('#main').css('min-height',
		$(window).outerHeight(true)
		- ( $('body').outerHeight(true)
		- $('body').height() )
		- $('#header').outerHeight(true)
		- ( $('#main').outerHeight(true) - $('#main').height() )
		- $('#footer').outerHeight(true)
	);


	/* ---------------------------------------------------------------------- */
	/*  Page Notification
	/* ---------------------------------------------------------------------- */

	$('.close-button').click(function(){
		$('.page-notification').slideUp();
	});


	/* ---------------------------------------------------------------------- */
	/*  Main Navigation
	/* ---------------------------------------------------------------------- */

	$('.main-nav > ul').superfish({
		hoverClass: 'sfHover',
		animation: { opacity:'show', height:'show'},
		speed: 250,
		delay: 300,
		dropShadows: false
	});


	/* ---------------------------------------------------------------------- */
	/*  Responsive Navigation
	/* ---------------------------------------------------------------------- */

	$('.main-nav > ul').mobileMenu({
	    defaultText: 'Navigate to...',
	    className: 'responsive-nav',
	    subMenuDash: '&nbsp;&ndash;'
	});


	/* ---------------------------------------------------------------------- */
	/*  Recent Project Hover
	/* ---------------------------------------------------------------------- */

	$('.recent-projects').projectHover({
		color: '#ff674f',
		opacity: '0.6',
		borderWidth: '3px',
		count: 3,
		animationSpeed: 200
	});


	/* ---------------------------------------------------------------------- */
	/*  Lightbox
	/* ---------------------------------------------------------------------- */

	$('a[rel^="lightbox"]').prettyPhoto({
		social_tools: false,
		overlay_gallery: false,
		show_title: false,
		deeplinking: false
	});


	/* ---------------------------------------------------------------------- */
	/*  FlexSlider
	/* ---------------------------------------------------------------------- */

	$('.flexslider').flexslider({
		controlNav: false,
		pauseOnHover: true,
		useCSS: true
	});


	/* ---------------------------------------------------------------------- */
	/*  Isotope
	/* ---------------------------------------------------------------------- */

	var $portfolioContainer = $('.portfolio-filter');

	$portfolioContainer.isotope({
		filter: '*',
		animationOptions: {
			duration: 750,
			easing: 'linear',
			queue: false,
		}
	});

	$('.portfolio-nav a').click(function(){
		var selector = $(this).attr('data-filter');
		$portfolioContainer.isotope({
			filter: selector,
			animationOptions: {
				duration: 750,
				easing: 'linear',
				queue: false,
			}
		});
	  return false;
	});

	var $optionSets = $('.portfolio-nav ul'),
	       $optionLinks = $optionSets.find('a');
	 
	       $optionLinks.click(function(){
	          var $this = $(this);
		  // don't proceed if already selected
		  if ( $this.hasClass('selected') ) {
		      return false;
		  }
	   var $optionSet = $this.parents('.portfolio-nav ul');
	   $optionSet.find('.selected').removeClass('selected');
	   $this.addClass('selected'); 
	});


	/* ---------------------------------------------------------------------- */
	/*  Audio Player
	/* ---------------------------------------------------------------------- */

	$('.audio-player audio').mediaelementplayer({
        alwaysShowControls: true,
        features: ['playpause','volume','progress'],
        audioVolume: 'horizontal',
        audioWidth: '100%',
        audioHeight: 40,
        iPhoneUseNativeControls: false
    });


    /* ---------------------------------------------------------------------- */
    /*  Accordion
    /* ---------------------------------------------------------------------- */

    var accordionUL = $('.accordion .inner'),
		accordionLink  = $('.accordion a');
     
    accordionUL.hide();

    accordionLink.click(function(e) {
        e.preventDefault();
        if(!$(this).hasClass('active')) {
            accordionLink.removeClass('active');
            accordionUL.filter(':visible').slideUp('normal');
            $(this).addClass('active').next().stop(true,true).slideDown('normal');
        } else {
            $(this).removeClass('active');
            $(this).next().stop(true,true).slideUp('normal');
        }
    });


	/* ---------------------------------------------------------------------- */
	/*  Twitter Widget
	/* ---------------------------------------------------------------------- */

	$('.twitter').tweet({
        username: twitterUserName,
        join_text: "auto",
        avatar_size: 32,
        count: twitterCount,
        auto_join_text_default: "", 
        auto_join_text_ed: "",
        auto_join_text_ing: "",
        auto_join_text_reply: "",
        auto_join_text_url: "",
        loading_text: "loading tweets..."
    });


    /* ---------------------------------------------------------------------- */
	/*  Flickr Plugin
	/* ---------------------------------------------------------------------- */

	$('#footer .flickr ul').jflickrfeed({
		limit: 10,
		qstrings: {
			id: flickrID
		},
		itemTemplate: 
			'<li>' +
				'<a href="{{image_b}}"><img src="{{image_s}}" alt="{{title}}" /></a>' +
			'</li>'
	});

	$('.widget_flickr .flickr ul').jflickrfeed({
		limit: 12,
		qstrings: {
			id: flickrID
		},
		itemTemplate: 
			'<li>' +
				'<a href="{{image_b}}"><img src="{{image_s}}" alt="{{title}}" /></a>' +
			'</li>'
	});


	/* ---------------------------------------------------------------------- */
	/*  Google Maps
	/* ---------------------------------------------------------------------- */

	var $map = $('#map');

	if( $map.length ) {

		$map.gMap({
			address: address,
			zoom: 16,
			markers: [
				{ 'address' : address }
			]
		});

	}


	/* ---------------------------------------------------------------------- */
	/*  Other
	/* ---------------------------------------------------------------------- */

	$('.comment-list .comment article, .testimonial .text').prepend('<span class="arrow"></div>');

	$().UItoTop({ easingType: 'easeOutQuart' });

	/* ---------------------------------------------------------------------- */
	/*  Contact Form
	/* ---------------------------------------------------------------------- */

	$("#contact-form").validate({
		errorPlacement: function(error, element) {
	        error.insertBefore(element);
	    }
	});

	setTimeout(function() {

	$("#contact-form").submit(function(event){
	
		event.preventDefault();
			
		if ( !$('#contact-form input, #contact-form textarea').hasClass('error') ) {
		
			$.post("./php/send.php", $("#contact-form").serialize());
			
			$('#contact-form .success').slideDown(500).delay(3000).fadeOut();
			
		}
		
		else {
		
			$('.contact-form .erroor').slideDown(250).delay(3000).fadeOut();
			
			return false;
			
		}

		$('input[type=text],textarea').val('');

	});

	},500);

});