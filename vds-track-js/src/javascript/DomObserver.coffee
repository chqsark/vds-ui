require 'mutationobservers' # Mutation Observers Polyfill for IE9 & 10
TreeMirror = require 'tree-mirror' # Utility class from Mutation Summary to detect change of dom

class DomObserver
  mirrorClient = null

  registerDomObserver: ->
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

  registerEventListener: ->
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

    addEventListener document, event, eventHandler for event in ['click']

  connect: (send) ->
    @send = send
    @registerEventListener() unless mirrorClient
    @registerDomObserver()

module.exports = DomObserver