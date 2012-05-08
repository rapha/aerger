type 'a arg = { name: string; desc: string; of_string: (string -> 'a) }

let custom ~name ~desc ~of_string = { name; desc; of_string }
(* TODO: Allow 1 and 0 for boolean args. *)
let bool ~name ~desc = custom ~name ~desc:("A bool: " ^ desc) ~of_string:bool_of_string
let float ~name ~desc = custom ~name ~desc:("A float: " ^ desc) ~of_string:float_of_string
let int ~name ~desc = custom ~name ~desc:("A int: " ^ desc) ~of_string:int_of_string
let string ~name ~desc = custom ~name ~desc:("A string: " ^ desc) ~of_string:(fun s -> s)
let enum ~name ~desc ~values = custom ~name
                                      ~desc:(Printf.sprintf "Any of {%s}: %s" (String.concat ", " values) desc)
                                      ~of_string:(fun s -> if List.mem s values then s else invalid_arg s)

module type ArgsOf = sig
  exception RequiredArgMissing of string (* name, description *)
  exception BadArgValue of string * string * string * exn (* value, name, description, exception *)

  val get : 'a arg -> 'a option
  val get_or : 'a -> 'a arg -> 'a
  val require : 'a arg -> 'a

  val rest : unit -> string list
end

module Of(Argv : sig val argv : string array end) : ArgsOf = struct
  exception RequiredArgMissing of string
  exception BadArgValue of string * string * string * exn

  (* The user may need to mutate argv, so we re-evaluate each time. *)
  let arg_list () =
    (* Argv always begins with the name of the executable, which we want to exclude. *)
    List.tl (Array.to_list Argv.argv)

  let find_given_value spec =
    (* TODO: implement
      * --name value
      * -name=value
    *)
    let flag = "-" ^ (spec.name) in
    let rec find_value_in = function
      | [] | [_] -> None
      | name :: value :: _ when name = flag -> Some value
      | _ :: rest -> find_value_in rest
    in
    find_value_in (arg_list ())

  let get spec =
    match find_given_value spec with
    | Some str -> begin
        try Some (spec.of_string str)
        with e -> raise (BadArgValue (str, spec.name, spec.desc, e))
      end
    | None -> None

  let get_or default spec =
    match get spec with
    | Some value -> value
    | None -> default

  let require spec =
    match get spec with
    | Some value -> value
    | None -> raise (RequiredArgMissing spec.name)

  let rest () =
    (* TODO: Implement -- -a -b *)
    let is_flag = function "" -> false | str -> str.[0] = '-' in
    let rec find_unflagged_in = function
      | [] -> []
      | first :: [] when is_flag first -> []
      | first :: _ :: rest when is_flag first -> find_unflagged_in rest
      | first :: rest -> first :: find_unflagged_in rest
    in
    find_unflagged_in (arg_list ())

end

include Of(Sys)
