# Overview
- WUID is a unique number generator, while it is not a UUID implementation.
- WUID is **10-135** times faster than UUID and **4600** times faster than generating unique numbers with Redis.
- WUID generates unique 64-bit integers in sequence. The high 24 bits are loaded from a data store. By now, Redis, MySQL, PostgreSQL, and MongoDB are supported.

# Benchmarks
```
BenchmarkWUID       100000000           10.3 ns/op         0 B/op          0 allocs/op
BenchmarkRand        50000000           24.6 ns/op         0 B/op          0 allocs/op
BenchmarkTimestamp  100000000           12.3 ns/op         0 B/op          0 allocs/op
BenchmarkUUID_V1     20000000          107 ns/op           0 B/op          0 allocs/op
BenchmarkUUID_V2     20000000          106 ns/op           0 B/op          0 allocs/op
BenchmarkUUID_V3      5000000          359 ns/op         144 B/op          4 allocs/op
BenchmarkUUID_V4      1000000         1376 ns/op          16 B/op          1 allocs/op
BenchmarkUUID_V5      3000000          424 ns/op         176 B/op          4 allocs/op
BenchmarkRedis          30000        46501 ns/op         176 B/op          5 allocs/op
BenchmarkSnowflake    5000000          244 ns/op           0 B/op          0 allocs/op
```

# Features
- Extremely fast
- Thread-safe
- Being unique across time
- Being unique within a data center
- Being unique globally if all data centers share the same data store, or they use different section IDs
- Being capable of generating 100M unique numbers in a single second
- Auto-renew when the low 40 bits are about to run out

# Install
``` bash
go get -u github.com/edwingeng/wuid
```

# Usage examples
### Redis
``` go
import "github.com/edwingeng/wuid/redis"

newClient := func() (redis.Cmdable, error) {
    var client redis.Cmdable
    // ...
    return client, nil
}

// Setup
g := NewWUID("default", nil)
_ = g.LoadH24FromRedis(newClient, "wuid")

// Generate
for i := 0; i < 10; i++ {
    fmt.Printf("%#016x\n", g.Next())
}
```

### MySQL
``` go
import "github.com/edwingeng/wuid/mysql"

newDB := func() (*sql.DB, error) {
    var db *sql.DB
    // ...
    return db, nil
}

// Setup
g := NewWUID("default", nil)
_ = g.LoadH24FromMysql(newDB, "wuid")

// Generate
for i := 0; i < 10; i++ {
    fmt.Printf("%#016x\n", g.Next())
}
```

### MongoDB
``` go
import "github.com/edwingeng/wuid/mongo"

newClient := func() (*mongo.Client, error) {
    var client *mongo.Client
    // ...
    return client, nil
}

// Setup
g := NewWUID("default", nil)
_ = g.LoadH24FromMongo(newClient, "test", "wuid", "default")

// Generate
for i := 0; i < 10; i++ {
    fmt.Printf("%#016x\n", g.Next())
}
```

### Callback
``` go
import "github.com/edwingeng/wuid/callback"

// Setup
g := wuid.NewWUID("default", nil)
g.LoadH24WithCallback(func() (uint64, error) {
    resp, err := http.Get("https://stackoverflow.com/")
    if resp != nil {
        defer resp.Body.Close()
    }
    if err != nil {
        return 0, err
    }

    bytes, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        return 0, err
    }

    fmt.Printf("Page size: %d (%#06x)\n\n", len(bytes), len(bytes))
    return uint64(len(bytes)), nil
})

// Generate
for i := 0; i < 10; i++ {
    fmt.Printf("%#016x\n", g.Next())
}
```

# Mysql table creation
``` sql
CREATE TABLE IF NOT EXISTS `wuid` (
    `h` int(10) NOT NULL AUTO_INCREMENT,
    `x` tinyint(4) NOT NULL DEFAULT '0',
    PRIMARY KEY (`x`),
    UNIQUE KEY `h` (`h`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

# Section ID
You can specify a custom section ID for the generated numbers with `wuid.WithSection` when you call `wuid.NewWUID`. The section ID must be in between `[1, 15]`. It occupies the highest 4 bits of the generated numbers.

# Best practices
- Use different keys/tables/docs for different purposes.
- Pass a logger to `wuid.NewWUID` and keep an eye on the warnings that include "renew failed", which means that the low 40 bits are about to run out in hours or hundreds of hours, and WUID fails to get a new number from your data store.
- Give a reasonalbe bound to the high 24 bits with `wuid.WithH24Verifier`.

# Special thanks
- [dustinfog](https://github.com/dustinfog)
