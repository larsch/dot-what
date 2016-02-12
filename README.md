# dot-what

Show ruby available methods on objects and classes

## Synopsis

```shell
c:\> irb
irb(main):001:0> require 'what'
=> true
irb(main):002:0> String.what?
=> nil
```

```shell
irb(main):001:0> require 'time'
=> true
irb(main):002:0> Time.what?
=> nil
```

```shell
irb(main):001:0> require 'time'
=> true
irb(main):002:0> Time.instance_what?
=> nil
```

## Installation

```shell
gem install dot-what
```
