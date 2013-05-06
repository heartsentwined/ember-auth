exports = exports ? this

class SharedExample
  _examples: {}

  example: (name, callback) ->
    SharedExample::_examples[name] = callback

  follow: (name, args..., callback) ->
    args.push callback unless typeof callback == 'function'
    if (example = SharedExample::_examples[name])?
      describe "follows #{name}", ->
        callback() if typeof callback == 'function'
        example.apply this, args
    else
      it "cannot find example #{name}", ->
        expect(false).toEqual true # dummy

sharedExample = new SharedExample

exports.example = sharedExample.example
exports.follow  = sharedExample.follow
