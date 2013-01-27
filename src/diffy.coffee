# a diffing tool for objects

# The point is to diff objects in javascript, mainly for realtime
# message handling. For example, if you're using Pubnub/Socket.io
# + Backbone: instead of re-rendering the views everytime you get
# a new message, check for changes/additions/deletions then only
# render what's new.

# More documentation in wiki on [github](https://github.com/fouad/diffy).

# Some helper functions + IE indexOf
unless Array::indexOf
  Array::indexOf = (elt) ->
    len = @length >>> 0
    from = Number(arguments_[1]) or 0
    from = (if (from < 0) then Math.ceil(from) else Math.floor(from))
    from += len  if from < 0
    while from < len
      return from  if from of this and this[from] is elt
      from++
    -1

unless Array::remove
  Array::remove = (from, to) ->
    rest = @slice((to or from) + 1 or @length)
    @length = (if from < 0 then @length + from else from)
    @push.apply this, rest

diffy = (_old, _new) ->
  # Resulting object
  result = {}
  # Any keys that only change in value
  result.changes = {}
  # Any keys that are in _new but not _old
  result.additions = {}
  # Any keys that are no longer found in _new
  result.deletions = {}
  
  # Takes keys from _new
  # This way we don't have to loop through _new
  # from the beginning when we want to check additions
  new_keys = []
  new_keys.push(key) for key of _new
  # Loop through all the keys in _old
  for key of _old
    # Check if the key is in _new
    if _new[key]?
      # Check if the value has been modified
      if _old[key] isnt _new[key]
        # If it's been modified, add to changes
        result.changes[key] = { from: _old[key], to: _new[key] }
      # Remove key from potential _new additions
      new_keys.remove new_keys.indexOf key
    # If key isnt in _new, it's been deleted
    else
      result.deletions[key] = { from: _old[key], to: null }
  # Plop all remaining _new keys into additions
  for key in new_keys
    result.additions[key] = { from: null, to: _new[key] }

  return result

# Check if node.js
if module?
  module.exports = diffy