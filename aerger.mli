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
val bool : ?default:bool option -> ?desc:string -> names:string list -> bool arg
val float : ?default:float option -> ?desc:string -> names:string list -> float arg
val int : ?default:int option -> ?desc:string -> names:string list -> int arg
val string : ?default:string option -> ?desc:string -> names:string list -> string arg
val enum : ?default:string option -> ?desc:string -> names:string list -> values:string list -> string arg


(* Convenience function which handles displaying a useful message
 * if there is a problem getting the arg values. *)
val with_usage : string -> (unit -> 'a) -> 'a (* usage_string -> function_returning_arg_values -> arg values *)

(* Describes a module which extracts args from some argv. *)
module type ArgAccess = sig
  (* Returns whether an arg is present. *)
  val is_present: 'a arg -> bool

  (* Finds the value given for this arg.
   * Returns Some value if found, or the default otherwise.
   * Raises BadArgValue if there was a problem parsing the given value. *)
  val get : 'a arg -> 'a option

  (* Finds the value given for this arg.
   * If found, returns Some value
   * Otherwise if the default is not None, returns that.
   * Otherwise raises RequiredArgMissing.
   * Raises BadArgValue if there was a problem parsing the given value. *)
  val require : 'a arg -> 'a

  (* Returns all the args which do not directly follow args beginning with - *)
  val rest : unit -> string list
end

(* Use this to construct modules for your own argv. *)
module On(Argv : sig val argv : string array end) : ArgAccess

(* The included implementation uses the Sys.argv. *)
include ArgAccess
