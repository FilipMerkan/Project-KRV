scoring = require('./scoring')

# Language support: 'en' for English, 'sl' for Slovenian
# Can be set globally: window.ZXCVBN_LANGUAGE = 'sl'
# Or passed as parameter to zxcvbn function
LANGUAGE = if typeof window != 'undefined' and window.ZXCVBN_LANGUAGE
  window.ZXCVBN_LANGUAGE
else if typeof process != 'undefined' and process.env?.ZXCVBN_LANGUAGE
  process.env.ZXCVBN_LANGUAGE
else
  'en'

# Translations
TRANSLATIONS =
  en:
    default_feedback:
      warning: ''
      suggestions: [
        "Use a few words, avoid common phrases"
        "No need for symbols, digits, or uppercase letters"
      ]
    extra_feedback: 'Add another word or two. Uncommon words are better.'
    spatial:
      straight: 'Straight rows of keys are easy to guess'
      short: 'Short keyboard patterns are easy to guess'
      suggestion: 'Use a longer keyboard pattern with more turns'
      slovenian_layout: 'Slovenian keyboard patterns are easy to guess'
    repeat:
      single: 'Repeats like "aaa" are easy to guess'
      multi: 'Repeats like "abcabcabc" are only slightly harder to guess than "abc"'
      suggestion: 'Avoid repeated words and characters'
    sequence:
      warning: "Sequences like abc or 6543 are easy to guess"
      suggestion: 'Avoid sequences'
    regex:
      recent_year: "Recent years are easy to guess"
      avoid_recent: 'Avoid recent years'
      avoid_personal: 'Avoid years that are associated with you'
    date:
      warning: "Dates are often easy to guess"
      suggestion: 'Avoid dates and years that are associated with you'
      slovenian_format: 'Date in Slovenian format (DD.MM.YYYY) detected'
    dictionary:
      top10: 'This is a top-10 common password'
      top100: 'This is a top-100 common password'
      very_common: 'This is a very common password'
      similar: 'This is similar to a commonly used password'
      word_alone: 'A word by itself is easy to guess'
      names_alone: 'Names and surnames by themselves are easy to guess'
      names_common: 'Common names and surnames are easy to guess'
      capitalization: "Capitalization doesn't help very much"
      all_upper: "All-uppercase is almost as easy to guess as all-lowercase"
      reversed: "Reversed words aren't much harder to guess"
      l33t: "Predictable substitutions like '@' instead of 'a' don't help very much"
  sl:
    default_feedback:
      warning: ''
      suggestions: [
        "Uporabite nekaj besed, izogibajte se pogostim frazam"
        "Ni potrebe po simbolih, številkah ali velikih črkah"
      ]
    extra_feedback: 'Dodajte še eno ali dve besedi. Manj pogoste besede so boljše.'
    spatial:
      straight: 'Ravne vrste tipk je enostavno uganiti'
      short: 'Kratke vzorce tipkovnice je enostavno uganiti'
      suggestion: 'Uporabite daljši vzorec tipkovnice z več obrati'
      slovenian_layout: 'Vzorce slovenske tipkovnice je enostavno uganiti'
    repeat:
      single: 'Ponovitve kot "aaa" je enostavno uganiti'
      multi: 'Ponovitve kot "abcabcabc" so le malo težje za uganiti kot "abc"'
      suggestion: 'Izogibajte se ponavljajočim besedam in znakom'
    sequence:
      warning: "Zaporedja kot abc ali 6543 je enostavno uganiti"
      suggestion: 'Izogibajte se zaporedjem'
    regex:
      recent_year: "Nedavna leta je enostavno uganiti"
      avoid_recent: 'Izogibajte se nedavnim letom'
      avoid_personal: 'Izogibajte se letom, ki so povezana z vami'
    date:
      warning: "Datumi so pogosto enostavni za uganiti"
      suggestion: 'Izogibajte se datumom in letom, ki so povezana z vami'
      slovenian_format: 'Uporabljen je datum v slovenskem formatu (DD.MM.YYYY)'
    dictionary:
      top10: 'To je eno izmed 10 najpogostejših gesel'
      top100: 'To je eno izmed 100 najpogostejših gesel'
      very_common: 'To je zelo pogosto geslo'
      similar: 'To je podobno pogosto uporabljenemu geslu'
      word_alone: 'Beseda sama je enostavna za uganiti'
      names_alone: 'Imena in priimki sami so enostavni za uganiti'
      names_common: 'Pogosta imena in priimki so enostavni za uganiti'
      capitalization: "Velika začetnica ne pomaga veliko"
      all_upper: "Vse velike črke so skoraj tako enostavne za uganiti kot vse male"
      reversed: "Obrnjene besede niso veliko težje za uganiti"
      l33t: "Predvidljive zamenjave kot '@' namesto 'a' ne pomagajo veliko"
      # Slovenian-specific messages
      slovenian_password_top10: 'To je eno izmed 10 najpogostejših slovenskih gesel'
      slovenian_password_top100: 'To je eno izmed 100 najpogostejših slovenskih gesel'
      slovenian_password_common: 'To je zelo pogosto slovensko geslo iz podatkovnih kršitev'
      slovenian_word: 'Uporabljena je pogosta slovenska beseda'
      slovenian_word_common: 'To je zelo pogosta slovenska beseda'
      slovenian_surname: 'Uporabljen je pogost slovenski priimek'
      slovenian_surname_common: 'To je zelo pogost slovenski priimek'
      slovenian_male_name: 'Uporabljeno je pogosto slovensko moško ime'
      slovenian_female_name: 'Uporabljeno je pogosto slovensko žensko ime'
      slovenian_name_common: 'To je zelo pogosto slovensko ime'
      international_password_top10: 'To je eno izmed 10 najpogostejših mednarodnih gesel'
      international_password_top100: 'To je eno izmed 100 najpogostejših mednarodnih gesel'
      international_password_common: 'To je zelo pogosto mednarodno geslo'

