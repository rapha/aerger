let _ =
  let some_arg = Aerger.string ~name:"some" ~desc:"desc" in

  let get argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.get
  in
  let get_or argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.get_or
  in
  let require argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.require
  in
  let rest argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.rest
  in
  assert (get [] some_arg = None);
  assert (get ["-some"] some_arg = None);
  assert (get ["value"; "-some"] some_arg = None);
  assert (get ["-some"; "value"] some_arg = Some "value");
  assert (get ["-color"; "red"] (Aerger.enum "color" "a color" ["red"; "green"; "blue"]) = Some "red");
  assert (get_or [] "otherwise" some_arg = "otherwise");
  assert (get_or ["-some"; "value"] "otherwise" some_arg = "value");
  assert (try (ignore (require [] some_arg); false) with _ -> true);
  assert (require ["-some"; "value"] some_arg = "value");
  assert (try (ignore (get ["-num"; "not a number"] (Aerger.float "num" "not a number")); false) with _ -> true);
  assert (try (ignore (get ["-color"; "yellow"] (Aerger.enum "color" "a color" ["red"; "green"; "blue"])); false) with _ -> true);
  assert (rest ["-some"; "value"; "a"; "-and"; "thing"; "b"; "c"] () = ["a"; "b"; "c"]);
