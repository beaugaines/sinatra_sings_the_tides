# $('#rollup').click ->
#   body = this.closest('div.buy_links').find('div.content')
#   if(body.is(:hidden))
#     body.show()
#   else
#     body.hide()

# ajax form submit


$ ->
  $("#search").submit (e) ->
    e.preventDefault()
    $.ajax
      type: "POST"
      url: "/"
      data: @serialize()
      success: ->
        $('#search').hide()
        $('#results').show()
        $('#results').html('Next high tide at ' + @tide_1)
      error: ->
        $('#results').html('No results for that location')



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

    

$ ->
  $('#content').hide()
  $('#rollup').show()
  $('#rollup').click ->
    $('#content').slideToggle()

   

