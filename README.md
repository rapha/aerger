A little library for parsing command-line args.

    let _ =
      let awesomeness, colour, speed = Aerger.(
        require (float "awesomeness" ~desc:"How awesome to be."),
        get_or "RED" (enum ~name:"colour" ~desc:"A primary colour." ~values:["RED"; "GREEN"; "BLUE"]),
        match get (bool "go_faster" "Whether to go faster.") with Some true -> "fast" | Some false -> "slow" | None -> "?"
      ) in
      Printf.printf "speed: %s\nawesomeness: %f\ncolour: %s\n" speed awesomeness colour;
      List.iter print_endline (Aerger.rest ())
