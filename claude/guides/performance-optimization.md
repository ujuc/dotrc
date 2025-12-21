# Performance Optimization Guide

<meta>
Document: performance-optimization.md
Role: Performance Optimization Reference
Priority: Medium
Source: https://abseil.io/fast/hints.html
Authors: Jeff Dean, Sanjay Ghemawat
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document is a reference guide that summarizes language-independent, general-purpose performance optimization principles based on Google's performance optimization guide.
</context>

<your_responsibility>
As Optimization Expert, you must:
- **Measure before optimizing**: Base decisions on profiling results, not guesses
- **Focus on the 3%**: Concentrate optimization efforts only on actual bottlenecks
- **Consider trade-offs**: Evaluate the impact of optimization on readability and maintainability
- **Document changes**: Record optimization reasons and performance improvement metrics
</your_responsibility>

## 1. Core Philosophy

> "We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. **But we should not pass up our opportunities in that critical 3%.**" — Donald Knuth

### Why You Shouldn't Delay Performance Work

1. **Flat profiles**: Late optimization faces situations with no clear hotspots
2. **External code**: Library users cannot easily optimize other teams' code
3. **Cost of change**: System-wide changes become difficult when heavily used
4. **Opportunity cost**: Missing easy performance improvements requires expensive infrastructure solutions

---

## 2. Computational Cost Estimation

### Hardware Operation Cost Reference Table

| Operation | Time |
|-----------|------|
| L1 cache reference | 0.5 ns |
| L2 cache reference | 3 ns |
| Branch misprediction | 5 ns |
| Mutex lock/unlock (uncontended) | 15 ns |
| Main memory reference | 50 ns |
| SSD random read | 16,000 ns |
| Disk seek | 5,000,000 ns |
| Network round trip (same datacenter) | 500,000 ns |

### Back-of-the-envelope Calculations

Calculate approximate costs before implementation to compare algorithm approaches:

**Example**: Sorting 1 billion items
- Memory bandwidth cost: ~7.5 seconds (based on 16GB/s)
- Branch misprediction cost: ~75 seconds (30 billion comparisons, 50% misprediction)
- **Conclusion**: Branch misprediction dominates → Focus optimization here

---

## 3. Measurement and Profiling

### Principles

- **Measure first, optimize later**: Intuition can be wrong
- Use profiling tools to identify actual bottlenecks
- Always measure before and after optimization to verify effectiveness

### Dealing with Flat Profiles

When there are no clear bottlenecks:
- Accumulate multiple 1% improvements
- Look for loops higher up the call stack
- Identify structural inefficiencies
- Replace overly generic code with specialized versions
- Reduce allocation count
- Identify cache miss patterns using hardware performance counters

---

## 4. API Design

### Bulk Operations

Reduce overhead with batch processing instead of individual operations:

```
// Before: Individual lookups
for each key in keys:
    result = lookup(key)

// After: Bulk lookup
results = lookupMany(keys)
```

**Benefits**: Reduced API call count, algorithm optimization opportunities, distributed fixed costs

### View Types

Pass data "views" as function arguments to prevent copying:
- String views (reference to original string)
- Array slices (reference to part of original array)
- Function references (prevent function object copying)

### Pass Pre-computed Values

Pass already-computed values as arguments to prevent redundant computation:

```
// Before: Compute current time internally
recordEvent(eventName, data)

// After: Pass value caller already has
now = getCurrentTime()
recordEvent(eventName, data, now)
```

### Thread-Compatible vs Thread-Safe

