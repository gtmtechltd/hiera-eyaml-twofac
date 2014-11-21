hiera-eyaml-twofac
==================

This is a plugin encryptor for the hiera-eyaml project (hosted https://github.com/TomPoulton/hiera-eyaml/).

It encrypts using the pkcs7 encryption type (much like the existing encryptor) - however it also requires an interactive password to be supplied at runtime. This makes it fairly useless in puppet scenarios, however eyaml as a tool is useful in other scenarios. 

Usage:

```
$ gem install hiera-eyaml-twofac
```

Then see hiera-eyaml documentation for how to use the eyaml tool to encrypt using the 'TWOFAC' encryption_type.

Authors
=======

- [Geoff Meakin](http://github.com/gtmtechltd)

License
=======

The MIT License (MIT)

Copyright (c) 2013 GTMTech Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
