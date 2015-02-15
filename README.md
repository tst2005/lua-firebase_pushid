This is a Lua package to generate guid (globally unique id) with good properties

Usage:
```
local firebase_pushid = require("firebase_pushid")

local id := firebase_pushid.new()
print( ("guid: '%s'\n"):format(id) )
```

Generated guids have good properties:
* they're 20 character strings, safe for inclusion in urls (don't require escaping)
* they're based on timestamp so that they sort **after** any existing ids
* they contain 72-bits of random data after the timestamp so that IDs won't
  collide with other clients' IDs
* they sort **lexicographically** (so the timestamp is converted to characters
  that will sort properly)
* they're monotonically increasing.  Even if you generate more than one in the
  same timestamp, thelatter ones will sort after the former ones.  We do this
  by using the previous random bits but "incrementing" them by 1 (only in the
  case of a timestamp collision).

Read https://www.firebase.com/blog/2015-02-11-firebase-unique-identifiers.html
for more info.

Based on [firebase_pushid.py](https://gist.github.com/risent/4cab3878d995bec7d1c2)
