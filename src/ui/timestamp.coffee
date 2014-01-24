# Deprecated


timestamp = ($target) ->
  ms = parseInt($target.attr("ms"), 10)
  now = new Date()
  diff = parseInt((now.valueOf() - ms) / 1000, 10)
  if diff < 5
    return "just now"
  else if diff < 60
    return "#{diff}s ago"
  else if diff < (60 * 45)
    return "#{Math.round(diff / 60)}m ago"
  else if diff < (60 * 60)
    return "about an hour ago"
  else
    return "over an hour ago"

setup.push ->
  setInterval(->
    $("[ms]").each(->
      $self = $ @
      $self.text(timestamp($self)))
  , 1000)




