# Trigger-Nim
Trigger is a simple and half-assed attempt at an event system written in Nim, made for use in Nimberite! An example of
how to use it:
```nim
type
  # Unneeded but good for clarity
  ListenerProc = proc(val: int)
  EventData = (int,)

let eventSystem = eventSystem[ListenerProc, EventData]()

discard eventSystem.addListener(
  proc(val: int) =
    echo "A: ", val
)

discard eventSystem.addListener(
  proc(val: int) =
    echo "B: ", val
)

eventSystem.fire (1,)
eventSystem.fire (2,)
```
