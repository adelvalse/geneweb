(* camlp5r *)
(* $Id: convert.ml,v 1.00 2013/09/05 10:09:42 flh Exp $ *)

open Def;

(**/**) (* Ancien format de stockage *)


type old_gen_person 'person 'string =
  { old_first_name : 'string;
    old_surname : 'string;
    old_occ : int;
    old_image : 'string;
    old_public_name : 'string;
    old_qualifiers : list 'string;
    old_aliases : list 'string;
    old_first_names_aliases : list 'string;
    old_surnames_aliases : list 'string;
    old_titles : list (gen_title 'string);
    old_rparents : list (gen_relation 'person 'string);
    old_related : list iper;
    old_occupation : 'string;
    old_sex : sex;
    old_access : access;
    old_birth : codate;
    old_birth_place : 'string;
    old_birth_src : 'string;
    old_baptism : codate;
    old_baptism_place : 'string;
    old_baptism_src : 'string;
    old_death : death;
    old_death_place : 'string;
    old_death_src : 'string;
    old_burial : burial;
    old_burial_place : 'string;
    old_burial_src : 'string;
    old_notes : 'string;
    old_psources : 'string;
    old_key_index : iper }
;

type old_gen_family 'person 'string =
  { old_marriage : codate;
    old_marriage_place : 'string;
    old_marriage_src : 'string;
    old_witnesses : array 'person;
    old_relation : relation_kind;
    old_divorce : divorce;
    old_comment : 'string;
    old_origin_file : 'string;
    old_fsources : 'string;
    old_fam_index : ifam }
;


type old_gen_record = 
  { old_date : string;
    old_wizard : string;
    old_gen_p : old_gen_person iper string;
    old_gen_f : list (old_gen_family iper string);
    old_gen_c : list (array iper) }
;

type gen_record = 
  { date : string;
    wizard : string;
    gen_p : gen_person iper string;
    gen_f : list (gen_family iper string);
    gen_c : list (array iper) }
;


(* Fonction de conversion *)

value load_old_person_history fname = do {
  let history = ref [] in
  match try Some (Secure.open_in_bin fname) with [ Sys_error _ -> None ] with
  [ Some ic ->
      do {
        try 
          while True do {
            let v : old_gen_record = input_value ic in
            history.val := [v :: history.val]
          }
        with [ End_of_file -> () ];
        close_in ic
      }
  | None -> () ];
  (* On retourne la liste car les dernières  *)
  (* entrées se retrouvent en tête de liste. *)
  List.rev history.val
};

value convert_file file tmp_file =
  let old_history = load_old_person_history file in
  let new_history =
    List.map
      (fun old_gr ->
         let old_gen_p = old_gr.old_gen_p in
         let gen_p = 
           {first_name = old_gen_p.old_first_name; 
            surname = old_gen_p.old_surname; 
            occ = old_gen_p.old_occ; image = old_gen_p.old_image; 
            first_names_aliases = old_gen_p.old_first_names_aliases; 
            surnames_aliases = old_gen_p.old_surnames_aliases;
            public_name = old_gen_p.old_public_name; 
            qualifiers = old_gen_p.old_qualifiers; 
            titles = old_gen_p.old_titles; rparents = old_gen_p.old_rparents;
            related = old_gen_p.old_related; aliases = old_gen_p.old_aliases; 
            occupation = old_gen_p.old_occupation; sex = old_gen_p.old_sex; 
            access = old_gen_p.old_access; birth = old_gen_p.old_birth; 
            birth_place = old_gen_p.old_birth_place; birth_note = ""; 
            birth_src = old_gen_p.old_birth_src; 
            baptism = old_gen_p.old_baptism; 
            baptism_place = old_gen_p.old_baptism_place; 
            baptism_note = ""; baptism_src = old_gen_p.old_baptism_src; 
            death = old_gen_p.old_death; 
            death_place = old_gen_p.old_death_place; 
            death_note = ""; death_src = old_gen_p.old_death_src; 
            burial = old_gen_p.old_burial; 
            burial_place = old_gen_p.old_burial_place; 
            burial_note = ""; burial_src = old_gen_p.old_burial_src; 
            pevents = []; notes = old_gen_p.old_notes; 
            psources = old_gen_p.old_psources; 
            key_index = old_gen_p.old_key_index}
         in
         let gen_f =
           List.map
             (fun old_gen_f ->
                {marriage = old_gen_f.old_marriage; 
                 marriage_place = old_gen_f.old_marriage_place;
                 marriage_note = ""; marriage_src = old_gen_f.old_marriage_src;
                 relation = old_gen_f.old_relation; 
                 divorce = old_gen_f.old_divorce; fevents = []; 
                 witnesses = old_gen_f.old_witnesses; 
                 comment = old_gen_f.old_comment; 
                 origin_file = old_gen_f.old_origin_file; 
                 fsources = old_gen_f.old_fsources;
                 fam_index = old_gen_f.old_fam_index} )
             old_gr.old_gen_f
         in
         {date = old_gr.old_date; wizard = old_gr.old_wizard;
          gen_p = gen_p; gen_f = gen_f; gen_c = old_gr.old_gen_c } )
      old_history
  in
  let ext_flags = 
    [Open_wronly; Open_append; Open_creat; Open_binary; Open_nonblock]
  in
  match 
    try Some (Secure.open_out_gen ext_flags 0o644 tmp_file) 
    with [ Sys_error _ -> None ]
  with
  [ Some oc -> 
      do {
        List.iter (fun gr -> output_value oc (gr : gen_record)) new_history;
        close_out oc
      }
  | None -> () ]
;

value convert history_dir =
  (* Récupère tous les fichiers et dossier d'un dossier et   *)
  (* renvoie la liste des dossiers et la liste des fichiers. *)
  let read_files_folders fname =
    let list = 
      List.map 
        (fun file -> Filename.concat fname file)
        (Array.to_list (Sys.readdir fname)) 
    in
    List.partition Sys.is_directory list
  in
  (* Parcours récursif de tous les dossiers *)
  let rec loop l folders files =
    match l with
    [ [] -> (folders, files)
    | [x :: l] ->
        let (fd, fi) = read_files_folders x in
        let l = List.rev_append l fd in
        let folders = List.rev_append fd folders in
        let files = List.rev_append fi files in
        loop l folders files ]
  in
  (* Toute l'arborescence du dossier history_d *)
  let (folders, files) = loop [history_dir] [] [] in
  let len = List.length files in
  do {
    ProgrBar.start ();
    loop 0 files where rec loop i files =
      match files with
      [ [] -> ()
      | [file :: l] ->
         do {
           let tmp_file = file ^ ".new" in
           convert_file file tmp_file;
           try Sys.rename file (file ^ "~") with [ Sys_error _ -> () ];
           try Sys.rename tmp_file file with [ Sys_error _ -> () ];
           ProgrBar.run i len;
           loop (i + 1) l
         } ];
    ProgrBar.finish ();
  }
;



(**/**) (* main *)

value history_dir = ref "";

value speclist = []; 
value anonfun n = history_dir.val := n;
value usage = "Usage: convert_hist history_dir (the history_d folder)";


value main () = do {
  
  Arg.parse speclist anonfun usage;
  if history_dir.val = "" then do { Arg.usage speclist usage; exit 2; } else ();
  convert history_dir.val;
};

main ();
