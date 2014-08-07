TreeMirror = require ('tree-mirror')
uuid = require('node-uuid')

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
    console.log JSON.stringify(message)

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
    console.log JSON.stringify(message)

mirrorClient = new TreeMirror.TreeMirrorClient document,callback
