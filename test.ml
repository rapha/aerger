let _ =
  let some_arg = Aerger.string ~names:["some"] ~desc:"desc" in

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
  let is_given argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.is_given
  in
  assert (get [] some_arg = None);
  assert (get ["-some"] some_arg = None);
  assert (get ["value"; "-some"] some_arg = None);
  assert (get ["-some"; "value"] some_arg = Some "value");
  assert (get ["--some"; "value"] some_arg = Some "value");
  assert (get ["--some=value"] some_arg = Some "value");
  assert (get ["-color"; "red"] (Aerger.enum ["color"] ["red"; "green"; "blue"]) = Some "red");
  assert (get ["-run"; "0"] (Aerger.bool ["run"]) = Some false);
  assert (get_or [] "otherwise" some_arg = "otherwise");
  assert (get_or ["-some"; "value"] "otherwise" some_arg = "value");
  assert (
    try let _ = require [] some_arg in false
    with Aerger.RequiredArgMissing ["some"] -> true);
  assert (require ["-some"; "value"] some_arg = "value");
  assert (
    try let _ = get ["-num"; "not a number"] (Aerger.float ["num"]) in false
    with Aerger.BadArgValue ("not a number", "-num", "A float. ", Failure "float_of_string") -> true);
  assert (
    try let _ = get ["-color"; "yellow"] (Aerger.enum ["color"] ["red"; "green"; "blue"]) in false
    with Aerger.BadArgValue ("yellow", "-color", "Any of {red, green, blue}. ", Invalid_argument "yellow") -> true);
  assert (rest ["-some"; "value"; "a"; "--and"; "thing"; "b"; "c"; "-also"; "--"; "-d"; "e"] () = ["a"; "b"; "c"; "-d"; "e"]);
  assert (is_given [] some_arg = false);
  assert (is_given ["-some"] some_arg = false);
  assert (is_given ["-some"; "value"] some_arg = true);
