From AsyncTest Require Export
     Classes
     Instances.
Open Scope string_scope.

Definition or_jexp' (e f : jexp) : string + jexp :=
  match normalise e, normalise f with
  | Jexp__Object el, Jexp__Object fl => inr $ Jexp__Object $ (el ++ fl)%list
  | Jexp__Object _, x
  | x, Jexp__Object _ => inl $ "Not an Object: " ++ to_string x
  | _, _ => inl $ "Neither is an Object: " ++ to_string e
               ++ "or: " ++ to_string f
  end.

Definition or_jexp (e f : jexp) : jexp :=
  if or_jexp' e f is inr x then x else e.

Declare Scope jexp_scope.

Module XNotations.
Infix "+" := or_jexp : jexp_scope.
End XNotations.
