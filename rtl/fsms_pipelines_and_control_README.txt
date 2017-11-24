Queue
 - receives ready from outside IP
 - constantly outputs last value and valid
   - pixel color passed outside IP
   - dest location reported for debug
   - valid if value in the queue
 - evicts last value upon receiving ready
 - outputs ready to end of datapath if not full
 - pushes value if not full and datapath valid

End of datapath
 - receives ready from queue
 - constantly outputs registered source color and location
 - requests read from BRAM only if queue is ready and incoming request
 - asserts valid if has a value registered
 - only registers a value if BRAM returns with a valid

Dividers
 - receives request from early arithmetic units
 - enters values into next divider if it is open
   - stores dest pixel location in a register nearby
 - if divider not open, asserts not ready
 - only empties the LRU divider if datapath end is ready
 - asserts valid if LRU divider is finished

Multipliers (beginning of datapath)
 - pipelines dest location with the multiplication request
 - if dividers assert not ready, freeze the pipelines by deasserting clken
 - report ready to Control FSM as passthrough of divider ready

Control FSM
 - Receives valid for incoming pixel from before our IP
 - controls the registers that count which pixel of output is being calculated
 - sends dest pixel location and request to the datapath if datapath ready
 - sends ready out of IP as passthrough of datapath ready