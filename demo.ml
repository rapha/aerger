let _ =
  let awesomeness, colour, speed = Aerger.(
    require (float ~name:"awesomeness" ~desc:"How awesome to be."),
    get_or_default "RED" (enum ~name:"colour" ~desc:"A primary colour." ~values:["RED"; "GREEN"; "BLUE"]),
    match get (bool "go_faster" "Whether to go faster") with Some true -> "quickly" | Some false -> "slowly" | None -> "?"
  ) in
  Printf.printf "speed: %s\nawesomeness: %f\ncolour: %s\n" speed awesomeness colour;
  List.iter print_endline (Aerger.rest ())
