# Map


[![NPM version](https://badge.fury.io/js/super-stream.map.png)](https://npmjs.org/package/super-stream.map)
[![Build Status](https://travis-ci.org/markuz-gj/super-stream.map.png?branch=master)](https://travis-ci.org/markuz-gj/super-stream.map)
[![Coverage Status](https://coveralls.io/repos/markuz-gj/super-stream.map/badge.png?branch=master)](https://coveralls.io/r/markuz-gj/super-stream.map?branch=master)
[![Dependency Status](https://david-dm.org/markuz-gj/super-stream.map.png)](https://david-dm.org/markuz-gj/super-stream.map)
[![devDependency Status](https://david-dm.org/markuz-gj/super-stream.map/dev-status.png)](https://david-dm.org/markuz-gj/super-stream.map#info=devDependencies)
[![MIT Licensed](http://img.shields.io/badge/license-MIT-blue.svg)](#license)

### Not ready Yet

See also.  
[`super-stream`](https://github.com/markuz-gj/super-stream)  
[`super-stream.through`](https://github.com/markuz-gj/super-stream.through)  
[`super-stream.each`](https://github.com/markuz-gj/super-stream.each)  
[`super-stream.reduce`](https://github.com/markuz-gj/super-stream.reduce)  
[`super-stream.filter`](https://github.com/markuz-gj/super-stream.filter)  
[`super-stream.junction`](https://github.com/markuz-gj/super-stream.junction)  
[`super-stream.pipeline`](https://github.com/markuz-gj/super-stream.pipeline)  

* * *


#### _map([options,] [transformFn,] [flushFn]);_

##### some stuff here



```javascript

var expect = require('chai').expect;
var map = require("super-stream.map")

var streamA = map.obj(function(counter, enc, done){
  counter += 1;
  done(null, counter);
});
var streamB = map({objectMode: true}, function(counter, enc, done){
  counter += 1;
  done(null, counter);
});

var map = map.factory({objectMode: true});

streamA.pipe(streamB).pipe(map(function(counter, enc, done){
  expect(counter).to.be.equal(2);
}));

streamA.write(0);

```



```javascript

var streamA = map(function(chunk, enc, done){
  data = chunk.toString();
  done(null, new Buffer(data +'-'+ data));
});

mapObj = map.factory({objectMode: true});
var streamB = mapObj.buf(function(chunk, enc, done){
  expect(chunk.toString()).to.be.equal('myData-myData');
  done();
});
 
streamA.pipe(streamB);
streamA.write(new Buffer('myData'));

```


#### _map.obj([transfromFn,] [flushFn])_



It is a conveniece method for `map({objectMode: true}, transformFn, flushFn);`  
If called without arguments, returns a passthrough `Transform` 



```javascript
var stream = map.obj(function(string, enc, done){
  expect(string).to.be.deep.equal({data: 'myData'});
  done();
});
stream.write({data: 'myData'});
```


#### _map.buf([transfromFn,] [flushFn])_


It is a conveniece method for `map({objectMode: false}, transformFn, flushFn);`  
If called without arguments, returns a passthrough `Transform` 



```javascript
// see the factory method.
var map = map.factory({objectMode: true});
var myData = new Buffer('my data');

var streamBuf = map.buf(function(chunk, enc, done){
  expect(chunk).to.be.equal(myData);
  expect(chunk).to.not.be.equal('my data');
  done();
});
streamBuf.write(myData);
```


#### _map.factory([options]);_



A factory method for creating a custom `map` instance.  



```javascript
var mapObj = map.factory({objectMode: true});

var streamObj = mapObj(function(string, enc, done){
  expect(string).to.be.equal('my data');
  done();
});
streamObj.write('my data');
```

```javascript
var myData = new Buffer('my data');
var mapBuf = map.factory({objectMode: false, highWaterMark: 1000*Math.pow(2,6)});

var streamBuf = mapBuf(function(chunk, enc, done){
  expect(chunk).to.be.equal(myData);
  expect(chunk).to.not.be.equal('my data');
  done();
});
streamBuf.write(myData);
```

License
---

The MIT License (MIT)

Copyright (c) 2014 Markuz GJ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[![NPM](https://nodei.co/npm/super-stream.map.png)](https://nodei.co/npm/super-stream.map/) [![NPM](https://nodei.co/npm-dl/super-stream.map.png)](https://nodei.co/npm/super-stream.map/)