TreeMirror = require ('tree-mirror')

callback =
  initialize: (rootId, children) ->
    message =
      f: 'initialize'
      args: [
        rootId
        children
    console.log JSON.stringify(message)

  applyChanged: (removed, addedOrMoved, attributes, text) ->
    message =
      f: 'applyChanged'
      args:
        removed: removed
        addedOrMoved: addedOrMoved
        attributes: attributes
        text: text
    console.log JSON.stringify(message)

mirrorClient = new TreeMirror.TreeMirrorClient document,callback
