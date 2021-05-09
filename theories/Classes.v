From JSON Require Export
     Encode.
From AsyncTest Require Export
     Jexp.

Class XEncode T := xencode : T -> jexp.

Definition jkv (k : string) (v : jexp) : jexp :=
  Jexp__Object [(k, v)].

Definition jobj' {T} (encode : T -> IR) (k : string) (v : T) : jexp :=
  jkv k $ Jexp__Const $ encode v.

Definition jobj {T} `{JEncode T} : string -> XEncode T := jobj' encode.
