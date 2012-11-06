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

opencvCoord2CanvasCoord = (openCvPoints) ->
  return [openCvPoints[0], openCvPoints[1], openCvPoints[2] - openCvPoints[0], openCvPoints[3] - openCvPoints[1]]

ws = new WebSocket("ws://#{location.host}/harvesting")
ws.onopen = ->  console.log "Opened websocket"
ws.onmessage = (e) ->
  openCvCoords = JSON.parse(e.data)[0]
  canvasCoords = opencvCoord2CanvasCoord(openCvCoords)
  ctx.strokeRect(canvasCoords[0], canvasCoords[1], canvasCoords[2], canvasCoords[3])

saveLabel = (label) ->
  console.log "saving " + label
  $.post('/harvest', {label: label}).success(-> startHarvest())

startHarvest = ->
  $('form').hide()
  navigator.webkitGetUserMedia({'video': true, 'audio': false}, onSuccess, onError) 

$('button').click((e)-> 
  e.preventDefault()
  label = $('#name').val()
  console.log(label)
  saveLabel(label) if label 
)
