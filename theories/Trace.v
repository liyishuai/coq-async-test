From JSON Require Export
     JSON.

Definition clientT := nat.
Variant connT :=
  Conn__Server
| Conn__Client : clientT -> connT.

Notation IR := json.

Record packetT :=
  Packet { packet__src     : connT;
           packet__dst     : connT;
           packet__payload : IR }.

Definition labelT := nat.

Definition traceT := list (labelT * packetT).
