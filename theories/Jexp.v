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

Definition nth_weak (n : nat) (j : IR)
  : option IR :=
  if j is JSON__Array l then
    get_nth n j <|> last (map Some l) None
  else None.

Fixpoint jget_weak (p : jpath) (j : IR) : option IR :=
  match p with
  | Jpath__This        => Some j
  | Jpath__Array  p' n => jget_weak p' j >>= nth_weak n
  | Jpath__Object p' s => jget_weak p' j >>= get_json' s
  end.

Example tget_strong (l : labelT) (p : jpath) (t : traceT) : IR :=
  odflt (JSON__Object []) $ packet__payload <$> get l t >>= jget p.

Definition tget_weak' (jget : jpath -> IR -> option IR)
           (l : labelT) (p : jpath) (t : traceT) : IR :=
  odflt (last (pick_some $ map (jget p ∘ packet__payload ∘ snd) t) $ JSON__Object []) $
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

Definition findpath' (p : jpath) : traceT -> list labelT :=
  fmap fst ∘ filter (fun lj => if jget_weak p (packet__payload $ snd lj) is Some _
                          then true else false).

Definition findpath (p : jpath) (f : IR -> IR) (t : traceT) : list jexp :=
  l <- findpath' p t;; [Jexp__Ref l p f].

Fixpoint IR_to_jexp (j : IR) : jexp :=
  match j with
  | JSON__Array l  => Jexp__Array  (map     IR_to_jexp l)
  | JSON__Object l => Jexp__Object (map_snd IR_to_jexp l)
  | _            => Jexp__Const   j
  end.

Fixpoint normalise (e : jexp) : jexp :=
  match e with
  | Jexp__Const  j => IR_to_jexp  j
  | Jexp__Array  l => Jexp__Array  (map     normalise l)
  | Jexp__Object l => Jexp__Object (map_snd normalise l)
  | _            => e
  end.
