describe 'Em.Auth.JsonAuthResponse', ->
  auth = null
  json = null

  beforeEach ->
    auth = authTest.create { response: 'json' }
    json = auth._response
  afterEach ->
    auth.destroy() if auth

  describe '#canonicalize', ->

    it 'works with JSON string', ->
      expect(json.canonicalize '{"foo":"bar"}').toEqual { foo: 'bar' }

    it 'throws on invalid JSON', ->
      expect(-> json.canonicalize '<!DOCTYPE html>').toThrow()

    it 'throws on invalid JSON', ->
      expect(-> json.canonicalize 'foo').toThrow()
