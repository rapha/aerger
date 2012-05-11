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
let enum ?(desc="") ~names ~values = custom ~desc:(sprintf "Any of {%s}. %s" (String.concat ", " values) desc)
                                            ~names
                                            ~of_string:(fun s -> if List.mem s values then s else invalid_arg s)

let with_usage usage get_args =
  let fail str =
    prerr_string str;
    exit 1
  in
  try
    get_args ()
  with
  | RequiredArgMissing names ->
      fail (sprintf "The arg %s is required.\n\nUsage: %s\n" (String.concat " or " names) usage)
  | BadArgValue (value, name, desc, exc) ->
      fail (sprintf
        "The value '%s' is invalid for arg '%s' (%s). %s.\n\nUsage: %s\n"
        value name desc (Printexc.to_string exc) usage)

(* We classify elements as either a name, a value or '--'
 * and return a list of [ `NameValue | `Value ]'s *)
let parse strings =
  (* TODO: implement --name=value *)
  let is_name = function "" | "--" -> false | str -> str.[0] = '-' in
  let is_value str = not (is_name str) && str <> "--" in
  let rec parse_rest = function
    | [] -> []
    | "--" :: rest ->
        List.map (fun str -> `Value str) rest
    | first :: rest when is_value first ->
        `Value first :: parse_rest rest
    | first :: second :: rest when is_name first && is_value second ->
        `NameValue (first, second) :: parse_rest rest
    | first :: rest -> (* first must be a name not followed by a value, so we drop it. *)
        parse_rest rest
  in
  parse_rest strings

module type ArgAccess = sig
  val get : 'a arg -> 'a option
  val get_or : 'a -> 'a arg -> 'a
  val require : 'a arg -> 'a
  val is_given : 'a arg -> bool
  val rest : unit -> string list
end

module On(Argv : sig val argv : string array end) : ArgAccess = struct

  let parts () =
    parse (
      (* Argv always begins with the name of the executable, which we want to exclude. *)
      List.tl (
        (* The user may want to do dirty things to argv, so we re-evaluate each time. *)
        Array.to_list Argv.argv))

  let rest () =
    let rec values_in = function
      | [] -> []
      | `NameValue _ :: tail -> values_in tail
      | `Value str :: tail -> str :: values_in tail
    in
    values_in (parts ())

  let find arg =
    (* TODO: raise error if the same arg is given more than once? *)
    let names = List.map ((^) "-") arg.names @ List.map ((^) "--") arg.names in
    let rec find_in = function
      | [] -> None
      | `NameValue (name, value) :: _ when List.mem name names -> Some (name, value)
      | `NameValue _ :: tail | `Value _ :: tail -> find_in tail
    in
    find_in (parts ())

  let get arg =
    match find arg with
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

end

include On(Sys)
