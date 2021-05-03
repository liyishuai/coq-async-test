From QuickChick Require Export
     QuickChick.
From JSON Require Export
     Instances.
From AsyncTest Require Export
     Jexp.

Definition shrinkValue {K V} (shr : V -> list V)
  : list (K * V) -> list (list (K * V)) :=
  shrinkListAux (fun kv => let (k, v) := kv : K * V in
                        map (pair k) $ shr v).

Instance Shrink__json : Shrink json :=
  {| shrink :=
       fix shrink_json (j : json) : list json :=
         match j with
         | JSON__Number n => map JSON__Number $ shrink n
         (* | JSON__Array  l => map JSON__Array  $ shrinkListAux shrink_json l *)
         (* | JSON__Object l => map JSON__Object $ shrinkValue   shrink_json l *)
         | _            => []
         end |}.

Instance Shrink__jexp : Shrink jexp :=
  {| shrink :=
       fix shrink_jexp (e : jexp) : list jexp :=
         match e with
         | Jexp__Const  j => map Jexp__Const  $ shrink j
         (* | Jexp__Array  l => map Jexp__Array  $ shrinkListAux shrink_jexp l *)
         (* | Jexp__Object l => map Jexp__Object $ shrinkValue   shrink_jexp l *)
         | _ => []
         end |}.

Instance Serialize__jpath : Serialize jpath :=
  let fix jpath_to_list (p : jpath) : list sexp :=
      match p with
      | Jpath__This       => []
      | Jpath__Array  n p => to_sexp n::jpath_to_list p
      | Jpath__Object s p => Atom s   ::jpath_to_list p
      end in
  List ∘ jpath_to_list.

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
    | Jexp__Ref  l p => [[Atom "label"; to_sexp l]; [Atom "path"; to_sexp p]]
    end.
