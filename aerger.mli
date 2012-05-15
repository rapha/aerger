(* Describes a command line arg with values of type 'a. *)
type 'a arg

exception RequiredArgMissing of string list (* names *)
exception BadArgValue of string option * string * string * exn (* value, name, description, exception *)

(* Arg constructors. *)
val custom :
  names:string list ->  (* The names of the arg, e.g. ["c"; "color"] to match -c and -color. *)
  desc:string ->  (* A description of the arg for the user. *)
  default:'a option ->  (* An optional default value to use if the arg is not present. *)
  parse_value:(string option -> 'a) -> 'a arg  (* A function to convert the value given to the right type. There may be no value given. *)

(* Common arg types *)
val bool : ?default:bool -> ?desc:string -> names:string list -> bool arg
val float : ?default:float -> ?desc:string -> names:string list -> float arg
val int : ?default:int -> ?desc:string -> names:string list -> int arg
val string : ?default:string -> ?desc:string -> names:string list -> string arg
val enum : ?default:string -> ?desc:string -> names:string list -> values:string list -> string arg


(* Convenience function which handles displaying a useful message
 * if there is a problem getting the arg values. *)
val with_usage : string -> (unit -> 'a) -> 'a (* usage_string -> function_returning_arg_values -> arg values *)


(* Describes a module which extracts args from some argv. *)
module type ArgAccess = sig
  (* Returns whether an arg is present. *)
  val is_present: 'a arg -> bool

  (* Returns Some value for the given arg (if present), or Some default (if specified), or None.
   * Raises BadArgValue if there was a problem parsing the given value. *)
  val get : 'a arg -> 'a option

  (* Returns Some value for the given arg (if present), or Some default (if specified), or raises RequiredArgMissing.
   * Raises BadArgValue if there was a problem parsing the given value. *)
  val require : 'a arg -> 'a

  (* Returns all the element which are not values of some arg. *)
  val rest : unit -> string list
end

(* Use this to construct modules for your own argv. *)
module On(Argv : sig val argv : string array end) : ArgAccess

(* The included implementation uses the Sys.argv. *)
include ArgAccess
