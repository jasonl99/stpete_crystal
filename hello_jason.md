# Hello, Jason!
So we change our line of code to something very familiar to rubyists.  String interpolation:

```crystal
puts "Hello, #{ARGV[0]? || "world"}!"
```

From the terminal:

```bash
crystal src/stpete_crystal.cr         # Hello, world!
crystal src/stpete_crystal.cr Jason   # Hello, Jason!
```

Ok, great.  It works.  I'm bored, can we do something useful?  Why yes, yes we can.

