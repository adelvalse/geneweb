(* camlp4r ./pa_lock.cmo *)
(* $Id: mk_consang.ml,v 2.9 1999-10-06 08:47:56 ddr Exp $ *)
(* Copyright (c) 1999 INRIA *)

value fname = ref "";
value scratch = ref False;
value quiet = ref False;

value usage = "usage: " ^ Sys.argv.(0) ^ " [options] <file_name>";
value speclist =
  [("-q", Arg.Set quiet, ": quiet mode");
   ("-scratch", Arg.Set scratch, ": from scratch");
   ("-mem", Arg.Set Iobase.save_mem,
    ": Save memory, but slower when rewritting data base");
   ("-nolock", Arg.Set Lock.no_lock_flag, ": do not lock data base.")]
;

value main () =
  do Argl.parse speclist (fun s -> fname.val := s) usage;
     if fname.val = "" then
       do Printf.eprintf "Missing file name\n";
          Printf.eprintf "Use option -help for usage\n";
          flush stderr;
       return ()
     else ();
  return
  let f () =
    let base = Iobase.input fname.val in
    try
      do Sys.catch_break True;
         try ConsangAll.compute base scratch.val quiet.val with
         [ Sys.Break -> do Printf.eprintf "\n"; flush stderr; return () ];
         Iobase.simple_output fname.val base;
      return ()
    with
    [ Consang.TopologicalSortError ->
        do Printf.printf "
Error: probable loop in database (persons being their own ancestors).\n";
           flush stdout;
        return exit 2 ]
  in
  lock (Iobase.lock_file fname.val) with
  [ Accept -> f ()
  | Refuse ->
      do Printf.eprintf "Base is locked. Waiting... ";
         flush stderr;
      return
      lock_wait (Iobase.lock_file fname.val) with
      [ Accept ->
          do Printf.eprintf "Ok\n";
             flush stderr;
          return f ()
      | Refuse ->
          do Printf.printf "\nSorry. Impossible to lock base.\n";
             flush stdout;
          return exit 2 ] ]
;

Printexc.catch main ();
