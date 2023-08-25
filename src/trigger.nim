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
  macros # Used for `newCall`
]

macro unpackTuple*(callee: untyped, args: tuple): untyped =
  result = newCall(callee)
  for i in 0 ..< args.getTypeImpl.len:
    result.add nnkBracketExpr.newTree(args, newlit i)

type
  EventListenerAddCondition[T: proc] = proc(es: EventSystem[T]): bool

  EventSystem*[T: proc] = object
    ## Simple EventSystem object, very basic and bare bones
    listeners*: seq[T]
    listenerAddCond: EventListenerAddCondition[T]

proc esTrue[T: proc](es: EventSystem[T]): bool = true

proc new*[T: proc](_: typedesc[EventSystem[T]], listenerAddCond: EventListenerAddCondition[T] = esTrue): EventSystem[T] =
  ## Creates a new EventSystem object
  EventSystem[T](
    listeners: newSeq[T](),
    listenerAddCond: listenerAddCond
  )

proc addListener*[T: proc](es: var EventSystem[T], listener: T) =
  # Registers a listener to the EventSystem
  if es.listenerAddCond(es):
    es.listeners.add(listener)

proc fire*[T: proc, R: tuple](es: EventSystem[T], args: R) =
  ## Passes the data in `args` to every registered listener
  for listener in es.listeners:
    unpackTuple(listener, args)

