import unittest
import asyncdispatch

import trigger

type EventData = (int,)

test "Synchronous Event Firing":
  type ListenerProc = proc(val: int)

  let es = eventSystem[ListenerProc, EventData]()

  discard es.addListener(
    proc(val: int) =
      echo "A: ", val
  )

  let bListener = es.addListener(
    proc(val: int) =
      echo "B: ", val
  )

  es.fire (1,)

  es.delListener(bListener)

  es.queueEvent (2,)
  es.fire()

test "Asynchronous Event Firing":
  type ListenerProc = proc(val: int) {.async.}

  let es = eventSystem[ListenerProc, EventData]()

  discard es.addListener(
    proc(val: int) {.async.} =
      echo "A: ", val
  )

  let bListener = es.addListener(
    proc(val: int) {.async.} =
      echo "B: ", val
  )

  es.fire (1,)

  es.delListener(bListener)

  es.queueEvent (2,)
  waitFor es.asyncFire()
