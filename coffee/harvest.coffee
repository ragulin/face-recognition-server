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
ctx.strokeStyle = '#ff0'
ctx.lineWidth = 2

predict = () ->
  console.log('Started to predict')
  counter = 0
  window.ws.onmessage = (e) =>
    data = JSON.parse(e.data)
    console.log data.face.distance
    $('#predict').show()
    if data
      $('.prettyprint').text(JSON.stringify(data, undefined, 2))
      ctx.strokeRect(data.face.coords.x, data.face.coords.y, data.face.coords.width, data.face.coords.height) if showFace()
      if data.face.distance < 1000 
        counter -= 1
      else
        counter += 1
      if counter > 10
        console.log counter
        counter = 0
        window.ws.close()
        console.log 'About to start training'
        $('#predict').hide()
        train()


showFace = () ->
  $('#show-face').attr('checked')

train = () ->
  console.log('Started training')
  $('#predict').hide()
  $('#train').show()
  $('#input').show()

  startHarvest = ->
    setupWS('harvesting')
    window.ws.onmessage = (e) ->
      console.log "closing harvesting websocket"
      window.ws.close()
      setBarWidth(70, 'Training model')
      $.post('/train').success(-> 
        console.log("done training")
        setBarWidth(100)
        $('#training').hide()
        setupWS('predict')
        predict()
      )

  saveLabel = (label) ->
    console.log "Saving " + label
    $('#input').hide()
    $('#training').show()
    setBarWidth(40, 'Saving label')
    $.post('/harvest', {label: label}).success(-> 
      setBarWidth('50')
      startHarvest())

  setBarWidth = (w, text = 'Saving images') ->
    $('.bar').css('width', "#{w}%")
    $('.bar').text(text)

  $('#start').click((e)-> 
    e.preventDefault()
    label = $('#name').val()
    saveLabel(label) if label 
  )

navigator.webkitGetUserMedia({'video': true, 'audio': false}, onSuccess, onError) 
setupWS('predict')
predict()

#$('#stop').click((e)-> 
#  e.preventDefault()
#  window.ws.close()
#)

#$('#train').click((e)-> 
#  e.preventDefault()
#  $.post('/train').success(-> console.log("done training"))
#)
