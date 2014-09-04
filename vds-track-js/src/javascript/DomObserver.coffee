require 'mutationobservers' # Mutation Observers Polyfill for IE9 & 10
TreeMirror = require 'tree-mirror' # Utility class from Mutation Summary to detect change of dom

class DomObserver
  mirrorClient = null
  registerDomObserver: ->
    ###
    # Disconnect existed mirror client to aviod double observing
    ###
    mirrorClient?.disconnect()
    domObserver =
      initialize: (rootId, children) =>
        message =
          type: 'initialize'
          properties: @properties
          time: Date.now()
          url: window.location.href
          dom:
            rootId: rootId
            children: children
        @send message

      applyChanged: (removed, addedOrMoved, attributes, text) =>
        message =
          type: 'change'
          time: Date.now()
          url: window.location.href
          dom:
            removed: removed
            addedOrMoved: addedOrMoved
            attributes: attributes
            text: text
        @send message, false
    mirrorClient = new TreeMirror.Client document, domObserver

  eventHandler = null
  registerEventListener: ->
    events = ['click'] # Events listened
    ###
    # Unique id added by Mutation Summary to track node. Send to server to identify the node which event tagets on
    ###
    ID_PROP = '__mutation_summary_node_map_id__'

    addEventListener = (element, eventType, eventHandler) ->
      if element.addEventListener
        element.addEventListener eventType, eventHandler, true
      else if element.attachEvent
        element.attachEvent('on' + eventType, eventHandler)
      else
        element['on' + eventType] = eventHandler

    eventHandler = (event) =>
      message =
        type: 'event'
        time: event.timeStamp || Date.now()
        event:
          id: event.target[ID_PROP]
          type: event.type

      @send message

    addEventListener document, event, eventHandler for event in events

  observe: (send) ->
    @send = send
    ###
    # Only register once for each event listener to avoid duplicate listeners send same events multiple times
    ###
    @registerEventListener() unless eventHandler
    @registerDomObserver()

module.exports = DomObserver