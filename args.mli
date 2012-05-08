(* Describes a command line arg with values of type 'a. *)
type 'a arg

(* Constructors for args of the given types. *)
val bool : name:string -> desc:string -> bool arg
val float : name:string -> desc:string -> float arg
val int : name:string -> desc:string -> int arg
val string : name:string -> desc:string -> string arg
val enum : name:string -> desc:string -> values:string list -> string arg

(* Can be any type, if you can provide a way to deserialise from string *)
val custom : name:string -> desc:string -> of_string:(string -> 'a) -> 'a arg

(* Describes a module which extracts args from some argv. *)
module type ArgsOf = sig
  exception RequiredArgMissing of string (* name *)
  exception BadArgValue of string * string * string * exn (* value, name, description, exception *)

  (* Attempts to find the value of the given arg, returning Some value if found, or None otherwise. *)
  val get : 'a arg -> 'a option

  (* Returns the value of the given arg, or a default if not found. *)
  val get_or_default : 'a -> 'a arg -> 'a

  (* Returns the value of the given arg, or raises RequiredArgMissing if not found. *)
  val require : 'a arg -> 'a

  (* Returns all the args which do not directly follow args beginning with - *)
  val rest : unit -> string list
end

(* Use this to construct modules for your own argv. *)
module Of(Argv : sig val argv : string array end) : ArgsOf

(* The included implementation uses the Sys.argv. *)
include ArgsOf
