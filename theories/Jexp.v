From ExtLib Require Export
     Extras.
From AsyncTest Require Export
     Trace
     Common.
Export
  FunNotation.

Inductive jpath :=
  Jpath__This
| Jpath__Array  : nat -> jpath -> jpath
| Jpath__Object : string -> jpath -> jpath.

Inductive jexp :=
  Jexp__Const  : json                             -> jexp
| Jexp__Array  : list jexp                        -> jexp
| Jexp__Object : list (string * jexp)             -> jexp
| Jexp__Ref    : labelT -> jpath -> (traceT -> json) -> jexp.

Fixpoint jget (p : jpath) (j : json) : option json :=
  match p with
  | Jpath__This => Some j
  | Jpath__Array n p' => get_nth n j >>= jget p'
  | Jpath__Object s p' => get_json' s j >>= jget p'
  end.

Fixpoint jexp_to_json (t : traceT) (e : jexp) : json :=
  match e with
  | Jexp__Const  j => j
  | Jexp__Array  l => JSON__Array  $ map (jexp_to_json t) l
  | Jexp__Object m =>
    JSON__Object $ map (fun se => let (s, e) := se : string * jexp in
                             (s, jexp_to_json t e)) m
  | Jexp__Ref l p f => if get l t >>= jget p is Some j then j
                    else f t
  end.
