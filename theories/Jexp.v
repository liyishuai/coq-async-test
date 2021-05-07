From Parsec Require Export
     Parser.
From ExtLib Require Export
     Extras.
From Coq Require Export
     ssr.ssrfun.
From AsyncTest Require Export
     Trace
     Common.
Export
  FunNotation.
Open Scope parser_scope.

Inductive jpath :=
  Jpath__This
| Jpath__Array  : nat -> jpath -> jpath
| Jpath__Object : string -> jpath -> jpath.

Inductive jexp :=
  Jexp__Const  : json                             -> jexp
| Jexp__Array  : list jexp                        -> jexp
| Jexp__Object : list (string * jexp)             -> jexp
| Jexp__Ref    : labelT -> jpath                   -> jexp.

Fixpoint jget_strong (p : jpath) (j : json)
  : option json :=
  match p with
  | Jpath__This        => Some j
  | Jpath__Array n p'  => get_nth   n j >>= jget_strong p'
  | Jpath__Object s p' => get_json' s j >>= jget_strong p'
  end.

Definition nth_weak (fp : json -> option json) (n : nat) (j : json)
  : option json :=
  if j is JSON__Array l then
    get_nth n j >>= fp <|>
    last (map Some $ pick_some (map fp l)) None
  else None.

Fixpoint jget_weak (p : jpath) (j : json) : option json :=
  match p with
  | Jpath__This        => Some j
  | Jpath__Array  n p' => nth_weak (jget_weak p') n j
  | Jpath__Object s p' => get_json' s j >>= jget_weak p'
  end.

Example tget_strong (l : labelT) (p : jpath) (t : traceT) : json :=
  odflt JSON__Null $ packet__payload <$> get l t >>= jget_strong p.

Definition tget_weak' (jget : jpath -> json -> option json)
           (l : labelT) (p : jpath) (t : traceT) : json :=
  odflt (last (pick_some $ map (jget p ∘ packet__payload ∘ snd) t) JSON__Null) $
        packet__payload <$> get l t >>= jget p.

Definition tget_weak : labelT -> jpath -> traceT -> json := tget_weak' jget_weak.

Fixpoint jexp_to_json' (tget : labelT -> jpath -> traceT -> json)
         (t : traceT) (e : jexp) : json :=
  match e with
  | Jexp__Const  j => j
  | Jexp__Array  l => JSON__Array  $ map     (jexp_to_json' tget t) l
  | Jexp__Object m => JSON__Object $ map_snd (jexp_to_json' tget t) m
  | Jexp__Ref  l p => tget l p t
  end.

Example jexp_to_json_strong : traceT -> jexp -> json := jexp_to_json' tget_strong.

Definition jexp_to_json_weak : traceT -> jexp -> json := jexp_to_json' tget_weak.
