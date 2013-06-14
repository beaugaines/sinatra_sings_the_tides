# $('#rollup').click ->
#   body = this.closest('div.buy_links').find('div.content')
#   if(body.is(:hidden))
#     body.show()
#   else
#     body.hide()

$(document).ready ->
  $('#content').hide()
  $('#rollup').show()
  $('#rollup').click ->
    $('#content').slideToggle()
