Tracker = require './Tracker'
DomObserver = require './DomObserver'

tracker = new Tracker()

###
# To support async, apply all invocation of setting and link _vds to apply function
###
apply = (name, args...)->
  tracker[name].apply tracker, args
apply args... for args in window._vds
window._vds = {push: apply}

###
# Create a tracker with observer for dom and events
###
domObserver = new DomObserver()
callback = (send) ->
  domObserver.observe send
tracker.connect callback
