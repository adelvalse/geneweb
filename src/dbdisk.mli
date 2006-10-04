(* $Id: dbdisk.mli,v 5.4 2006-10-03 10:27:47 ddr Exp $ *)

open Def;

type dsk_person = gen_person iper istr;
type dsk_ascend = gen_ascend ifam;
type dsk_union = gen_union ifam;
type dsk_family = gen_family iper istr;
type dsk_couple = gen_couple iper;
type dsk_descend = gen_descend iper;

type dsk_title = gen_title istr;

type rn_mode = [ RnAll | Rn1Ch | Rn1Ln ];

type notes =
  { nread : string -> rn_mode -> string;
    norigin_file : string;
    efiles : unit -> list string }
;

type record_access 'a =
  { load_array : unit -> unit;
    get : int -> 'a;
    set : int -> 'a -> unit;
    len : mutable int;
    output_array : out_channel -> unit;
    clear_array : unit -> unit }
;

type string_person_index =
  { find : istr -> list iper;
    cursor : string -> istr;
    next : istr -> istr }
;

type visible_record_access =
  { v_write : unit -> unit;
    v_get : (dsk_person -> bool) -> int -> bool }
;

type base_data =
  { persons : record_access dsk_person;
    ascends : record_access dsk_ascend;
    unions : record_access dsk_union;
    visible : visible_record_access;
    families : record_access dsk_family;
    couples : record_access dsk_couple;
    descends : record_access dsk_descend;
    strings : record_access string;
    particles : list string;
    bnotes : notes }
;

type base_func =
  { persons_of_name : string -> list iper;
    strings_of_fsname : string -> list istr;
    index_of_string : string -> istr;
    persons_of_surname : string_person_index;
    persons_of_first_name : string_person_index;
    patch_person : iper -> dsk_person -> unit;
    patch_ascend : iper -> dsk_ascend -> unit;
    patch_union : iper -> dsk_union -> unit;
    patch_family : ifam -> dsk_family -> unit;
    patch_couple : ifam -> dsk_couple -> unit;
    patch_descend : ifam -> dsk_descend -> unit;
    patch_string : istr -> string -> unit;
    patch_name : string -> iper -> unit;
    commit_patches : unit -> unit;
    commit_notes : string -> string -> unit;
    patched_ascends : unit -> list iper;
    is_patched_person : iper -> bool;
    cleanup : unit -> unit }
;

type dsk_base =
  { data : base_data;
    func : base_func }
;