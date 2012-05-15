let _ =
  let some_arg = Aerger.string ~names:["some"] ~desc:"desc" ~default:None in

  let get argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.get
  in
  let require argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.require
  in
  let rest argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.rest
  in
  let is_present argv =
    let module A = Aerger.On(struct let argv = (Array.of_list ("cmd" :: argv)) end) in A.is_present
  in
  assert (get [] some_arg = None);
  assert (get ["-some"; "value"] some_arg = Some "value");
  assert (get ["--some"; "value"] some_arg = Some "value");
  assert (get ["--some=value"] some_arg = Some "value");
  assert (get ["-color"; "red"] (Aerger.enum ["color"] ["red"; "green"; "blue"]) = Some "red");
  assert (get ["-run"; "0"] (Aerger.bool ["run"]) = Some false);
  assert (get [] (Aerger.string ~default:(Some "otherwise") ~names:["some"] ~desc:"desc") = Some "otherwise");
  assert (get ["-some"; "value"] (Aerger.string ~default:(Some "thing") ~names:["some"] ~desc:"desc") = Some "value");
  assert (require ["-some"; "value"] some_arg = "value");
  assert (
    try let _ = require [] some_arg in false
    with Aerger.RequiredArgMissing ["some"] -> true);
  assert (
    try let _ = get ["-some"] some_arg in false
    with Aerger.BadArgValue (None, "-some", "A string. desc", Invalid_argument("No value given")) -> true);
  assert (
    try let _ = get ["-num"; "not a number"] (Aerger.float ["num"]) in false
    with Aerger.BadArgValue (Some "not a number", "-num", "A float. ", Failure "float_of_string") -> true);
  assert (
    try let _ = get ["-color"; "yellow"] (Aerger.enum ["color"] ["red"; "green"; "blue"]) in false
    with Aerger.BadArgValue (Some "yellow", "-color", "Any of {red, green, blue}. ", Invalid_argument "yellow") -> true);
  assert (rest ["-some"; "value"; "a"; "--and"; "thing"; "b"; "c"; "-also"; "--"; "-d"; "e"] () = ["a"; "b"; "c"; "-d"; "e"]);
  assert (is_present [] some_arg = false);
  assert (is_present ["-some"] some_arg = true);
  assert (is_present ["-some"; "value"] some_arg = true);
