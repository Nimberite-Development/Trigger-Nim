#! Copyright 2023 Yu-Vitaqua-fer-Chronos
#!
#! Licensed under the Apache License, Version 2.0 (the "License");
#! you may not use this file except in compliance with the License.
#! You may obtain a copy of the License at
#!
#!     http://www.apache.org/licenses/LICENSE-2.0
#!
#! Unless required by applicable law or agreed to in writing, software
#! distributed under the License is distributed on an "AS IS" BASIS,
#! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express orimplied.
#! See the License for the specific language governing permissions and
#! limitations under the License.

import std/[
  asyncdispatch, # Used for async event stuff
  tables,        # Used for storing listeners using IDs
  macros,        # Used for `newCall`
  locks          # Used for preventing race conditions
]

macro unpackTuple*(callee: untyped, args: tuple): untyped =
  result = newCall(callee)
  for i in 0 ..< args.getTypeImpl.len:
    result.add nnkBracketExpr.newTree(args, newlit i)

type
  EventSystem*[T: proc, R: tuple] = ref object
    ## Simple EventSystem object, very basic and bare bones
    listeners*: Table[uint16, T]
    queue: seq[R]
    lock: Lock = Lock()
    counter: uint16 = 0

proc eventSystem*[T: proc, R: tuple](): EventSystem[T, R] =
  ## Creates a new EventSystem object
  result = EventSystem[T, R](
    queue: newSeq[R](),
    lock: Lock()
  )

  initLock(result.lock)

proc queueEvent*[T: proc, R: tuple](es: EventSystem[T, R], data: R) =
  ## Adds event data to the queue
  withLock(es.lock):
    es.queue.add data

proc addListener*[T: proc, R: tuple](es: EventSystem[T, R], listener: T): uint16 =
  # Registers a listener to the EventSystem and returns the ID of the registered listener
  withLock(es.lock):
    result = es.counter
    es.listeners[es.counter] = listener

    es.counter += 1

proc delListener*[T: proc, R: tuple](es: EventSystem[T, R], id: uint16) =
  withLock(es.lock):
    es.listeners.del(id)

proc fire*[T: proc, R: tuple](es: EventSystem[T, R], args: R) =
  ## Passes the data in `args` to every registered listener
  for listener in es.listeners.values:
    try:
      when compiles(waitFor unpackTuple(listener, args)):
        waitFor unpackTuple(listener, args)
      else:
        unpackTuple(listener, args)
    except Exception as e:
      echo e.msg

proc fire*[T: proc, R: tuple](es: EventSystem[T, R]) =
  ## Triggers all registered listeners with the first event data tuple
  ## in the queue
  withLock(es.lock):
    if es.queue.len > 0:
      for listener in es.listeners.values:
        try:
          when compiles(waitFor unpackTuple(listener, args)):
            waitFor unpackTuple(listener, es.queue[0])
          else:
            unpackTuple(listener, es.queue[0])
        except Exception as e:
          echo e.msg

      es.queue.delete(0)

proc asyncFire*[T: proc, R: tuple](es: EventSystem[T, R], args: R) {.async.} =
  ## Passes the data in `args` to every registered listener and
  ## runs asynchronously
  when not compiles(await unpackTuple(default(T), default(R))):
    {.error: "The event system is not async!".}

  for listener in es.listeners.values:
    try:
      asyncCheck unpackTuple(listener, args)
    except Exception as e:
      echo e.msg

proc asyncFire*[T: proc, R: tuple](es: EventSystem[T, R]) {.async.} =
  ## Triggers all registered listeners with the first event data tuple
  ## in the queue
  when not compiles(await unpackTuple(default(T), default(R))):
    {.error: "The event system is not async!".}

  withLock(es.lock):
    if es.queue.len > 0:
      for listener in es.listeners.values:
        try:
          asyncCheck unpackTuple(listener, es.queue[0])
        except Exception as e:
          echo e.msg

      es.queue.delete(0)
