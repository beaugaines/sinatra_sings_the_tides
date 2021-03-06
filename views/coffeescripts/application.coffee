

# ajax form submit


$ ->
  $("").submit (e) ->
    e.preventDefault()
    $.ajax
      type: "POST"
      url: "/"
      data: $('form#search_form').serialize()
      success: ->
        $('#search_form').hide()
        $('#results').show()
        $('#results').html('Next high tide at ' + @tide_1)
      error: ->
        $('#results').html('No results for that location')


# contact form reveal

$ ->
  $('#contact').click (e) ->
    top = $('#contact-form').offset().top
    $('#contact-form').show()
    $('html, body').animate({scrollTop: '900px'}, 2000, 'easeOutExpo')
    # $(window).scrollTop $("#contact-form").offset().top
  # $('#rollup').show()
  # $('#rollup').click ->
  #   $('#content').slideToggle()


# contact form submit

pulsate = ->
  $("#thanks").animate(
    opacity: 0.2
  , 1000, "linear").animate
    opacity: 1
  , 1000, "linear", pulsate

$ ->
  $("#formsend").submit ->
    $.post $(@).attr('action'), $(@).serialize(), (->
    #   $('fieldset').html '<h1>Thank you for getting in touch!</h1>'
    # ), 'text'
    # false
    $('#contact-form').hide()
    $('#thanks').fadeIn(800)
    ), 'text'
    # pulsate   // cant get this to work now, annoying
    false


# smooth scrollin ease in
$ ->
  $('callout a').click (e) ->
    $anchor = $(@)
    $('html, body').stop().animate({
      scrollTop: $($anchor.attr('href')).offset().top
    }, 2000, 'easeOutExpo')
    e.preventDefault()
    
# $ ->    
#   $('callout a').clickscrollTo('#post-5',{duration:'slow', offsetTop : '50'});


# geolocate fcn
$ ->
  getLocation = ->
    if Modernizr.geolocation
      timeoutVal = 10 * 1000 * 1000
      navigator.geolocation.getCurrentPosition
      showPosition
      displayError
      { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 }
    else
      alert("Geolocation not supported on your browser")
  showPosition = (position) ->
    $('#geoloc').text("Lat:" + position.coords.latitude + "<br>Long:" + position.coords.longitude)
  displayError = (error)->
    errors = {
      1: 'Permission denied',
      2: 'Position unavailable',
      3: 'Requrest timeout'
    }
    alert('Error: ' + errors[error.code])

    

   

