From QuickChick Require Export
     Decidability.
From ExtLib Require Export
     Functor
     OptionMonad.
From Coq Require Export
     Basics
     List.
Export
  ListNotations.
Open Scope program_scope.

Definition get' {K V} (eqb : K -> K -> bool) (k : K) : list (K * V) -> option V :=
  fmap snd ∘ find (eqb k ∘ fst).

Definition get {K V} `{Dec_Eq K} : K -> list (K * V) -> option V :=
  get' (fun k k' => k = k'?).

Definition map_snd {K V U} (f : V -> U) : list (K * V) -> list (K * U) :=
  map (fun kv => let (k, v) := kv : K * V in (k, f v)).

Fixpoint pick_some {A} (l : list (option A)) : list A :=
  match l with
  | [] => []
  | Some a :: l' => a :: pick_some l'
  | None   :: l' =>     pick_some l'
  end.
