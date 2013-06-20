// Generated by CoffeeScript 1.6.2
(function() {
  $(function() {
    return $("#search_form").submit(function(e) {
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

  $(function() {
    $('#content').hide();
    $('#rollup').show();
    return $('#rollup').click(function() {
      return $('#content').slideToggle();
    });
  });

}).call(this);