get_language = ->
  if typeof window != 'undefined' and window.ZXCVBN_LANGUAGE
    window.ZXCVBN_LANGUAGE
  else if typeof process != 'undefined' and process.env?.ZXCVBN_LANGUAGE
    process.env.ZXCVBN_LANGUAGE
  else
    'en'

t = (key) ->
  lang = get_language()
  keys = key.split('.')
  value = TRANSLATIONS[lang]
  for k in keys
    value = value?[k]
  value ? TRANSLATIONS.en[key.split('.')[0]]?[key.split('.')[1]] ? key

feedback =
  default_feedback: ->
    lang = get_language()
    TRANSLATIONS[lang].default_feedback

  get_feedback: (score, sequence) ->
    # starting feedback
    return @default_feedback() if sequence.length == 0

    # no feedback if score is good or great.
    return if score > 2
      warning: ''
      suggestions: []

    # tie feedback to the longest match for longer sequences
    longest_match = sequence[0]
    for match in sequence[1..]
      longest_match = match if match.token.length > longest_match.token.length
    feedback = @get_match_feedback(longest_match, sequence.length == 1)
    extra_feedback = t('extra_feedback')
    if feedback?
      feedback.suggestions.unshift extra_feedback
      feedback.warning = '' unless feedback.warning?
    else
      feedback =
        warning: ''
        suggestions: [extra_feedback]
    feedback

  get_match_feedback: (match, is_sole_match) ->
    switch match.pattern
      when 'dictionary'
        @get_dictionary_match_feedback match, is_sole_match

      when 'spatial'
        layout = match.graph.toUpperCase()
        is_slovenian = match.graph == 'qwertz_slovenian'
        warning = if match.turns == 1
          if is_slovenian
            t('spatial.slovenian_layout')
          else
            t('spatial.straight')
        else
          if is_slovenian
            t('spatial.slovenian_layout')
          else
            t('spatial.short')
        warning: warning
        suggestions: [
          t('spatial.suggestion')
        ]

      when 'repeat'
        warning = if match.base_token.length == 1
          t('repeat.single')
        else
          t('repeat.multi')
        warning: warning
        suggestions: [
          t('repeat.suggestion')
        ]

      when 'sequence'
        warning: t('sequence.warning')
        suggestions: [
          t('sequence.suggestion')
        ]

      when 'regex'
        if match.regex_name == 'recent_year'
          warning: t('regex.recent_year')
          suggestions: [
            t('regex.avoid_recent')
            t('regex.avoid_personal')
          ]

      when 'date'
        lang = get_language()
        # Check for Slovenian-specific dates
        date_str = match.token
        is_slovenian_format = date_str.match(/^(\d{2})\.(\d{2})\.(\d{4})$/) or date_str.match(/^(\d{2})(\d{2})(\d{4})$/)
        
        warning = t('date.warning')
        if lang == 'sl' and is_slovenian_format
          warning = t('date.slovenian_format')
        
        warning: warning
        suggestions: [
          t('date.suggestion')
        ]

  get_dictionary_match_feedback: (match, is_sole_match) ->
    warning = ''
    lang = get_language()
    
    # Handle Slovenian passwords
    if match.dictionary_name == 'slovenian_passwords'
      if not match.l33t and not match.reversed
        if match.rank <= 10
          warning = t('dictionary.slovenian_password_top10')
        else if match.rank <= 100
          warning = t('dictionary.slovenian_password_top100')
        else if is_sole_match or match.rank <= 1000
          warning = t('dictionary.slovenian_password_common')
      else if match.guesses_log10 <= 4
        warning = t('dictionary.slovenian_password_common')
    # Handle English/international passwords
    else if match.dictionary_name == 'passwords'
      if not match.l33t and not match.reversed
        if match.rank <= 10
          if lang == 'sl'
            warning = t('dictionary.international_password_top10')
          else
            warning = t('dictionary.top10')
        else if match.rank <= 100
          if lang == 'sl'
            warning = t('dictionary.international_password_top100')
          else
            warning = t('dictionary.top100')
        else if is_sole_match
          if lang == 'sl'
            warning = t('dictionary.international_password_common')
          else
            warning = t('dictionary.very_common')
      else if match.guesses_log10 <= 4
        if lang == 'sl'
          warning = t('dictionary.international_password_common')
        else
          warning = t('dictionary.similar')
    # Handle Slovenian words
    else if match.dictionary_name == 'slovenian_wikipedia'
      if is_sole_match
        if match.rank <= 1000
          warning = t('dictionary.slovenian_word_common')
        else
          warning = t('dictionary.slovenian_word')
      else
        warning = t('dictionary.slovenian_word')
    # Handle English words
    else if match.dictionary_name == 'english_wikipedia'
      if is_sole_match
        warning = t('dictionary.word_alone')
    # Handle Slovenian surnames
    else if match.dictionary_name == 'slovenian_surnames'
      if is_sole_match
        if match.rank <= 100
          warning = t('dictionary.slovenian_surname_common')
        else
          warning = t('dictionary.slovenian_surname')
      else
        warning = t('dictionary.slovenian_surname')
    # Handle Slovenian male names
    else if match.dictionary_name == 'slovenian_male_names'
      if is_sole_match
        if match.rank <= 50
          warning = t('dictionary.slovenian_name_common')
        else
          warning = t('dictionary.slovenian_male_name')
      else
        warning = t('dictionary.slovenian_male_name')
    # Handle Slovenian female names
    else if match.dictionary_name == 'slovenian_female_names'
      if is_sole_match
        if match.rank <= 50
          warning = t('dictionary.slovenian_name_common')
        else
          warning = t('dictionary.slovenian_female_name')
      else
        warning = t('dictionary.slovenian_female_name')
    # Handle English names (fallback)
    else if match.dictionary_name in ['surnames', 'male_names', 'female_names']
      if is_sole_match
        warning = t('dictionary.names_alone')
      else
        warning = t('dictionary.names_common')

    suggestions = []
    word = match.token
    if word.match(scoring.START_UPPER)
      suggestions.push t('dictionary.capitalization')
    else if word.match(scoring.ALL_UPPER) and word.toLowerCase() != word
      suggestions.push t('dictionary.all_upper')

    if match.reversed and match.token.length >= 4
      suggestions.push t('dictionary.reversed')
    if match.l33t
      suggestions.push t('dictionary.l33t')

    result =
      warning: warning
      suggestions: suggestions
    result

module.exports = feedback
