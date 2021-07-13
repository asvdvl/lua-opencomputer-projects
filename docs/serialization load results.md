`a = asv.time.getRaw() for i = 1, 10000 do serialization.unserialize("{}") end print((asv.time.getRaw() - a)/10000)`\
`a = asv.time.getRaw() for i = 1, 10000 do serialization.serialize({}) end print((asv.time.getRaw() - a)/10000)`

## unserialize\
`"" - 0.033`\
`"{}" - 0.033`
`"{protocol = "asvnetl2", data = ""}" - 0.045`\
`"{protocol = "asvnetl2", data = "a"(x1000)}" - 0.068`\
`"{protocol = "asvnetl2", data = "a"(x8000)}" - 0.068`\
`"{protocol = "asvnetl2", data = {protocol = "ipv4", src = 3221226219, dst  = 3221226220, flags = 1, id = 0, hl = 20, data = {protocol = "tcp", sn = 21, ACKSN = 2, flag = "AAA", data = ""}}}" - 0.071`\
## serialize\
`"" - 0.1`\
`{} - 0.1`\
`{protocol = "asvnetl2", data = ""} - 0.1`\
`{protocol = "asvnetl2", data = "a"(x1000)} - 19`\
`{protocol = "asvnetl2", data = {protocol = "ipv4", src = 3221226219, dst  = 3221226220, flags = 1, id = 0, hl = 20, data = {protocol = "tcp", sn = 21, ACKSN = 2, flag = "AAA", data = ""}}} - 0.354`\
`{protocol = "asvnetl2", data = {protocol = "ipv4", src = 3221226219, dst  = 3221226220, flags = 1, id = 0, hl = 20, data = {protocol = "tcp", sn = 21, ACKSN = 2, flag = "AAA", data = "a"(x8000)}}} - 168`\
