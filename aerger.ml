open Printf

type 'a arg = { names: string list; desc: string; default: 'a option; parse_value: (string option -> 'a) }

exception RequiredArgMissing of string list (* names *)
exception BadArgValue of string option * string * string * exn (* value, name, description, exception *)

let some func = function
  | None -> invalid_arg "No value given"
  | Some value -> func value

let parse_bool = function
  | None -> true  (* The arg was present, but no value given. Consider that implicitly true. *)
  | Some "true" | Some "1" -> true
  | Some "false" | Some "0" -> false
  | Some str -> invalid_arg str

let parse_enum values = function
  | s when List.mem s values -> s
  | s -> invalid_arg s

let custom ?default ~names ~desc ~parse_value = { names; desc; default; parse_value }
let float ?default ?(desc="") ~names = custom ~names ~desc:("A float. " ^ desc) ?default ~parse_value:(some float_of_string)
let int ?default ?(desc="") ~names = custom ~names ~desc:("A int. " ^ desc) ?default ~parse_value:(some int_of_string)
let string ?default ?(desc="") ~names = custom ~names ~desc:("A string. " ^ desc) ?default ~parse_value:(some (fun s -> s))
let bool ?default ?(desc="") ~names = custom ~names
                                             ~desc:("A bool. " ^ desc)
                                             (* If a default value is not specified, an absent arg will have value false *)
                                             ~default:(match default with Some b -> b | None -> false)
                                             ~parse_value:parse_bool
let enum ?default ?(desc="") ~names ~values = custom ~names
                                                     ~desc:(sprintf "Any of {%s}. %s" (String.concat ", " values) desc)
                                                     ?default
                                                     ~parse_value:(some (parse_enum values))

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
      let given_value = match value with Some str -> sprintf "'%s'" str | None -> "<missing value>" in
      fail (sprintf
        "The value %s is invalid for arg '%s' (%s). %s.\n\nUsage: %s\n"
        given_value name desc (Printexc.to_string exc) usage)

module Parser = struct
  (* Is the name of a user arg, e.g. -c *)
  let is_name = function
    | "" | "--" -> false
    | str -> str.[0] = '-'

  (* Is a name-value pair, e.g. -c=1 *)
  let is_namevalue str = is_name str && (String.contains str '=')

  (* Is a normal value, e.g. 1 *)
  let is_value str = not (is_name str) && str <> "--"

  let split_namevalue str =
    let index = String.index str '=' in
    let name = String.sub str 0 index in
    let value = String.sub str (index + 1) (String.length str - index - 1) in
    (name, Some value)

  (* We classify elements as: a name, a value, a namevalue or '--'
   * and return a [> `NameValue of string * string option | `Value of string ] list *)
  let parse strings =
    let rec parse_rest = function
      | [] -> []
      | "--" :: rest ->
          List.map (fun str -> `Value str) rest
      | first :: rest when is_value first ->
          `Value first :: parse_rest rest
      | first :: rest when is_namevalue first ->
          `NameValue (split_namevalue first) :: parse_rest rest
      | first :: second :: rest when is_name first && is_value second ->
          `NameValue (first, Some second) :: parse_rest rest
      | first :: rest -> (* A name, not followed by a value. *)
          `NameValue (first, None) :: parse_rest rest
    in
    parse_rest strings
end

module type ArgAccess = sig
  val is_present : 'a arg -> bool
  val get : 'a arg -> 'a option
  val require : 'a arg -> 'a
  val rest : unit -> string list
end

module On(Argv : sig val argv : string array end) : ArgAccess = struct

  let parts () =
    Parser.parse (
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

  let is_present arg =
    match find arg with
    | Some _ -> true
    | None -> false

  let get arg =
    match find arg with
    | Some (name, str_opt) -> begin
        try
          Some (arg.parse_value str_opt)
        with e ->
          raise (BadArgValue (str_opt, name, arg.desc, e))
      end
    | None -> arg.default

  let require arg =
    match get arg with
    | Some value -> value
    | None -> raise (RequiredArgMissing arg.names)

end

include On(Sys)
