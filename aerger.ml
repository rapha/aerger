open Printf

type 'a arg = { names: string list; desc: string; of_string: (string -> 'a) }

exception RequiredArgMissing of string list (* names *)
exception BadArgValue of string * string * string * exn (* value, name, description, exception *)

(* Allow the user to provide "0", "1", "false" or "true" as valid values. *)
let parse_bool str =
  try bool_of_string str
  with Invalid_argument _ -> begin
    match try int_of_string str with Failure _ -> invalid_arg str with
    | 0 -> false
    | 1 -> true
    | _ -> invalid_arg str
  end

let custom ?(desc="") ~names ~of_string = { names; desc; of_string }
let bool ?(desc="") ~names = custom ~names ~desc:("A bool. " ^ desc) ~of_string:parse_bool
let float ?(desc="") ~names = custom ~names ~desc:("A float. " ^ desc) ~of_string:float_of_string
let int ?(desc="") ~names = custom ~names ~desc:("A int. " ^ desc) ~of_string:int_of_string
let string ?(desc="") ~names = custom ~names ~desc:("A string. " ^ desc) ~of_string:(fun s -> s)
let enum ?(desc="") ~names ~values = custom ~desc:(Printf.sprintf "Any of {%s}. %s" (String.concat ", " values) desc)
                                           ~names
                                           ~of_string:(fun s -> if List.mem s values then s else invalid_arg s)

module type ArgAccess = sig
  val get : 'a arg -> 'a option
  val get_or : 'a -> 'a arg -> 'a
  val require : 'a arg -> 'a
  val is_given : 'a arg -> bool
  val rest : unit -> string list
  val with_usage : string -> (unit -> 'a) -> 'a
end

module On(Argv : sig val argv : string array end) : ArgAccess = struct
  (* The user may want to do dirty things to argv, like mutate it, so we re-evaluate each time. *)
  let arg_list () =
    (* Argv always begins with the name of the executable, which we want to exclude. *)
    List.tl (Array.to_list Argv.argv)

  let find_given_value arg =
    (* TODO:
      * implement --name=value
      * raise error if the same arg is given more than once?
      *)
    let flags = List.map ((^) "-") arg.names @ List.map ((^) "--") arg.names in
    let rec find_value_in = function
      | [] | [_] -> None
      | name :: value :: _ when List.mem name flags -> Some (name, value)
      | _ :: rest -> find_value_in rest
    in
    find_value_in (arg_list ())

  let get arg =
    match find_given_value arg with
    | Some (name, str) -> begin
        try Some (arg.of_string str)
        with e -> raise (BadArgValue (str, name, arg.desc, e))
      end
    | None -> None

  let get_or default arg =
    match get arg with
    | Some value -> value
    | None -> default

  let require arg =
    match get arg with
    | Some value -> value
    | None -> raise (RequiredArgMissing arg.names)

  let is_given arg =
    match get arg with
    | Some _ -> true
    | None -> false

  let rest () =
    (* TODO: implement -- -a -b *)
    let is_flag = function "" -> false | str -> str.[0] = '-' in
    let rec find_unflagged_in = function
      | [] -> []
      | first :: [] when is_flag first -> []
      | first :: _ :: rest when is_flag first -> find_unflagged_in rest
      | first :: rest -> first :: find_unflagged_in rest
    in
    find_unflagged_in (arg_list ())

  let with_usage usage get_args =
    let fail str =
      prerr_string str;
      exit 1
    in
    let usage = sprintf "%s %s" Argv.argv.(0) usage in
    try
      get_args ()
    with
    | RequiredArgMissing names ->
        fail (sprintf "The arg %s is required.\n\nUsage: %s\n" (String.concat " or " names) usage)
    | BadArgValue (value, name, desc, exc) ->
        fail (sprintf
          "The value '%s' is invalid for arg '%s' (%s). %s.\n\nUsage: %s\n"
          value name desc (Printexc.to_string exc) usage)
end

include On(Sys)
