class Test
  constructor: (@expect, @val, @toEqual) ->
    # Run it, and time that
    begin = new Date()
    @result = @val()
    end = new Date()
    @runtime = end.valueOf() - begin.valueOf()

    if @result.toString() == @toEqual.toString()
      @printSuccess()
    else
      @printFailure()

  print: (result, success) ->
    q("body").innerHTML += "<div class=\"#{if success then "success" else "failed"}\">#{result}</div>"

  printSuccess: ->
    @print("#{@expect} <b>success</b> in #{@runtime}ms", true)

  printFailure: ->
    @print("#{@expect} <b>failed</b> in #{@runtime}ms\n  Expected: #{@toEqual}\n  Got:      #{@result}", false)

