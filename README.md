# Trigger-Nim
**Note**: This is not going to be maintained purely because I think it's limited in how it can be used, and I much prefer
[Pulse](https://github.com/Nimberite-Development/Pulse-Nim) when compared to this. Use that, or fork this repo instead
please!

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
