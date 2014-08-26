require 'mutationobservers' # Mutation Observers Polyfill for IE9 & 10
TreeMirror = require 'tree-mirror' # Utility class from Mutation Summary to detect change of dom
Tracker = require './Tracker'

tracker = new Tracker()

apply = (name, args...)->
  tracker[name].apply tracker, args
apply args... for args in window._vds

ID_PROP = '__mutation_summary_node_map_id__'
addEventListener = (element, eventType, eventHandler) ->
  if element.addEventListener
    element.addEventListener eventType, eventHandler, true
  else if element.attachEvent
    element.attachEvent('on' + eventType, eventHandler)
  else
    element['on' + eventType] = eventHandler

callback = (send) ->
  eventHandler = (event) ->
    message =
      type: 'event'
      time: event.timeStamp || Date.now()
      event:
        id: event.target[ID_PROP]
        type: event.type

    send message
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
      send message

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
      send message, false

  addEventListener document, event, eventHandler for event in ['click']
  mirrorClient?.disconnect()
  mirrorClient = new TreeMirror.Client document, domObserver

tracker.connect callback

TrackerProxy = ->
  {push: apply}
window._vds = new TrackerProxy()