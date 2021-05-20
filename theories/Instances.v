From QuickChick Require Export
     QuickChick.
From JSON Require Export
     Instances.
From AsyncTest Require Export
     Classes.

Global Instance Dec_Eq__connT : Dec_Eq connT.
Proof. dec_eq. Defined.

Definition shrinkListNoRemove {A} (shr : A -> list A) : list A -> list (list A) :=
  fix shrinkListNoRemove_ (l : list A) : list (list A) :=
  if l is x::xs then (map (flip cons xs) $ shr x) ++
                    (map (cons x) $ shrinkListNoRemove_ xs)
  else [].

Definition shrinkValue {K V} (shr : V -> list V)
  : list (K * V) -> list (list (K * V)) :=
  shrinkListNoRemove (fun kv => let (k, v) := kv : K * V in
                             map (pair k) $ shr v).

Instance Shrink__IR : Shrink IR :=
  {| shrink :=
       fix shrink_IR (j : IR) : list IR :=
         match j with
         | JSON__Number n => map JSON__Number $ shrink n
         | JSON__Array  l => map JSON__Array  $ shrinkListAux shrink_IR l
         | JSON__Object l => map JSON__Object $ shrinkValue   shrink_IR l
         | _            => []
         end |}.

Instance Shrink__jexp : Shrink jexp :=
  {| shrink :=
       fix shrink_jexp (e : jexp) : list jexp :=
         match e with
         | Jexp__Const  j => map Jexp__Const  $ shrink j
         | Jexp__Array  l => map Jexp__Array  $ shrinkListAux shrink_jexp l
         | Jexp__Object l => map Jexp__Object $ shrinkValue   shrink_jexp l
         | _ => []
         end |}.

Definition xencode__list {A} `{XEncode A} : XEncode (list A) :=
  fun l => Jexp__Array $ map xencode l.

Definition encode__xencode {A} `{XEncode A} : JEncode A :=
  jexp_to_IR_weak [] ∘ xencode.

Local Open Scope sexp_scope.

Instance Serialize__connT : Serialize connT :=
  fun c =>
    match c with
    | Conn__Client c => [Atom "Client"; to_sexp c]
    | Conn__Server   => [Atom "Server"]
    end.

Instance Serialize__packetT : Serialize packetT :=
  fun pkt =>
    let 'Packet s d p := pkt in
    [[Atom "Src"; to_sexp s];
     [Atom "Dst"; to_sexp d];
     [Atom "Msg"; to_sexp p]].

Instance Serialize__jexp : Serialize jexp :=
  fix jexp_to_sexp (e : jexp) : sexp :=
    match e with
    | Jexp__Const  j => to_sexp j
    | Jexp__Array  l => List $ map jexp_to_sexp l
    | Jexp__Object l => List $ map (fun se => let (s, e) := se : string * jexp in
                                        [Atom s; jexp_to_sexp e]) l
    | Jexp__Ref  l p _ => [[Atom "label"; to_sexp l]; [Atom "path"; to_sexp p]]
    end.
