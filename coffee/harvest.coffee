onError = (e) -> console.log "Rejected", e

onSuccess = (localMediaStream) ->
  video.src = webkitURL.createObjectURL(localMediaStream)
  setInterval(update, 250) 

setupWS = (url) ->
  window.ws?.close()
  window.ws = new WebSocket("ws://#{location.host}/#{url}")
  window.ws.onopen = ->  console.log "Opened websocket #{url}"

update = => 
  ctx.drawImage(video, 0, 0, 320, 240)
  canvas.toBlob((blob)-> 
                  window.ws?.send(blob) 
                ,'image/jpeg')

video = document.querySelector('video')
canvas = document.querySelector('canvas')
ctx = canvas.getContext('2d')

predict = () ->
  console.log('Started to predict')
  counter = 0
  window.ws.onmessage = (e) =>
    data = JSON.parse(e.data)
    if data
      name = data[0]
      distance = data[1]
      if distance < 1000.0
        $('.prettyprint').text(data) 
      else
        counter += 1
      if counter > 10
        console.log counter
        counter = 0
        window.ws.close()
        console.log 'about to start trainin'
        train()

train = () ->
  console.log('started training')

  startHarvest = ->
    setupWS('harvesting')
    window.ws.onmessage = (e) ->
      console.log "closing training websocket"
      window.ws.close()
      $.post('/train').success(-> 
        console.log("done training")
        setupWS('predict')
        predict()
      )

  saveLabel = (label) ->
    console.log "saving " + label
    $.post('/harvest', {label: label}).success(-> startHarvest())

  $('#start').click((e)-> 
    e.preventDefault()
    label = $('#name').val()
    saveLabel(label) if label 
  )

navigator.webkitGetUserMedia({'video': true, 'audio': false}, onSuccess, onError) 
setupWS('predict')
predict()

$('#stop').click((e)-> 
  e.preventDefault()
  window.ws.close()
)

$('#train').click((e)-> 
  e.preventDefault()
  $.post('/train').success(-> console.log("done training"))
)
