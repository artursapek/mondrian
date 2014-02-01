###


  Archive Event

  Events are amazing creatures. They are specialized objects for certain types
  of events, obviously, that happen when one is using Mondy.

  The best part about them is they are serializable as  string,
  and can be completely restored from one as well.

  That means that this is a archive system that doesn't have to die when the session dies.

  Let me repeat that: WE CAN PASS AROUND FILE HISTORIES AS BLOBS OF TEXT.
  And it's rather space-efficient as well, given its power.


  Some key concepts:

  Abstraction through mapping

    There are different types of Events. Things like nudges and rotations are stored
    as the relevant measurements as opposed to actual changes between points,
    for efficiency's sake.

    It's much easier to just say "rotate the element at zindex 3 by 12°" than,
    "Find the element with the points "M577.5621054400491,303.51924490455684 C592.3321407555776,35..."
    and update that to "M560.5835302627165,358.31402081341434 C536.5694824830614,406.6805951105095..."

  Minimal serialization

    These are not meant to be human-readable, when they are stored they use tons of one-character indicators.
    A typical rotation event looks like this:
      {"t":"m:r","i":[0],"args":{"angle":42.278225912417064,"origin":{"x":498.21488701676367,"y":308.96076780376694,"zoomLevel":1}}}

   "t" = meaning type
   "m:r" = map: rotate
   "i" = index

  For now the args are more reasonably labeled so shit doesn't get TOO confusing

  We'll see how this goes and later I might change the grammar/standard if it's worth making more efficient.




  types

    "m:" = map... MapEvent
      This one has a second argument - which method do we map? It follows the colon.

      "r" = rotate
      "n" = nudge
      "s" = scale

    "e" = ExistenceEvent

    "d" = DiffEvent



###

class Event
  constructor: () ->

  # This is true when it was the last event to happen.
  # So basically, if current == true then this is where we're at in the timeline.
  current: false

  # The index this event is at in archive.events
  position: undefined

  toString: ->
    JSON.stringify @toJSON()

  fromJSON: (json) ->
    if typeof json is "string"
      json = JSON.parse json

    switch json.t[0]
      when "m"
        # MapEvent
        # Get the fun key from the character following the colon
        funKey = {
          n: "nudge"
          s: "scale"
          r: "rotate"
        }[json.t[2]]
        indexes = json.i
        args = json.a
        return new MapEvent(funKey, indexes, args)

      when "e"
        # ExistenceEvent
        ee = new ExistenceEvent(json.a)
        ee.mode = { d: "delete", c: "create" }[json.t[2]]

        return ee

      when "p"
        # PointExistenceEvent
        point = json.p
        at = json.i
        elem = parseInt json.e, 10
        mode = { d: "delete", c: "create" }[json.t[2]]
        pe = new PointExistenceEvent(elem, point, at)
        pe.mode = mode
        return pe

      when "a"
        # AttrEvent
        new AttrEvent(json.i, json.c, json.o)

      when "z"
        new ZIndexEvent(json.ib, json.ia, json.d)




window.Event = Event

