From Parsec Require Export
     Parser.
From ExtLib Require Export
     Extras.
From JSON Require Export
     Jpath.
From Coq Require Export
     ssr.ssrfun.
From AsyncTest Require Export
     Trace
     Common.
Export
  FunNotation.
Open Scope parser_scope.

Inductive jexp :=
  Jexp__Const  : IR                               -> jexp
| Jexp__Array  : list jexp                        -> jexp
| Jexp__Object : list (string * jexp)             -> jexp
| Jexp__Ref    : labelT -> jpath -> (IR -> IR)       -> jexp.

Definition nth_weak (fp : IR -> option IR) (n : nat) (j : IR)
  : option IR :=
  if j is JSON__Array l then
    get_nth n j >>= fp <|>
    last (map Some $ pick_some (map fp l)) None
  else None.

Fixpoint jget_weak (p : jpath) (j : IR) : option IR :=
  match p with
  | Jpath__This        => Some j
  | Jpath__Array  n p' => nth_weak (jget_weak p') n j
  | Jpath__Object s p' => get_json' s j >>= jget_weak p'
  end.

Example tget_strong (l : labelT) (p : jpath) (t : traceT) : IR :=
  odflt JSON__Null $ packet__payload <$> get l t >>= jget p.

Definition tget_weak' (jget : jpath -> IR -> option IR)
           (l : labelT) (p : jpath) (t : traceT) : IR :=
  odflt (last (pick_some $ map (jget p ∘ packet__payload ∘ snd) t) JSON__Null) $
        packet__payload <$> get l t >>= jget p.

Definition tget_weak : labelT -> jpath -> traceT -> IR := tget_weak' jget_weak.

Fixpoint jexp_to_IR' (tget : labelT -> jpath -> traceT -> IR)
         (t : traceT) (e : jexp) : IR :=
  match e with
  | Jexp__Const  j => j
  | Jexp__Array  l => JSON__Array  $ map     (jexp_to_IR' tget t) l
  | Jexp__Object m => JSON__Object $ map_snd (jexp_to_IR' tget t) m
  | Jexp__Ref  l p f => f $ tget l p t
  end.

Example jexp_to_IR_strong : traceT -> jexp -> IR := jexp_to_IR' tget_strong.

Definition jexp_to_IR_weak : traceT -> jexp -> IR := jexp_to_IR' tget_weak.
