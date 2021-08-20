From JSON Require Import
     Encode.
From AsyncTest Require Import
     Jexp.
Import JpathNotations.
Open Scope json_scope.

Example response : IR :=
  jobj "fields" (jobj "ETag" "foo").

Goal jget_weak (this@"fields"@"ETag") response = Some (JSON__String "foo").
Proof. reflexivity. Qed.
