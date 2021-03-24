(* This file is part of Dream, released under the MIT license. See
   LICENSE.md for details, or visit https://github.com/aantron/dream.

   Copyright 2021 Anton Bachin *)



module Dream = Dream__pure.Inmost



(* TODO This belongs in the core module. *)
let add_header response buffered_body =
  let length =
    match buffered_body with
    | `Empty -> 0
    | `String body -> String.length body
  in
  Lwt.return
    (Dream.add_header "Content-Length" (string_of_int length) response)

(* Add a Content-Length header to HTTP 1.x responses that have a fixed body but
   don't yet have the header. *)
let content_length next_handler request =
  let open Lwt.Infix in

  if fst (Dream.version request) <> 1 then
    next_handler request

  else
    next_handler request
    >>= fun response ->

    if Dream.has_header "Content-Length" response then
      Lwt.return response

    else
      (* TODO This check belongs in the core module. *)
      match !(response.body) with
      | `Empty | `String _ as buffered_body ->
        add_header response buffered_body
      | _ ->
        Lwt.return response