From AsyncTest Require Export
     Classes
     Instances.
Open Scope string_scope.

Definition or_jexp (e f : jexp) : jexp :=
  match e, f with
  | Jexp__Object el, Jexp__Object fl => Jexp__Object $ (el ++ fl)%list
  | Jexp__Object l, _
  | _, Jexp__Object l => Jexp__Object l
  | _, _ => e
  end.

Module XNotations.
Infix "+" := or_jexp : jexp_scope.
End XNotations.
