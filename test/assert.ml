(* 
  Utility methods built so I can get verifications in a 
  'Expected %s but result %s' format. These are heavily based off of Java's
  JUnit library, specifically the Assert class. 
  @author: Ben Jenkins 
*)


(* Useful toggle for debugging if tests aren't working as expected. *)
let print_true_conditions : bool = false ;;
let red_text_code : string = "\027[31m" ;;

let string_of_list (string_of_a : 'a -> string) (lst : 'a list) : string =
  let str_lst = List.map string_of_a lst in
  "[" ^ (String.concat "; " str_lst) ^ "]" ;;


let assert_strings (condition : bool)
                   (test_name : string)
                   (expected : string)
                   (result : string)
                  : 'a =
  (* Turns text red in linux terminal. *)
  if not condition then (
    Printf.fprintf stdout 
      "%sTest '%s' failed. Expected: '%s', but actual: '%s'\n" 
      red_text_code test_name expected result ;
      assert condition 
      )
  else if print_true_conditions then (
    Printf.fprintf stdout 
      "Test '%s' passed. Value: '%s'\n" test_name expected ;
      assert condition 
    )
      
;;


let assert_cmp (test_name : string)
                (cmp : 'a -> 'a -> bool)
                (string_of_a : 'a -> string)
                (expected : 'a)
                (result : 'a)
              : 'b =
  let condition = cmp expected result in
  let expected_display = string_of_a expected in
  let result_display = string_of_a result in
  assert_strings condition test_name expected_display result_display ;;


(* Asserts that two objects are equal. *)
let assert_equals (test_name : string)
                (string_of_a : 'a -> string)
                (expected : 'a)
                (result : 'a)
              : 'b =
  assert_cmp test_name (=) string_of_a expected result ;;

let assert_equals_int (test_name : string) 
                      (expected : int) 
                      (result : int)
                    : 'a =
  assert_equals test_name string_of_int expected result ;;

let assert_equals_int_list (test_name : string) 
                      (expected : int list) 
                      (result : int list)
                    : 'a =
  assert_equals test_name (string_of_list string_of_int) expected result ;;  

let assert_equals_char (test_name : string) 
                       (expected : char) 
                       (result : char) 
                     : 'a =
  let string_of_char = fun my_char -> String.make 1 my_char in
  assert_equals test_name string_of_char expected result ;;  

let assert_equals_char_list (test_name : string) 
                      (expected : char list) 
                      (result : char list)
                    : 'a =
  let string_of_char = fun my_char -> String.make 1 my_char in                  
  assert_equals test_name (string_of_list string_of_char) expected result ;;

let assert_equals_bool (test_name : string) 
                       (expected : bool) 
                       (result : bool) 
                     : 'a = 
  assert_equals test_name string_of_bool expected result ;;

let assert_equals_bool_list (test_name : string) 
                    (expected : bool list) 
                    (result : bool list)
                  : 'a =
assert_equals test_name (string_of_list string_of_bool) expected result ;;  

let assert_equals_string (test_name : string) 
                         (expected : string) 
                         (result : string) 
                       : 'a = 
  assert_strings (expected = result) test_name expected result ;; 

let assert_equals_string_list (test_name : string) 
                    (expected : string list) 
                    (result : string list)
                  : 'a =
assert_equals test_name (string_of_list (fun x -> x)) expected result ;;     

let assert_equals_float (test_name : string)
                        (expected : float)
                        (result : float)
                        (epsilon : float)
                      : 'a = 
  let condition = (abs_float (expected -. result)) < epsilon in 
  let expected_display = string_of_float expected in
  let result_display = string_of_float result in
  assert_strings condition test_name expected_display result_display ;;  



(* Asserts that two objects refer to the same object. *)
let assert_same (test_name : string)
                (string_of_a : 'a -> string)
                (expected : 'a)
                (result : 'a)
              : 'b =
  assert_cmp test_name (==) string_of_a expected result ;;

let assert_same_int (test_name : string) (expected : int) (result : int) : 'a =
  assert_same test_name string_of_int expected result ;;

let assert_same_float (test_name : string) 
                      (expected : float) 
                      (result : float) 
                    : 'a =
  assert_same test_name string_of_float expected result ;;

let assert_same_char (test_name : string) 
                     (expected : char) 
                     (result : char) 
                   : 'a =
  let string_of_char = fun my_char -> String.make 1 my_char in
  assert_same test_name string_of_char expected result ;;  

let assert_same_bool (test_name : string) 
                     (expected : bool) 
                     (result : bool) 
                   : 'a = 
  assert_same test_name string_of_bool expected result ;;

let assert_same_string (test_name : string)
                       (expected : string)
                       (result : string)
                     : 'a = 
  assert_strings (expected == result) test_name expected result ;; 

(* Asserts that a condition is true. *)
let assert_true (test_name : string) (result : bool) : 'a =
  assert_equals_bool test_name true result ;;

(* Asserts that a condition is false. *)
let assert_false (test_name : string) (result : bool) : 'a =
  assert_equals_bool test_name false result ;;

(* Fails a test with the given message. *)
let fail (test_name : string) (message : string) : 'a =
  Printf.fprintf stdout "%sTest '%s' failed. '%s'\n" 
  red_text_code test_name message ;;

let assert_none (test_name : string) (opt : float option) : 'a =
  match opt with 
  | Some _x -> Printf.fprintf stdout 
                "%sTest '%s' failed. Expected: 'None', but actual: 'Some'\n" 
                red_text_code test_name ;
                assert false 
  | None -> if print_true_conditions then 
              Printf.fprintf stdout "Test '%s' passed. Value: 'None'\n" 
              test_name ;
              assert true 
;;









                       