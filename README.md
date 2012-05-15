A little library for parsing command-line args.

    let awesomeness, is_fast, color = Aerger.(
      with_usage "demo --awesomeness=99 -c BLUE --go_faster" (fun _ ->
        require (float ["awesomeness"]),
        require (bool ["go_faster"]),
        match get (enum ~names:["c"; "color"] ~desc:"A primary color." ~values:["RED"; "GREEN"; "BLUE"] ~default:None) with
        | Some color -> color
        | None -> "WHITE"
      )
    ) in

    Printf.printf "fast? %b\nawesomeness: %f\ncolor: %s\n" is_fast awesomeness color;
    List.iter print_endline (Aerger.rest ())
