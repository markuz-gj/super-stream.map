{Transform} = require "readable-stream" 

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

# once = require "lodash.once"

expect = chai.expect
chai.config.showDiff = no

map = require ".."
{bufferMode, objectMode, Deferred, spy} = require "./fixture"

describe "exported value:", ->
  it 'must be a function', ->
    expect(map).to.be.an.instanceof Function

  it "must have obj property", ->
    expect(map).to.have.property "obj"
    expect(map.obj).to.be.an.instanceof Function

  it "must have buf property", ->
    expect(map).to.have.property "buf"
    expect(map.buf).to.be.an.instanceof Function

  it "must have factory property", ->
    expect(map).to.have.property "factory"
    expect(map.factory).to.be.an.instanceof Function



for mode in [bufferMode, objectMode]
  do (mode) ->
    describe mode.desc, ->
      beforeEach mode.before map
      afterEach mode.after

      it "must return an instanceof Transform", ->
        @defer.resolve()
        return @defer.then =>
          @streamsArray.map (stream, i) =>
            expect(stream).to.be.an.instanceof Transform

      it "must return a noop stream if called without arguments", ->
        @defer.resolve()
        return @defer.then =>
          @noop.pipe @thr (c,e,n) => expect(c).to.be.equal @data1
          @noop.write @data1

      it "must pass data through stream unchanged", ->
        @streamsArray.map (stream, i) =>
          stream.write @data1
          @cache.push stream.spy

        @defer.resolve()
        return @defer.then =>
          @cache.map (spy, i) =>
            expect(spy).to.have.been.calledWith @data1
            expect(spy).to.have.been.calledOnce

      it "must be able to re-use the same stream multiple times", ->
        @streamsArray.map (stream, i) =>
          @dataArray.map (data, j) =>
            stream.write data
            @cache.push {spy: stream.spy, data: data}

        @defer.resolve()
        return @defer.then =>
          @cache.map (v, i) =>
            expect(v.spy).to.have.been.calledWith v.data
            expect(v.spy).to.have.callCount @dataArray.length

      it "must pass data down stream multiple times", ->
        lastSpy = @streamsArray[-1..-1][0].spy
        @noop.pipe @streamsArray[0]

        @streamsArray.map (stream, i) =>
          if i is @streamsArray.length - 1
            @dataArray.map (data, j) => @noop.write data
            return 
          stream.pipe @streamsArray[i + 1]
        
        @defer.resolve()
        return @defer.then =>
          expect(lastSpy).to.have.callCount @dataArray.length
          @dataArray.map (data, i) =>
            expect(lastSpy).to.have.been.calledWith data


      describe "stream contex:", ->

        it "must have a `this._map` property on stream ctx and not as own property", ->
          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              stream.write data
              @cache.push {stream: stream, data: data}
          
          @defer.resolve()
          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.stream).have.property "_map"

              v.stream.spy2.args.map (x) ->
                # console.log(x[0])
                expect(x[0]).to.not.have.ownProperty "_map"
                expect(x[0]).to.have.property "_map"

        it "must have a `this._push` property on stream ctx and not as own property", ->
          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              stream.write data
              @cache.push {stream: stream, data: data}
          
          @defer.resolve()
          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.stream).have.property "_push"

              v.stream.spy2.args.map (x) ->
                # console.log(x[0])
                expect(x[0]).to.not.have.ownProperty "_map"
                expect(x[0]).to.have.property "_push"

        it "must throw if a `this._push` and the transform callback are run", ->
          @streamsArray.push(@stErrorB)

          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              stream.on 'error', (err) =>
                expect(i).to.be.equal @streamsArray.length - 1
                expect(err.message).to.be.equal 'no writecb in Transform class'
                expect(err.message).to.not.be.equal 'eeee'

              stream.write data
              @cache.push {spy: stream.spy, data: data, streamID: i}

          @defer.resolve()
          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.spy).to.have.been.calledWith v.data
              expect(v.spy).to.have.callCount @dataArray.length


        it "must NOT keep any data attached into ctx (inner and outer)", ->
          hasCounter = (id) =>
            # only the 3rd to 6th streams sets up a counter.
            return (id >= 2) and (id < 6)

          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              stream.write data
              @cache.push {stream: stream, data: data, streamID: i}
          
          @defer.resolve()
          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.stream).to.not.have.property "counter"

              v.stream.spy2.args.map (x) =>
                ctx = x[0]

                if hasCounter v.streamID
                  # context is frozen, so no counter in it !
                  expect(ctx).to.not.have.property("counter").and.be.equal 0
                else
                  expect(ctx).to.not.have.property "counter"

      describe "user's transform returned value:", ->
        
        it "must throw if a Error object is returned", ->
          @streamsArray.push(@stErrorA)

          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              stream.on 'error', (err) =>
                expect(i).to.be.equal @streamsArray.length - 1
                expect(err.message).to.be.equal 'stError'
                expect(err.message).to.not.be.equal 'eeee'

              stream.write data
              @cache.push {spy: stream.spy, data: data, streamID: i}

          @defer.resolve()
          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.spy).to.have.been.calledWith v.data
              expect(v.spy).to.have.callCount @dataArray.length

        it "must execute callback only after returned promise is resolved", ->
          @streamsArray.push(@stPromise)

          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>
              if (i is @streamsArray.length - 1) and (j is @dataArray.length - 1)
                # delaying defer until the very last moment.
                stream.pipe @thr (c) => @defer.resolve() 
              stream.write data
              @cache.push {spy: stream.spy, data: data, streamID: i}

          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.spy).to.have.been.calledWith v.data
              expect(v.spy).to.have.callCount @dataArray.length

        it "must throw if returned promise is rejected", ->
          @streamsArray.push(@stPromiseError)

          @streamsArray.map (stream, i) =>
            @dataArray.map (data, j) =>

              stream.on 'error', (err) =>
                expect(i).to.be.equal @streamsArray.length - 1
                expect(err.message).to.be.equal 'stPromiseError'
                expect(err.message).to.not.be.equal 'eeee'

              if (i is @streamsArray.length - 1) and (j is @dataArray.length - 1)
                # delaying defer until the very last moment.
                stream.pipe @thr (c) => @defer.resolve() 

              stream.write data
              @cache.push {spy: stream.spy, data: data, streamID: i}

          return @defer.then =>
            @cache.map (v, i) =>
              expect(v.spy).to.have.been.calledWith v.data
              expect(v.spy).to.have.callCount @dataArray.length



