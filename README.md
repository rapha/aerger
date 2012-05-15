A little library for parsing command-line args.

    let awesomeness, is_fast, color = Aerger.(
      with_usage "demo --awesomeness=99 -c BLUE --go_faster" (fun _ ->
        require (float ~names:["awesomeness"] ~desc:"How awesome to be" ~default:(Some 11.)),
        require (bool ["go_faster"]),
        match get (enum ["c"; "color"] ["RED"; "GREEN"; "BLUE"]) with | Some color -> color | None -> "unspecified"
      )
    ) in

    Printf.printf "fast? %b\nawesomeness: %f\ncolor: %s\n" is_fast awesomeness color;
    List.iter print_endline (Aerger.rest ())
