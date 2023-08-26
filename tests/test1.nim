import unittest
import asyncdispatch

import trigger

type EventData = (int,)

test "Synchronous Event Firing":
  type ListenerProc = proc(val: int)

  var es = eventSystem[ListenerProc, EventData]()

  es.addListener(
    proc(val: int) =
      echo "A: ", val
  )

  es.addListener(
    proc(val: int) =
      echo "B: ", val
  )

  es.fire (1,)

  es.queueEvent (2,)
  es.fire()

test "Asynchronous Event Firing":
  type ListenerProc = proc(val: int) {.async.}

  var es = eventSystem[ListenerProc, EventData]()

  es.addListener(
    proc(val: int) {.async.} =
      echo "A: ", val
  )

  es.addListener(
    proc(val: int) {.async.} =
      echo "B: ", val
  )

  es.fire (1,)

  es.queueEvent (2,)
  waitFor es.asyncFire()
