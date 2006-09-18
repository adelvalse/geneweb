(* $Id: gwdb.ml,v 5.1 2006-09-18 12:45:28 ddr Exp $ *)
(* Copyright (c) 1998-2006 INRIA *)

open Adef;

type db_person 'person 'string = Def.gen_person 'person 'string;

type person = db_person iper istr;
type ascend = Def.gen_ascend ifam;
type union = Def.gen_union ifam;

type family = Def.gen_family iper istr;
type couple = Def.gen_couple iper;
type descend = Def.gen_descend iper;

type relation = Def.gen_relation iper istr;
type title = Def.gen_title istr;

type rn_mode = [ RnAll | Rn1Ch | Rn1Ln ];

type notes =
  { nread : string -> rn_mode -> string;
    norigin_file : string;
    efiles : unit -> list string }
;

type cache 'a =
  { array : unit -> array 'a;
    get : int -> 'a;
    len : mutable int;
    clear_array : unit -> unit }
;

type istr_iper_index =
  { find : istr -> list iper;
    cursor : string -> istr;
    next : istr -> istr }
;

type visible_cache =
  { v_write : unit -> unit;
    v_get : (person -> bool) -> int -> bool }
;

type base_data =
  { persons : cache person;
    ascends : cache ascend;
    unions : cache union;
    visible : visible_cache;
    families : cache family;
    couples : cache couple;
    descends : cache descend;
    strings : cache string;
    particles : list string;
    bnotes : notes }
;

type base_func =
  { persons_of_name : string -> list iper;
    strings_of_fsname : string -> list istr;
    index_of_string : string -> istr;
    persons_of_surname : istr_iper_index;
    persons_of_first_name : istr_iper_index;
    patch_person : iper -> person -> unit;
    patch_ascend : iper -> ascend -> unit;
    patch_union : iper -> union -> unit;
    patch_family : ifam -> family -> unit;
    patch_couple : ifam -> couple -> unit;
    patch_descend : ifam -> descend -> unit;
    patch_string : istr -> string -> unit;
    patch_name : string -> iper -> unit;
    commit_patches : unit -> unit;
    commit_notes : string -> string -> unit;
    patched_ascends : unit -> list iper;
    is_patched_person : iper -> bool;
    cleanup : unit -> unit }
;

type base =
  { data : base_data;
    func : base_func }
;

value get_aliases p = p.Def.aliases;
value get_baptism p = p.Def.baptism;
value get_birth p = p.Def.birth;
value get_cle_index p = p.Def.cle_index;
value get_death p = p.Def.death;
value get_first_name p = p.Def.first_name;
value get_first_names_aliases p = p.Def.first_names_aliases;
value get_occ p = p.Def.occ;
value get_public_name p = p.Def.public_name;
value get_qualifiers p = p.Def.qualifiers;
value get_related p = p.Def.related;
value get_rparents p = p.Def.rparents;
value get_sex p = p.Def.sex;
value get_surname p = p.Def.surname;
value get_surnames_aliases p = p.Def.surnames_aliases;
value get_titles p = p.Def.titles;

value person_of_gen_person p = p;
value gen_person_of_person p = p;
