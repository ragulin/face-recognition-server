onError = (e) -> console.log "Rejected", e

onSuccess = (localMediaStream) ->
  video.src = webkitURL.createObjectURL(localMediaStream)
  setInterval(update, 250) 

update = -> 
  ctx.drawImage(video, 0, 0, 320, 240)
  canvas.toBlob((blob)-> 
                  ws.send(blob)
                ,'image/jpeg')

video = document.querySelector('video')
canvas = document.querySelector('canvas')
ctx = canvas.getContext('2d')
ctx.strokeStyle = '#ff0'
ctx.lineWidth = 2

ws = new WebSocket("ws://#{location.host}/predict")
ws.onopen = ->  console.log "Opened websocket"
ws.onmessage = (e) ->
  console.log e.data

saveLabel = (label) ->
  console.log "saving " + label
  $.post('/harvest', {label: label}).success(-> startHarvest())

startHarvest = ->
  navigator.webkitGetUserMedia({'video': true, 'audio': false}, onSuccess, onError) 

$('#start').click((e)-> 
  e.preventDefault()
  label = $('#name').val()
  console.log(label)
  saveLabel(label) if label 
)

$('#stop').click((e)-> 
  e.preventDefault()
  ws.close()
)

$('#train').click((e)-> 
  e.preventDefault()
  $.post('/train').success(-> console.log("done training"))
)
