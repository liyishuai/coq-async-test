From JSON Require Export
     JSON.

Definition clientT := nat.
Variant connT :=
  Conn__Server
| Conn__Client : clientT -> connT.

Record packetT :=
  Packet { packet__src     : connT;
           packet__dst     : connT;
           packet__payload : json }.

Definition labelT := nat.

Definition traceT := list (labelT * packetT).
