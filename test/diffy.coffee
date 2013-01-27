assert = require 'assert'
diffy = require '../lib/diffy'

Object::equals = (obj) ->
  for p of this
    return false  if typeof (obj[p]) is "undefined"
  for p of this
    if this[p]
      switch typeof (this[p])
        when "object"
          return false  unless this[p].equals(obj[p])
        when "function"
          return false  if typeof (obj[p]) is "undefined" or (p isnt "equals" and this[p].toString() isnt obj[p].toString())
        else
          return false  unless this[p] is obj[p]
    else
      return false  if obj[p]
  for p of obj
    return false  if typeof (this[p]) is "undefined"
  true

describe 'diffy', ->
  it 'should have no changes', ->
    obj = { same: 'same' }
    obj2 = { same: 'same' }
    result = diffy obj, obj2
    assert result.changes.equals {}
  it 'should have one addition', ->
    obj = {}
    obj2 = { add: 'add' }
    result = diffy obj, obj2
    assert result.additions.equals { add: { from: null, to: 'add' } }
  it 'should have one deletion', ->
    obj = { del: 'del' }
    obj2 = {}
    result = diffy obj, obj2
    assert result.deletions.equals { del: { from: 'del', to: null } }
  it 'should have one deletion and one addition', ->
    obj = { del: 'del' }
    obj2 = { add: 'add' }
    result = diffy obj, obj2
    expected =
      changes: {}
      additions:
        add:
          from: null
          to: 'add'
      deletions:
        del:
          from: 'del'
          to: null
    assert result.equals expected
  it 'should have one: change, deletion and addition', ->
    obj = { del: 'del', change: 'from' }
    obj2 = { add: 'add', change: 'to' }
    result = diffy obj, obj2
    expected =
      changes:
        change:
          from: 'from'
          to: 'to'
      additions:
        add:
          from: null
          to: 'add'
      deletions:
        del:
          from: 'del'
          to: null
    assert result.equals expected
