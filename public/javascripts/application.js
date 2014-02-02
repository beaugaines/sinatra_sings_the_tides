(function() {
  var pulsate;

  $(function() {
    return $("").submit(function(e) {
      e.preventDefault();
      return $.ajax({
        type: "POST",
        url: "/",
        data: $('form#search_form').serialize(),
        success: function() {
          $('#search_form').hide();
          $('#results').show();
          return $('#results').html('Next high tide at ' + this.tide_1);
        },
        error: function() {
          return $('#results').html('No results for that location');
        }
      });
    });
  });

  $(function() {
    return $('#contact').click(function(e) {
      var top;

      top = $('#contact-form').offset().top;
      $('#contact-form').show();
      return $('html, body').animate({
        scrollTop: '1100px'
      }, 2000, 'easeOutExpo');
    });
  });

  pulsate = function() {
    return $("#thanks").animate({
      opacity: 0.2
    }, 1000, "linear").animate({
      opacity: 1
    }, 1000, "linear", pulsate);
  };

  $(function() {
    return $("#formsend").submit(function() {
      $.post($(this).attr('action'), $(this).serialize(), (function() {}, $('#contact-form').hide(), $('#thanks').fadeIn(800)), 'text');
      return false;
    });
  });

  $(function() {
    return $('callout a').click(function(e) {
      var $anchor;

      $anchor = $(this);
      $('html, body').stop().animate({
        scrollTop: $($anchor.attr('href')).offset().top
      }, 2000, 'easeOutExpo');
      return e.preventDefault();
    });
  });

  $(function() {
    var displayError, getLocation, showPosition;

    getLocation = function() {
      var timeoutVal;

      if (Modernizr.geolocation) {
        timeoutVal = 10 * 1000 * 1000;
        navigator.geolocation.getCurrentPosition;
        showPosition;
        displayError;
        return {
          enableHighAccuracy: true,
          timeout: timeoutVal,
          maximumAge: 0
        };
      } else {
        return alert("Geolocation not supported on your browser");
      }
    };
    showPosition = function(position) {
      return $('#geoloc').text("Lat:" + position.coords.latitude + "<br>Long:" + position.coords.longitude);
    };
    return displayError = function(error) {
      var errors;

      errors = {
        1: 'Permission denied',
        2: 'Position unavailable',
        3: 'Requrest timeout'
      };
      return alert('Error: ' + errors[error.code]);
    };
  });

}).call(this);
