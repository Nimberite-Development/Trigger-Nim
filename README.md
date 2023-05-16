# Trigger-Nim
Trigger is a simple and half-assed attempt at an event system written in Nim, made for use in Nimberite! An example of
how to use it:
```nim
type ListenerProc = proc(val: int) # Unneeded, but a nice short-hand

var eventSystem = EventSystem[ListenerProc].new()

eventSystem.addListener(
  proc(val: int) =
    echo "A: ", val
)

eventSystem.addListener(
  proc(val: int) =
    echo "B: ", val
)

eventSystem.fire(1)
eventSystem.fire(2)
```

## To-Do
[ ] Add a way to unregister listeners.