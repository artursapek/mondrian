# Simple yet helpful lil' guy

class Set extends Array

  constructor: (array) ->
    for elem in array
      unless @has elem
        @push elem
    super

  push: (elem) ->
    return if @has elem
    super elem

window.Set = Set
