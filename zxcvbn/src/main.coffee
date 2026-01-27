matching = require './matching'
scoring = require './scoring'
time_estimates = require './time_estimates'
feedback = require './feedback'

time = -> (new Date()).getTime()

# Set language for feedback messages
# Usage: zxcvbn(password, user_inputs) or zxcvbn(password, user_inputs, 'sl')
# Or set globally: window.ZXCVBN_LANGUAGE = 'sl'
zxcvbn = (password, user_inputs = [], language = null) ->
  start = time()
  # Set language if provided (temporarily override global setting)
  original_lang = null
  if language and typeof window != 'undefined'
    original_lang = window.ZXCVBN_LANGUAGE
    window.ZXCVBN_LANGUAGE = language
  # reset the user inputs matcher on a per-request basis to keep things stateless
  sanitized_inputs = []
  for arg in user_inputs
    if typeof arg in ["string", "number", "boolean"]
      sanitized_inputs.push arg.toString().toLowerCase()
  matching.set_user_input_dictionary sanitized_inputs
  matches = matching.omnimatch password
  result = scoring.most_guessable_match_sequence password, matches
  result.calc_time = time() - start
  attack_times = time_estimates.estimate_attack_times result.guesses
  for prop, val of attack_times
    result[prop] = val
  result.feedback = feedback.get_feedback result.score, result.sequence
  # Restore original language if it was temporarily changed
  if language and typeof window != 'undefined'
    if original_lang?
      window.ZXCVBN_LANGUAGE = original_lang
    else
      delete window.ZXCVBN_LANGUAGE
  result

module.exports = zxcvbn
