uuid = require 'node-uuid'
SockJS = require 'sockjs-client'
Stomp = require 'stompjs'
TreeMirror = require 'tree-mirror'

socket = new SockJS 'http://vds-api.herokuapp.com/stomp'
stompClient = Stomp.over socket

stompClient.connect {}, (frame) ->
  sessionId = uuid.v4()
  callback =
    initialize: (rootId, children) ->
      message =
        type: 'initialize'
        session: sessionId
        time: Date.now()
        args:
          rootId: rootId
          children: children
      stompClient.send "/track/dom", {}, JSON.stringify(message)

    applyChanged: (removed, addedOrMoved, attributes, text) ->
      message =
        type: 'change'
        session: sessionId
        time: Date.now()
        args:
          removed: removed
          addedOrMoved: addedOrMoved
          attributes: attributes
          text: text
      stompClient.send "/track/dom", {}, JSON.stringify(message)

  mirrorClient = new TreeMirror.Client document,callback
