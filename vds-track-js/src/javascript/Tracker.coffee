uuid = require 'node-uuid' # Generator of RFC4122 UUID
SockJS = require 'sockjs-client' # WebSocket API but fall back to non-WebSocket alternatives when necessary at runtime
Stomp = require 'stompjs' # simple messaging protocol over WebSocket

class Tracker
  ###
  Name of host to send message over WebSocket. It includes port if avaiable.
  ###
  host: 'vds-api.herokuapp.com'
  ###
  Endpoint of Websocket
  ###
  endpoint: '/stomp'
  ###
  Use to store attributes set by client and send to server with initial dom.
  ###
  properties: {}

  setTrackerHost: (host) ->
    @host = host
  setAccountId: (accountId) ->
    @properties['accountId'] = accountId
  set: (key, value) ->
    @properties[key] = value

  getTrackerUrl = (host, endpoint) ->
    ###
    Use same protocol with document to avoid HTTP/HTTPS Mixed Content Error.
    ###
    (if 'https:' == document.location.protocol then 'https://' else 'http://') + host + endpoint

  ###
  Generate method to send message
  ###
  sender = (stompClient, trackId, reconnect) ->
    connecting = false
    messages = []
    (message, resent = true) ->
      if stompClient.connected
        console.log "send message with type [#{message.type}] ..."
        stompClient.send "/track/#{trackId}", {}, JSON.stringify(message)
      else
        messages.push message if resent

        unless connecting
          console.log "reconnect ..."
          connecting = true
          reconnect messages

  connect: (callback, messages)->
    url = getTrackerUrl @host, @endpoint
    socket = new SockJS url
    stompClient = Stomp.over socket
    ###
    reduce size from 16 * 1024 to avoid over buffer on server side
    ###
    stompClient.maxWebSocketFrameSize = 12 * 1024

    stompClient.connect {}, =>
      ###
      Eachtime connected to server, a UUID generated to track dom until the connection is closed
      ###
      trackId = uuid.v4()

      send = sender(stompClient, trackId, (messages) => @connect callback, messages)

      if messages
        console.log "resent messages ..."
        send message for message in messages
      callback? send

module.exports = Tracker
