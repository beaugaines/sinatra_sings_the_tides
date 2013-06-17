# $('#rollup').click ->
#   body = this.closest('div.buy_links').find('div.content')
#   if(body.is(:hidden))
#     body.show()
#   else
#     body.hide()

# geolocate fcn
$ ->
  getLocation = ->
    if Modernizr.geolocation
      timeoutVal = 10 * 1000 * 1000
      navigator.geolocation.getCurrentPosition
        showPosition,
        displayError
        { enableHighAccuracy: true, timeout: timeoutVal,
          maximumAge: 0 }
    else
      alert("Geolocation not supported on your browser")
  showPosition = (position) ->
    $('#search').text("Lat:" + position.coords.latitude + "<br>Long:" + position.coords.longitude)
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

   

getLocation = ->
if navigator.geolocation
  navigator.geolocation.getCurrentPosition showPosition
else
  x.innerHTML = "Geolocation is not supported by this browser."
showPosition = (position) ->
x.innerHTML = "Latitude: " + position.coords.latitude + "<br>Longitude: " + position.coords.longitude
x = document.getElementById("demo")