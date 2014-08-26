Tracker = require './Tracker'
DomObserver = require './DomObserver'

tracker = new Tracker()
apply = (name, args...)->
  tracker[name].apply tracker, args
apply args... for args in window._vds

domObserver = new DomObserver()
callback = (send) ->
  domObserver.connect send
tracker.connect callback

TrackerProxy = ->
  {push: apply}
window._vds = new TrackerProxy()