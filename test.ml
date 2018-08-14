open Lwt
open LTerm_widget
open LTerm_text


let get_time () =
  let localtime = Unix.localtime (Unix.time ()) in
  Printf.sprintf "%02u:%02u:%02u"
    localtime.Unix.tm_hour
    localtime.Unix.tm_min
    localtime.Unix.tm_sec


class mmouse initial_text = object(self)
 inherit label "mmouse"

  method! draw ctx _focused =
    LTerm_draw.draw_string ctx 3 3 "MY MOUSE WIDGET"


end

let main () =
  let waiter, wakener = wait () in

  let vbox = new LTerm_widget.vbox in
  
  let clock = new LTerm_widget.label (get_time ()) in
  vbox#add clock;
  
  let aButton = new LTerm_widget.button "aButton" in
  vbox#add aButton;

  let exitButton = new LTerm_widget.button "exit" in
  vbox#add exitButton; 

  let mmouseWidget = new mmouse "mmouseWidget" in
  vbox#add mmouseWidget;

  (* Update the time every second. *)
  ignore (Lwt_engine.on_timer 1.0 true (fun _ -> clock#set_text (get_time ())));

  (* Quit when the exit button is clicked. *)
  exitButton#on_click (wakeup wakener);
 
  aButton#on_click (fun _ -> clock#set_text ("Button clicked."));

  let frame = new frame in 
  frame#set vbox;
  frame#set_label ~alignment:LTerm_geom.H_align_center "This is a frame"; 

  Lazy.force LTerm.stdout 
  >>= fun term -> 
  LTerm.enable_mouse term 
  >>= fun () ->

  let draw ui matrix =
    let ctx = LTerm_draw.context matrix (LTerm_ui.size ui) in
    LTerm_draw.clear ctx;
    (* LTerm_draw.draw_styled ctx 5 5 (eval [B_fg LTerm_style.lblue; S"Mouse"; E_fg]) *)
  in
  LTerm_ui.create term draw 
  >>= fun ui -> 
  Lwt.finalize 
    (fun () -> run term frame waiter)  
    (fun () -> LTerm.disable_mouse term) 
    (fun () -> LTerm_ui.quit ui)

let () = Lwt_main.run (main ()) 

