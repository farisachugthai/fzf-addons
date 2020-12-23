" Yeah vim now has built-in support for unit tests
" Who woulda thought?
" As nothing much exists currently, let's do some
" really basic shit
"
" For the future don't hesitate to reference

" *v:errors* *errors-variable* *assert-return*
" or:
" assert_true({actual} [, {msg}])					*assert_true()*

" Smoke test
function s:test_plugin_loaded() abort
  echo 'You did it!'
  call assert_equal(g:did_fzf_addons, 1)
endfunction

" Test that we're catching errors
function s:expected_failure() abort
  call assert_equal(0, 1)
endfunction

" Execute all test functions, and immediately stop if one fails
" At some point it may be useful to write a new function that separates
" executing the test functions because that's very specific to this file, and
" another that properly formats the error as desired.
" Alternatively, a wrapper so that I can individually call each test function
function Main() abort
  for i in [ 's:test_plugin_loaded']
        " Skip as this was written just to make sure I was actually catching failing tests
        " 's:expected_failure'

    " HOLY FUCK I CAN'T BELIEVE THIS WORKED
    " Dude my vimscript is still on point and I haven't done any in months
    " This line successfully takes a string and converts it to the desired function
    " by using funcref, and then calls it! I got messed up at first by forgetting
    " the parenthesis after the funcref but I'm seriously excited right now
    call funcref(i)()

    if len(v:errors) > 0
      echoerr 'SOMETHING FAILED'
      echo v:errors
      return
    endif
  endfor
endfunction

call Main()
