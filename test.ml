let _ =
  let some_arg = Args.string ~name:"some" ~desc:"desc" in

  let get argv =
    let module A = Args.Of(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.get
  in
  let get_or_default argv =
    let module A = Args.Of(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.get_or_default
  in
  let require argv =
    let module A = Args.Of(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.require
  in
  let rest argv =
    let module A = Args.Of(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.rest
  in
  assert (get [] some_arg = None);
  assert (get ["-some"] some_arg = None);
  assert (get ["value"; "-some"] some_arg = None);
  assert (get ["-some"; "value"] some_arg = Some "value");
  assert (get ["-color"; "red"] (Args.enum "color" "a color" ["red"; "green"; "blue"]) = Some "red");
  assert (get_or_default [] some_arg "otherwise" = "otherwise");
  assert (get_or_default ["-some"; "value"] some_arg "otherwise" = "value");
  assert (try (ignore (require [] some_arg); false) with _ -> true);
  assert (require ["-some"; "value"] some_arg = "value");
  assert (try (ignore (get ["-num"; "not a number"] (Args.float "num" "not a number")); false) with _ -> true);
  assert (try (ignore (get ["-color"; "yellow"] (Args.enum "color" "a color" ["red"; "green"; "blue"])); false) with _ -> true);
  assert (rest ["-some"; "value"; "a"; "-and"; "thing"; "b"; "c"] () = ["a"; "b"; "c"]);
