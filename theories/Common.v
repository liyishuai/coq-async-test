From QuickChick Require Export
     Decidability.
From ExtLib Require Export
     Functor
     OptionMonad.
From Coq Require Export
     Basics
     List.
Open Scope program_scope.

Definition get' {K V} (eqb : K -> K -> bool) (k : K) : list (K * V) -> option V :=
  fmap snd ∘ find (eqb k ∘ fst).

Definition get {K V} `{Dec_Eq K} : K -> list (K * V) -> option V :=
  get' (fun k k' => k = k'?).
