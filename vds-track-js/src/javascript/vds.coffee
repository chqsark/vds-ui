uuid = require 'node-uuid'
SockJS = require 'sockjs-client'
Stomp = require 'stompjs'
TreeMirror = require 'tree-mirror'

socket = new SockJS 'http://vds-api.herokuapp.com/stomp'
stompClient = Stomp.over socket
stompClient.maxWebSocketFrameSize = 12 * 1024

stompClient.connect {}, (frame) ->
  trackId = uuid.v4()
  callback =
    initialize: (rootId, children) ->
      message =
        type: 'initialize'
        id: trackId
        time: Date.now()
        args:
          rootId: rootId
          children: children
      stompClient.send "/track/" + trackId, {}, JSON.stringify(message)

    applyChanged: (removed, addedOrMoved, attributes, text) ->
      message =
        type: 'change'
        id: trackId
        time: Date.now()
        args:
          removed: removed
          addedOrMoved: addedOrMoved
          attributes: attributes
          text: text
      stompClient.send "/track/" + trackId, {}, JSON.stringify(message)

  mirrorClient = new TreeMirror.Client document,callback
