A little library for parsing command-line args.

    let awesomeness, speed, color = Aerger.(
      with_usage "demo --awesomeness=99 --go_faster 1 -c BLUE" (fun _ ->
        require (float ["awesomeness"]),
        (match get (bool ["go_faster"]) with Some true -> "fast" | Some false -> "slow" | None -> "unspecified"),
        get_or "RED" (enum ~names:["c"; "color"] ~desc:"A primary color." ~values:["RED"; "GREEN"; "BLUE"])
      )
    ) in

    Printf.printf "speed: %s\nawesomeness: %f\ncolour: %s\n" speed awesomeness color;
    List.iter print_endline (Aerger.rest ())
