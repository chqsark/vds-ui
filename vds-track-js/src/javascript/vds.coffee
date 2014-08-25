uuid = require 'node-uuid'
SockJS = require 'sockjs-client'
Stomp = require 'stompjs'
require 'mutationobservers'
TreeMirror = require 'tree-mirror'

class Tracker
  properties: {}
  constructor: (@host = 'vds-api.herokuapp.com') ->

  setTrackerHost: (host) ->
    @host = host
  setAccountId: (accountId) ->
    @properties['accountId'] = accountId
  set: (key, value) ->
    @properties[key] = value

  getTrackerUrl = (host)->
    (if 'https:' == document.location.protocol then 'https://' else 'http://') + host + '/stomp'

  ID_PROP = '__mutation_summary_node_map_id__'
  addEventListener = (element, eventType, eventHandler) ->
    if element.addEventListener
      element.addEventListener eventType, eventHandler, false
    else if element.attachEvent
      element.attachEvent('on' + eventType, eventHandler)
    else
      element['on' + eventType] = eventHandler

  connect: (buffer)->
    socket = new SockJS getTrackerUrl(@host)
    stompClient = Stomp.over socket
    stompClient.maxWebSocketFrameSize = 12 * 1024

    stompClient.connect {}, (frame) =>
      trackId = uuid.v4()

      eventHandler = (event) ->
        message =
          type: 'event'
          id: trackId
          time: event.timeStamp || Date.now()
          event:
            id: event.target[ID_PROP]
            type: event.type

        if stompClient.connected
          stompClient.send "/track/" + trackId, {}, JSON.stringify(message)
        else
          mirrorClient?.disconnect()
          @connect(-> stompClient.send "/track/" + trackId, {}, JSON.stringify(message))
      domObserver =
        initialize: (rootId, children) =>
          message =
            type: 'initialize'
            properties: @properties
            id: trackId
            time: Date.now()
            url: window.location.href
            dom:
              rootId: rootId
              children: children
          stompClient.send "/track/" + trackId, {}, JSON.stringify(message)

        applyChanged: (removed, addedOrMoved, attributes, text) =>
          message =
            type: 'change'
            id: trackId
            time: Date.now()
            url: window.location.href
            dom:
              removed: removed
              addedOrMoved: addedOrMoved
              attributes: attributes
              text: text
          if stompClient.connected
            stompClient.send "/track/" + trackId, {}, JSON.stringify(message)
          else
            mirrorClient?.disconnect()
            @connect()

      buffer?()
      addEventListener document, event, eventHandler for event in ['click']
      mirrorClient = new TreeMirror.Client document, domObserver

apply = (name, args...)->
  tracker[name].apply tracker, args
TrackerProxy = ->
  {push: apply}

tracker = new Tracker()
apply args... for args in window._vds
tracker.connect()

window._vds = new TrackerProxy()