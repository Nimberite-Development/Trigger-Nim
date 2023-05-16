import unittest

import trigger

test "Event Firing":
  type ListenerProc = proc(val: int)

  var eventSystem = EventSystem[ListenerProc].new()

  eventSystem.addListener[:ListenerProc](
    proc(val: int) =
      echo "A: ", val
  )

  eventSystem.addListener[:ListenerProc](
    proc(val: int) =
      echo "B: ", val
  )

  eventSystem.fire(1)
  eventSystem.fire[:ListenerProc](2)