code.language: cpp
-
tag(): user.code_imperative

tag(): user.code_comment_documentation
tag(): user.code_comment_line
tag(): user.code_comment_block_c_like
tag(): user.code_data_bool
tag(): user.code_data_null
tag(): user.code_functions
tag(): user.code_libraries
tag(): user.code_libraries_gui
tag(): user.code_object_oriented
tag(): user.code_operators_array
tag(): user.code_operators_assignment
tag(): user.code_operators_bitwise
tag(): user.code_operators_lambda
tag(): user.code_operators_math
tag(): user.code_operators_pointer

settings():
    user.code_private_function_formatter = "PUBLIC_CAMEL_CASE"
    user.code_protected_function_formatter = "PUBLIC_CAMEL_CASE"
    user.code_public_function_formatter = "PUBLIC_CAMEL_CASE"
    user.code_private_variable_formatter = "PUBLIC_CAMEL_CASE"
    user.code_protected_variable_formatter = "PUBLIC_CAMEL_CASE"
    user.code_public_variable_formatter = "PUBLIC_CAMEL_CASE"


# ^funky <user.text>$: user.code_default_function(text)
# ^static funky <user.text>$: user.code_private_static_function(text)

# NOTE: migrated from generic, as they were only used here, though once cpp support is added, perhaps these should be migrated to a tag together with the commands below
state include:
    insert('#include ')
state include system:
    insert('#include <>')
    edit.left()
state include local:
    insert('#include ".h"')
    edit.left()
    edit.left()
    edit.left()
state type deaf:
    insert('typedef ')
state struct:
    insert('struct  {};')
    key('left:4')


# XXX - create a preprocessor tag for these, as they will match cpp, etc
state [pre] define: "#define "
state [pre] undefine: "#undef "
state [pre] if (define|def): "#ifdef "

# XXX - preprocessor instead of pre?
state pre if: "#if "
state error: "#error "
state pre else: "#else"
state pre else if: "#elif "
state pre end if: "#endif"
state pragma: "#pragma "
state default:
    insert("default:\nbreak;")
    edit.extend_left()
    edit.extend_word_left()
state assert:
    insert("assert();")
    edit.left()
    edit.left()
state co await: "co_await "
state co return: "co_return "

# Declare variables or structs etc.
# Examples:
#   variable int air -> "int a"
#   declare standard string function get text -> "std::string get_text()"
#   declare void function pointer callback -> "void(* callback)()"
(var|declare) <user.cpp_raw_type> <user.text>$:
    var_name = user.formatted_text(text, "PUBLIC_CAMEL_CASE")
    insert(user.cpp_build_declarator(cpp_raw_type, var_name))

(var|declare) <user.cpp_raw_type> <user.letter>:
    insert(user.cpp_build_declarator(cpp_raw_type, letter))

# Ex. (int *)
{user.cpp_cast_style}:
    user.cpp_insert_cast(cpp_cast_style, "")
{user.cpp_cast_style} [to] <user.cpp_type>:
    user.cpp_insert_cast(cpp_cast_style, cpp_type)

# e.g. use "const" to insert a const modifier at the cursor position
# {user.cpp_pointers}: "{cpp_pointers}"
{user.cpp_type_qualifiers}: "{cpp_type_qualifiers} "

# "type" introduces a fully-general type.
type <user.cpp_type>: "{cpp_type}"
# Alternatively, words like "const", "pointer" or "standard" also start type-entry mode.
<user.cpp_type_prefix> <user.cpp_raw_type>:
    ty = user.cpp_build_declarator_with_prefix(cpp_type_prefix, cpp_raw_type, '')
    insert("{ty}")
{user.cpp_standard} <user.cpp_unqualified_standard_generic_type>: "std::{cpp_unqualified_standard_generic_type} "
# 'auto' is common enough that we allow skipping the "type" prefix
auto: "auto "
# call <user.code_functions>:
#     user.cpp_insert_call("{code_functions}")
# {user.cpp_standard} double colon: "std::"
# {user.cpp_standard} {user.cpp_standard_functions}:
#     user.cpp_insert_call("std::{cpp_standard_functions}")
# {user.cpp_standard} {user.cpp_standard_range_algorithms}:
#     user.cpp_insert_call("std::{cpp_standard_range_algorithms}")
# {user.cpp_standard} ranges {user.cpp_standard_range_algorithms}:
#     user.cpp_insert_call("std::ranges::{cpp_standard_range_algorithms}")

# {user.cpp_standard} {user.cpp_standard_objects}: "std::{cpp_standard_objects}"
access {user.cpp_access_specifiers}: "{cpp_access_specifiers}:\n"
{user.cpp_declaration_specifiers}: "{cpp_declaration_specifiers} "

# For abstract methods:
equals zero: "= 0"
# For copy constructor declarations:
equals default: "= default"
equals delete: "= delete"

finish:
    key(escape)
    edit.line_end()
    sleep(100ms)
    insert(";")

toggle includes: user.code_toggle_libraries()
#include engine <user.code_libraries>:
#    user.code_insert_library(code_libraries, "")
include local <user.cpp_user_libraries>:
    user.code_insert_library(code_libraries, "")


# Variants of data_null.talon that allow saying "null pointer"
# without it resulting in "nullptr*"
[state] (no | nil | null) pointer: user.code_insert_null()
is not (none|null) pointer: user.code_insert_is_not_null()
is (none|null) pointer: user.code_insert_is_null()

flute <number>:
    insert("{number}.f")

scope: "::"
^block$:
    edit.line_insert_down()
    insert("{")
    edit.line_insert_down()
    edit.line_insert_down()
    insert("}")
    edit.up()
    key("tab")

^public$: 
    edit.delete_line()
    insert("public:")
^protected$: 
    edit.delete_line()
    insert("protected:")
^private$: 
    edit.delete_line()
    insert("private:")

(val oak) <user.prose>$:
    insert(".")
    user.insert_formatted(prose, "PUBLIC_CAMEL_CASE")
    insert("()")
    edit.left()
(val prop) <user.prose>$:
    insert(".")
    user.insert_formatted(prose, "PUBLIC_CAMEL_CASE")
(point oak) <user.prose>$:
    insert("->")
    user.insert_formatted(prose, "PUBLIC_CAMEL_CASE")
    insert("()")
    edit.left()
(point prop) <user.prose>$:
    insert("->")
    user.insert_formatted(prose, "PUBLIC_CAMEL_CASE")
^todo$: "// TODO: "