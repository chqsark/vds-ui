uuid = require 'node-uuid' # Generator of RFC4122 UUID
SockJS = require 'sockjs-client' # WebSocket API but fall back to non-WebSocket alternatives when necessary at runtime
Stomp = require 'stompjs' # simple messaging protocol over WebSocket

###
Generate method to send message
###
class Sender
  connecting = false
  messages = []

  constructor: (@url, @callback) ->

  init = (url) ->
    socket = new SockJS url

    stompClient = Stomp.over socket
    ###
    reduce size from 16 * 1024 to avoid over buffer on server side
    ###
    stompClient.maxWebSocketFrameSize = 12 * 1024
    stompClient

  connect: (reconnect = false) ->
    unless connecting
      connecting = true
      console.log if reconnect then "reconnecting" else "connecting ..."

      @stompClient = init @url
      @stompClient.connect {}, =>
        console.log "connected ..."
        connecting = false

        ###
        Eachtime connected to server, a UUID generated to track dom until the connection is closed
        ###
        @trackId = uuid.v4()

        if messages.length > 0
          console.log "resenting messages ..."
          @send message for message in messages
          messages = [];
        @callback? @send

  send: (message, resent = true) =>
    if @stompClient.connected
      console.log "sending message with type [#{message.type}] ..."
      @stompClient.send "/track/#{@trackId}", {}, JSON.stringify(message)
    else
      if resent
        console.log "queued message with type [#{message.type}] ..."
        messages.push message
      @connect true

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

  sender = null
  connect: (callback)->
    sender ?= new Sender getTrackerUrl(@host, @endpoint), callback
    sender.connect()

module.exports = Tracker
