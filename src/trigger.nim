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
#! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#! See the License for the specific language governing permissions and
#! limitations under the License.

import std/[
  macros # Used for `unpackVarargs`
]

type
  EventListenerAddCondition[T] = proc(es: EventSystem[T]): bool

  EventSystem*[T] = object
    ## Simple EventSystem object, very basic and bare bones
    listeners*: seq[T]
    listenerAddCond: EventListenerAddCondition[T]

proc esTrue[T](es: EventSystem[T]): bool = true

proc new*[T](_: typedesc[EventSystem[T]], listenerAddCond: EventListenerAddCondition[T] = esTrue): EventSystem[T] =
  ## Creates a new EventSystem object
  result.listeners = newSeq[T]()
  result.listenerAddCond = listenerAddCond

proc addListener*[T](es: var EventSystem[T], listener: T) =
  # Registers a listener to the EventSystem
  if es.listenerAddCond(es):
    es.listeners.add(listener)

template fire*[T](es: EventSystem[T], args: varargs[untyped]) =
  ## Passes the data in `args` to every registered listener
  for listener in es.listeners:
    unpackVarargs(listener, args)