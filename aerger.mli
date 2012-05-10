(* Describes a command line arg with values of type 'a. *)
type 'a arg

exception RequiredArgMissing of string list (* name *)
exception BadArgValue of string * string * string * exn (* value, name, description, exception *)

(* Constructors for args of the given types. *)
val bool : ?desc:string -> names:string list -> bool arg
val float : ?desc:string -> names:string list -> float arg
val int : ?desc:string -> names:string list -> int arg
val string : ?desc:string -> names:string list -> string arg
val enum : ?desc:string -> names:string list -> values:string list -> string arg

(* Can be any type, if you can provide a way to deserialise from string *)
val custom : ?desc:string -> names:string list -> of_string:(string -> 'a) -> 'a arg

(* Describes a module which extracts args from some argv. *)
module type ArgAccess = sig
  (* Attempts to find the value of the given arg, returning Some value if found, or None otherwise. *)
  val get : 'a arg -> 'a option

  (* Returns the value of the given arg, or a default if not found. *)
  val get_or : 'a -> 'a arg -> 'a

  (* Returns the value of the given arg, or raises RequiredArgMissing if not found. *)
  val require : 'a arg -> 'a

  (* Returns whether a value was given for the given arg. *)
  val is_given: 'a arg -> bool

  (* Returns all the args which do not directly follow args beginning with - *)
  val rest : unit -> string list

  (* Convenience function which handles displaying a useful message
   * if there is a problem extracting the arg values. *)
  val with_usage : string -> (unit -> 'a) -> 'a (* usage_string -> function_returning_arg_values -> arg values *)
end

(* Use this to construct modules for your own argv. *)
module On(Argv : sig val argv : string array end) : ArgAccess

(* The included implementation uses the Sys.argv. *)
include ArgAccess
