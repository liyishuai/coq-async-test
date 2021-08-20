From QuickChick Require Export
     QuickChick.
From ITree Require Export
     Exception
     ITree.
From SimpleIO Require Export
     SimpleIO.
From AsyncTest Require Export
     Instances.
Export
  SumNotations.
Open Scope sum_scope.

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
Parameter send_request  : clientT -> IR -> Monads.stateT conn_state IO bool.
Parameter cleanup       : conn_state -> IO unit.

Parameter gen_step      : gen_state -> traceT -> IO (clientT * jexp).

Parameter tester_state  : Type.
Parameter tester_init   : IO tester_state.
Parameter tester        : tester_state -> itree tE void.

End AsyncTestSIG.

Module AsyncTest (SIG : AsyncTestSIG).
Include SIG.

Notation scriptT := (list (clientT * jexp * labelT)).

Definition shrink_execute' (exec : scriptT -> IO (bool * traceT))
           (init : scriptT) : IO (option scriptT) :=
  prerr_endline "===== initial script =====";;
  prerr_endline (to_string init);;
  IO.fix_io
    (fun shrink_rec ss =>
       match ss with
       | [] => prerr_endline "<<<<< shrink exhausted >>>>";; ret None
       | sc :: ss' =>
         prerr_endline (to_string (List.length ss'));;
         (* prerr_endline "<<<<< current script >>>>>>";; *)
         (* prerr_endline (to_string sc);; *)
         '(b, tr) <- exec sc;;
         if b : bool
         then (* prerr_endline "===== accepting trace =====";; *)
              (* prerr_endline (to_string tr);; *)
              shrink_rec ss'
         else prerr_endline "<<<<< rejecting trace >>>>>";;
              prerr_endline (to_string tr);;
              (* prerr_endline "<<<<< shrink ended >>>>>>>>";; *)
              ret (Some sc)
       end) (repeat_list 10 $ shrinkListAux (const []) init).

Definition shrink_execute (first_exec : IO (bool * (scriptT * traceT)))
           (then_exec : scriptT -> IO (bool * traceT)) : IO bool :=
  '(b, (sc, tr)) <- first_exec;;
  if b : bool
  then ret true
  else prerr_endline "<<<<< rejecting trace >>>>>";;
       prerr_endline (to_string tr);;
       IO.while_loop (shrink_execute' then_exec) sc;;
       ret false.

Fixpoint execute' {R} (fuel : nat) (s : conn_state)
         (oscript : option scriptT) (acc : scriptT * traceT) (m : itree tE R)
  : IO (bool * conn_state * (scriptT * traceT)) :=
  let (script0, trace0) := acc in
  match fuel with
  | O => ret (true, s, acc)
  | S fuel =>
    match observe m with
    | RetF _ => ret (true, s, acc)
    | TauF m' => execute' fuel s oscript acc m'
    | VisF e k =>
      match e with
      | (Throw err|) =>
        prerr_endline err;;
        ret (false, s, acc)
      | (|ce|) =>
        match ce in clientE Y return (Y -> _) -> _ with
        | Client__Recv =>
          fun k => '(s', op) <- recv_response s;;
                let acc' :=
                    match op with
                    | Some p =>
                      let dst : connT := packet__dst p in
                      let lreqs :=
                          filter (fun lpkt => packet__src (snd lpkt) = dst?)
                                 trace0 in
                      let prevs :=
                          length (filter (fun lpkt => packet__dst (snd lpkt) = dst?)
                                         trace0) in
                      let label := nth prevs (map fst lreqs) O in
                      (script0, trace0 ++ [(label, p)])
                    | None => acc
                    end in
                execute' fuel s' oscript acc' (k op)
        | Client__Send gs =>
          fun k => '(ostep, osc') <-
                match oscript with
                | Some [] => ret (None, Some [])
                | Some (sc :: script') =>
                  ret (Some sc, Some script')
                | None =>
                  let l : labelT := S $ fold_left max (map snd script0) O in
                  step <- gen_step gs trace0;;
                  ret (Some (step, l), None)
                end;;
                match ostep with
                | Some ((c, e, l) as step) =>
                  let req : IR      := jexp_to_IR_weak trace0 e           in
                  let pkt : packetT := Packet (Conn__Client c) Conn__Server req in
                  '(s', b) <- send_request c req s;;
                  if b : bool
                  then execute' fuel s' osc'
                                (script0 ++ [step], trace0 ++ [(l, pkt)])
                                (k (Some pkt))
                  else execute' fuel s' osc' acc (k None)
                | None => execute' fuel s osc' acc (k None)
                end
        end k
      | (||oe) => other_handler oe >>= execute' fuel s oscript acc ∘ k
      end
    end
  end.

Definition execute {R} (m : tester_state -> itree tE R)
           (oscript : option scriptT) : IO (bool * (scriptT * traceT)) :=
  tester_init_state <- tester_init;;
  '(b, s, t') <- execute' 5000 init_state oscript ([], [])
                         (m tester_init_state);;
  cleanup s;;
  ret (b, t').

Definition test : IO bool :=
  shrink_execute (execute tester None)
                 (fmap (fun '(b, (_, t)) => (b, t)) ∘ execute tester ∘ Some).

End AsyncTest.
