# dot-what

Show available Ruby methods on objects and classes. 

Listed methods are grouped by where they are defined. Singleton methods are shown first, followed by class methods, then base classes, and included modules.

Source location is shown (if available), and documentation is automatically extracted and shown.

Output information in full color to a color-capabable pager. On Windows, less from your Git installation will work.

Mostly useful in interactive Ruby sessions (irb). 

## Synopsis

### List available methods

```shell
c:\> irb
irb(main):001:0> require 'what'
=> true
irb(main):002:0> String.what?
```

![string-what](https://github.com/larsch/dot-what/raw/screenshots/string-what.png)

### Show source location and documentation (if found)

```shell
irb(main):001:0> require 'time'
=> true
irb(main):002:0> Time.what?
```

![time-what](https://github.com/larsch/dot-what/raw/screenshots/time-what.png)

### Show instance methods

```shell
irb(main):001:0> require 'time'
=> true
irb(main):002:0> Time.instance_what?
```

![time-instance-what](https://github.com/larsch/dot-what/raw/screenshots/time-instance-what.png)

### Show only a single method

```shell
irb(main):001:0> Time.what?(:iso8601)
```

![time-instance-what](https://github.com/larsch/dot-what/raw/screenshots/time-what-method.png)

## Installation

```shell
gem install dot-what
```
