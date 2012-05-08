open Printf

let _ =
  let go_faster = Args.bool ~name:"go_faster" ~desc:"Whether to go faster." in
  let awesomeness =  Args.float ~name:"awesomeness" ~desc:"How awesome to be." in
  let colour = Args.enum ~name:"colour" ~desc:"A primary colour." ~values:["RED"; "GREEN"; "BLUE"] in

  let module Args = Args.Of(Sys) in

  print_endline begin
    match Args.get go_faster with
    | Some true -> "quickly"
    | Some false -> "slowly"
    | None -> "?"
  end;

  Printf.printf "awesomeness: %f\n" (Args.require awesomeness);
  Printf.printf "colour: %s\n" (Args.require colour);
  List.iter print_endline (Args.rest ())