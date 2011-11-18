
function(ctk_option_logical_expression_to_message varname logical_expr)
  set(enabling_msg)
  foreach(arg ${logical_expr})
    if(NOT "${${arg}}" STREQUAL "")
      set(value_as_int 0)
      if(${${arg}})
        set(value_as_int 1)
      endif()
      set(enabling_msg "${enabling_msg} ${arg}:${value_as_int}")
    else()
      set(enabling_msg "${enabling_msg} ${arg}")
    endif()
  endforeach()
  set(${varname} ${enabling_msg} PARENT_SCOPE)
endfunction()

macro(ctk_option option_prefix name doc default)
  option(${option_prefix}_${name} ${doc} ${default})
  mark_as_advanced(${option_prefix}_${name})
  list(APPEND ${option_prefix}S ${name})
  set(_logical_expr ${ARGN})
  if(_logical_expr AND NOT ${option_prefix}_${name})
    if(${ARGN})
      # Force the option to ON. This is okay since the
      # logical expression should contain a CTK_ENABLE_*
      # option value, which requires the current option to be ON.
      get_property(_doc_string CACHE ${option_prefix}_${name} PROPERTY HELPSTRING)
      set(${option_prefix}_${name} ON CACHE BOOL ${_doc_string} FORCE)
      # Generate user-friendly message
      set(enabling_msg)
      ctk_option_logical_expression_to_message(enabling_msg "${ARGN}")
      message("Enabling [${option_prefix}_${name}] because of [${enabling_msg}] evaluates to True")
    endif()
  endif()
endmacro()

macro(ctk_lib_option name doc default)
  ctk_option(CTK_LIB ${name} ${doc} ${default} ${ARGN})
endmacro()

macro(ctk_plugin_option name doc default)
  ctk_option(CTK_PLUGIN ${name} ${doc} ${default} ${ARGN})
endmacro()

macro(ctk_app_option name doc default)
  ctk_option(CTK_APP ${name} ${doc} ${default} ${ARGN})
endmacro()

macro(ctk_enable_option name doc default)
  option(CTK_ENABLE_${name} "${doc}" ${default})
  if(DEFINED CTK_ENABLE_${name}_internal)
    if(${CTK_ENABLE_${name}} AND ${CTK_ENABLE_${name}_internal})
      if(NOT (${ARGN}))
        get_property(_doc_string CACHE CTK_ENABLE_${name} PROPERTY HELPSTRING)
        set(CTK_ENABLE_${name} OFF CACHE BOOL ${_doc_string} FORCE)
        message("Full support for [${name}] disabled")
      endif()
    endif()
  endif()
  set(CTK_ENABLE_${name}_internal ${CTK_ENABLE_${name}} CACHE INTERNAL "" FORCE)
endmacro()