- **Thread-Compatible**: External synchronization (caller's responsibility)
- **Thread-Safe**: Internal synchronization (always incurs lock cost)

Consider Thread-Compatible as default so callers who don't need thread safety can avoid unnecessary costs

---

## 5. Algorithm Improvements

Algorithm improvements provide the greatest performance gains.

### Complexity Improvement Examples

| Situation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Sorted list intersection | O(N log N) | O(N) hash table | ~21% speedup |
| Graph cycle detection | Cost per edge | Batch add in reverse postorder | Significant improvement |

### Data Structure Selection

Choosing the right data structure for the problem is key:
- **Frequent lookups**: Hash table O(1) vs sorted list O(log N)
- **Range queries**: Sorted structures (trees, sorted arrays)
- **Order preservation needed**: Linked lists or sorted structures

---

## 6. Memory Representation

### Compact Data Structures

- Reorder fields to minimize padding
- Use smaller numeric types when appropriate (64-bit → 32-bit)
- Specify explicit sizes for enums
- Place frequently accessed fields together
- Separate hot and cold fields

### Indices Instead of Pointers

On 64-bit systems, pointers are 8 bytes. Using 32-bit indices:
- 50% memory savings
- Better cache locality with contiguous storage

### Prefer Contiguous Storage

Prefer array-based structures over node-based structures (linked lists, trees):
- Better cache behavior
- Lower allocator overhead
- Memory prefetch utilization

### Nested Maps → Composite Keys

```
// Before: 2-level lookup
map[category][item]

// After: 1-level lookup
map[(category, item)]
```

### When Domain is Small: Arrays Instead of Maps

When keys are small integers or enums:
```
// Before
map[payloadType] = clockRate

// After
clockRates[payloadType] = rate  // Array index access
```

### Bit Vectors Instead of Sets

When domain can be represented as small integers:
```
// Before: Hash set
zones = HashSet<ZoneId>

// After: Bit vector (26-31% performance improvement)
zones = BitVector<256>
```

---

## 7. Allocation Optimization

### Avoid Unnecessary Allocations

```
// Before: Create new object every time
info = newObject() if data else createEmpty()

// After: Reuse static empty object
EMPTY = createEmpty()  // Create only once
info = newObject() if data else EMPTY
```

### Pre-size Containers

```
// Before: Potentially N reallocations
for i in range(n):
    list.append(item)

// After: Single allocation
list = createWithCapacity(n)
for i in range(n):
    list.append(item)
```

### Avoid Copying

- Prefer move over copy
- Store pointers/indices instead of full objects in temporary structures
- Use regular sort instead of stable sort (reduces internal copying)

### Reuse Temporary Objects

```
// Before: Create every iteration
for item in items:
    record = createRecord()
    processRecord(record)

// After: Reuse
record = createRecord()
for item in items:
    record.clear()
    processRecord(record)
```

---

## 8. Avoiding Unnecessary Work

### Fast Path for Common Cases

```
// Fast path for 90% of cases
if isCommonCase(input):
    return fastPath(input)
// General path for remaining 10%
return slowPath(input)
```

### Pre-compute Expensive Information

```
// Before: Compute every time
if isExpensive(node):
    doSomething()

// After: Pre-compute and store
struct Node:
    isExpensive: bool  // Computed at creation

if node.isExpensive:
    doSomething()
```

### Loop-Invariant Code Motion

```
// Before: Compute every iteration
for i in range(n):
    limit = calculateLimit(data)  // Invariant
    process(i, limit)

// After: Move outside loop
limit = calculateLimit(data)
for i in range(n):
    process(i, limit)
```

### Lazy Evaluation

```
// Before: Always compute
expensiveResult = computeExpensive()
if condition:
    use(expensiveResult)

// After: Compute only when needed
if condition:
    expensiveResult = computeExpensive()
    use(expensiveResult)
```

### Use Caching

Cache results using input fingerprint (hash) as key:
```
cache = {}
fingerprint = hash(input)
if fingerprint in cache:
    return cache[fingerprint]
result = expensiveComputation(input)
cache[fingerprint] = result
return result
```

### Reduce Logging/Statistics Cost

```
// Before: Check log level in hot loop
for item in items:
    if isDebugEnabled():  // Check every time
        log(item)

// After: Check once outside loop
shouldLog = isDebugEnabled()
for item in items:
    if shouldLog:
        log(item)
// Performance improvement: 8-10%
```

**Statistics Collection Options**:
- Remove low-value statistics
- Sample events (e.g., 1 per 32)
- Use powers of 2 for fast modulo operations

---

## 9. Code Size

### Negative Effects of Large Code

- Long compile/link times
- Bloated binaries
- Increased memory usage
- Instruction cache pressure
- Branch predictor burden

### Careful Inlining

```
// Before: Inline at all call sites
inline complexFunction() { ... }

// After: Inline only hot path, separate function for slow path
inline fastPath():
    if (commonCase):
        return quickResult
    return slowPathHelper()  // Separate function call

slowPathHelper():  // Not inlined
    ... complex logic ...
```

### Minimize Template/Generic Instantiation

```
// Before: Separate instance per boolean
template<bool Flag>
process() { ... }

// After: Consolidated with runtime parameter
process(bool flag) { ... }
// Instance count: 287 → 143 (50% reduction)
```

### Bulk Initialization

```
// Before: Individual insertions (188KB code)
map[key1] = value1
map[key2] = value2
...

// After: Batch insertion (360 bytes)
map.insertAll([
    (key1, value1),
    (key2, value2),
    ...
])
```

---

## 10. Parallelization and Synchronization

### Leverage Parallelism

Modern machines have many cores. Distribute parallelization costs by splitting work into batches:
- 4-way parallelization achieved 3.6x speedup in one case
- **Caution**: Parallelization may not help if CPU or memory bandwidth is saturated

### Distribute Lock Acquisition

```
// Before: Acquire lock for each node
release(node):
    for child in node.children:
        release(child)  // Each acquires lock
    pool.delete(node)

// After: Acquire once for entire tree
release(node):
    lock(poolLock)
    releaseInternal(node)

releaseInternal(node):
    for child in node.children:
        releaseInternal(child)  // Proceed without lock
    pool.delete(node)
```

### Minimize Critical Sections

```
// Before: Expensive operations inside lock (RPC, file I/O)
lock(mutex):
    data = prepare()
    sendRPC(data)  // Slow operation

// After: Only decisions inside lock, execution outside
lock(mutex):
    shouldSend = checkCondition()
    data = prepareData()
if shouldSend:
    sendRPC(data)  // Execute outside lock
```

### Reduce Contention with Sharding

```
class ShardedCache:
    SHARD_COUNT = 16
    shards = [Cache() for _ in range(SHARD_COUNT)]

    lookup(key):
        shardIndex = hash(key) % SHARD_COUNT
        return shards[shardIndex].lookup(key)
```

16-way sharding improves throughput ~2x in multithreaded environments

### Prevent False Sharing

Place mutable data accessed by different threads on separate cache lines:

```
// Before: May be on same cache line
counter1: int
counter2: int  // Accessed by different thread

// After: Cache line aligned
counter1: int (aligned to cache line)
padding: bytes[56]  // Fill 64-byte cache line
counter2: int (aligned to cache line)
```

---

## Additional Resources

- "Optimizing software in C++" - Agner Fog
- "Understanding Software Dynamics" - Richard L. Sites
- "Programming Pearls" - Jon Bentley
- "Hacker's Delight" - Henry S. Warren
- "Computer Architecture: A Quantitative Approach" - Hennessy & Patterson
- [Performance tips of the week](https://abseil.io/fast/) - Abseil

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document
- [Performance](./performance.md) - Basic optimization guidelines
- [Technical Standards](./technical-standards.md) - Architecture and code quality
