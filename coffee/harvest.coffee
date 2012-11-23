onError = (e) -> console.log "Rejected", e

onSuccess = (localMediaStream) ->
  video.src = webkitURL.createObjectURL(localMediaStream)
  setInterval(update, 250) 

setupWS = (url, close) ->
  window.ws?.close()
  window.ws = new WebSocket("ws://#{location.host}/#{url}")
  window.ws.onopen = ->  console.log "Opened websocket #{url}"
  window.ws.onclose = close

update = => 
  ctx.drawImage(video, 0, 0, 320, 240)
  canvas.toBlob((blob)-> 
                  window.ws?.send(blob) 
                ,'image/jpeg')

# if distance is more then MAX_DISTANCE increment error counter
MAX_DISTANCE = 1000
ERROR_THRESHOLD = 10
video = document.querySelector('video')
canvas = document.querySelector('canvas')
ctx = canvas.getContext('2d')
ctx.strokeStyle = '#ff0'
ctx.lineWidth = 2

predict = () ->
  console.log('Started to predict')
  errorCounter = 0
  window.ws.onmessage = (e) =>
    data = JSON.parse(e.data)
    $('#predict').show()
    if data
      debugArea = $('.prettyprint')
      debugArea.text(JSON.stringify(data, undefined, 2))
      debugArea.append("\n\nError counter: #{errorCounter}")

      $('#name-of-face').text("Hello #{data.face.name}!")
      ctx.strokeRect(data.face.coords.x, data.face.coords.y, data.face.coords.width, data.face.coords.height) if showFace()
      if data.face.distance < MAX_DISTANCE and errorCounter > ERROR_THRESHOLD * -1
        errorCounter -= 1
      else
        errorCounter += 1
      if errorCounter > ERROR_THRESHOLD and not keepPredicting()
        console.log "About to close predict websocket"
        errorCounter = 0
        window.ws.close()

showFace = () ->
  $('#show-face').attr('checked')

keepPredicting = () ->
  $('#keep-predicting').attr('checked')

train = () ->
  console.log('Started training')
  $('#name').val("")
  $('#predict').hide()
  $('#train').show()
  $('#input').show()

  startHarvest = ->
    setupWS('harvesting', onTrainClose)
    window.ws.onmessage = (e) ->
      console.log "closing harvesting websocket"
      window.ws.close()
      updateProgressBar(70, 'Training model')

  saveLabel = (label) ->
    console.log "Saving " + label
    $('#input').hide()
    $('#training').show()
    updateProgressBar(40, 'Saving label')
    $.post('/', {label: label}).success(-> 
      updateProgressBar('50')
      startHarvest())

  $('#start').click((e)-> 
    e.preventDefault()
    label = $('#name').val()
    saveLabel(label) if label 
  )

updateProgressBar = (w, text = 'Saving images') ->
  $('.bar').css('width', "#{w}%")
  $('.bar').text(text)

onPredictClose = (e) ->
  console.log 'About to start training'
  $('#predict').hide()
  train()

onTrainClose = (e) ->
  $.post('/train').success(-> 
    console.log("done training")
    updateProgressBar(100)
    $('#training').hide()
    setupWS('predict', onPredictClose)
    predict()
  )

navigator.webkitGetUserMedia({'video': true, 'audio': false}, onSuccess, onError) 
setupWS('predict', onPredictClose)
predict()

#$('#stop').click((e)-> 
#  e.preventDefault()
#  window.ws.close()
#)

#$('#train').click((e)-> 
#  e.preventDefault()
#  $.post('/train').success(-> console.log("done training"))
#)
