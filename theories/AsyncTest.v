From QuickChick Require Export
     QuickChick.
From ITree Require Export
     Exception
     ITree.
From SimpleIO Require Export
     SimpleIO.
From AsyncTest Require Export
     Instances.

Variant clientE {gen_state} : Type -> Type :=
  Client__Recv :             clientE (option packetT)
| Client__Send : gen_state -> clientE (option packetT).

Module Type AsyncTestSIG.

Parameter gen_state     : Type.
Parameter otherE        : Type -> Type.
Parameter other_handler : otherE ~> IO.
Arguments other_handler {_}.

Notation failureE       := (exceptE string).
Notation tE             := (failureE +' @clientE gen_state +' otherE).

Parameter conn_state    : Type.
Parameter init_state    : conn_state.
Parameter recv_response : Monads.stateT conn_state IO (option packetT).
Parameter send_request  : connT -> json -> Monads.stateT conn_state IO unit.
Parameter cleanup       : conn_state -> IO unit.

Parameter gen_request   : gen_state -> traceT -> IO (clientT * jexp).

Parameter tester_state  : Type.
Parameter tester_init   : IO tester_state.
Parameter tester        : tester_state -> itree tE void.

End AsyncTestSIG.

Module AsyncTest (SIG : AsyncTestSIG).
Include SIG.

Notation scriptT := (list (clientT * jexp)).

Definition shrink_execute' (exec : scriptT -> IO (bool * traceT))
           (init : scriptT) : IO (option scriptT) :=
  prerr_endline "===== initial script =====";;
  prerr_endline (to_string init);;
  IO.fix_io
    (fun shrink_rec ss =>
       match ss with
       | [] => prerr_endline "<<<<< shrink exhausted >>>>";; ret None
       | sc :: ss' =>
         prerr_endline "<<<<< current script >>>>>>";;
         prerr_endline (to_string sc);;
         '(b, tr) <- exec sc;;
         if b : bool
         then prerr_endline "===== accepting trace =====";;
              prerr_endline (to_string tr);;
              shrink_rec ss'
         else prerr_endline "===== rejecting trace =====";;
              prerr_endline (to_string tr);;
              prerr_endline "<<<<< shrink ended >>>>>>>>";;
              ret (Some sc)
       end) (repeat_list 20 $ shrink init).

Definition shrink_execute (first_exec : IO (bool * (scriptT * traceT)))
           (then_exec : scriptT -> IO (bool * traceT)) : IO bool :=
  '(b, (sc, tr)) <- first_exec;;
  if b : bool
  then ret true
  else prerr_endline "<<<<< rejecting trace >>>>>";;
       prerr_endline (to_string tr);;
       IO.while_loop (shrink_execute' then_exec) sc;;
       ret false.

End AsyncTest.
