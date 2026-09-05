---
name: prefer-guava
description: 编码时优先使用 Guava 类库的场景化提示。覆盖不可变集合、Multimap/BiMap/Table 专属集合、Preconditions 参数校验、CacheBuilder 本地缓存、RateLimiter 限流、ListenableFuture 异步、EventBus 事件、Splitter/Joiner 字符串、Hashing/BaseEncoding、Range 区间等场景。触发：Guava、ImmutableList、ImmutableMap、Multimap、BiMap、Table、Multiset、Preconditions、CacheBuilder、RateLimiter、ListenableFuture、EventBus、Splitter、Joiner、Hashing、BaseEncoding、Range、TypeToken、Stopwatch。
metadata:
  author: HuaTalk
  version: "1.0.0"
  category: methodology
  status: experimental
---

# Prefer Guava — Guava 类库使用场景提示词

## 核心原则

Java 编码时遇到下列场景，优先用 Guava 的成熟工具，不手写轮子。使用前确认 Guava 已在依赖中；文末列出避免误用的场景。

## 1. 集合与不可变

| 如果... | 用... |
|---|---|
| 需要不可变、线程安全的集合 | `ImmutableList` / `ImmutableSet` / `ImmutableMap`（`of` / `copyOf` / `builder`） |
| 一个 key 对应多个 value | `Multimap`（`ArrayListMultimap`、`LinkedHashMultimap` 保序） |
| 需要双向 key-value 查询 | `BiMap`（`HashBiMap`，`inverse()` 反转） |
| 需要统计元素出现次数 | `Multiset`（`HashMultiset`，`count()` 即频率表） |
| 需要行×列双 key 索引 | `Table`（`HashBasedTable`，`row` / `column` / `cell` 视图） |
| 需要快速构造常用集合 | `Lists.newArrayList` / `Sets.newHashSet` / `Maps.newHashMap` |
| 需要集合交并差补运算 | `Sets.union` / `intersection` / `difference` / `complementOf` |

## 2. 参数校验

- 方法入口校验参数 → `Preconditions.checkArgument` / `checkNotNull` / `checkState`，替代手写 if + throw `IllegalArgumentException` / `NullPointerException`
- 后置条件或不变量断言 → `Verify.verify`（区别于面向调用方的 `Preconditions`）

## 3. 字符串处理

| 场景 | 用 |
|---|---|
| 按分隔符拆分并去空白/空串 | `Splitter.on(';').trimResults().omitEmptyStrings()`（`String.split` 做不了这些修饰） |
| 连接列表且跳过 null | `Joiner.on(',').skipNulls()` / `useForNull("")` |
| 判断空串、补齐、重复 | `Strings.isNullOrEmpty` / `padStart` / `padEnd` / `repeat` |
| 按字符类匹配或裁剪 | `CharMatcher`（`whitespace()`、`isDigit()`、`anyOf("abc")`、`trimFrom`） |

## 5. 并发与异步

| 场景 | 用 |
|---|---|
| QPS 限流 | `RateLimiter.create(permitsPerSecond)` + `tryAcquire()` |
| 异步任务链式回调 | `ListenableFuture` + `Futures.addCallback` / `transform` / `catching` |
| 互斥与条件等待 | `Monitor`（比裸 `synchronized` 更可控） |
| 高并发计数 | `AtomicLongMap` |

## 6. 事件驱动

- 模块间解耦的发布订阅 → `EventBus`：`@Subscribe` 标注监听方法，`eventBus.post(event)`

## 7. 哈希与编码

- 快速哈希（含一致性哈希） → `Hashing.murmur3_128()` / `sha256()` / `md5()`，`HashCode`
- base64 / base32 编解码 → `BaseEncoding.base64()` / `base32()`（无需引入 commons-codec）

## 8. 区间运算

- 语义化区间判断 → `Range.closed` / `open` / `atLeast` / `atMost` / `contains` / `intersects`
- 一组不相交区间的并集查询 → `RangeSet` / `RangeMap`

## 9. 对象与比较器

- 简洁 `toString` → `MoreObjects.toStringHelper(clazz).add("field", value)`
- 多字段链式排序 → `ComparisonChain.start().compare(a, b).compare(c, d)`
- null 安全的相等判断 → `Objects.equal`
- 链式排序规则 → `Ordering.natural().reverse().onResultOf(...).compound(...)`

## 10. 泛型反射

- 运行时捕获泛型类型参数 → `TypeToken`（反序列化、类型校验常见）

## 11. 计时

- 方法耗时统计 → `Stopwatch.createStarted()` + `elapsed(TimeUnit.MILLISECONDS)`

## 12. 数学

- 溢出安全运算 → `IntMath.checkedAdd` / `checkedMultiply`，`IntMath.pow`
- 浮点精确舍入与判定 → `DoubleMath.roundToLong` / `isMathematicalInteger`

## 避免误用的场景

- **集合直接构造**：Java 9+ 优先 `List.of` / `Set.of` / `Map.of`，Guava 用于 JDK 缺失的能力（不可变转换、专属集合、builder）
- **文件读写**：优先 `java.nio`（`Files.readAllBytes` / `write`），Guava 的 `Files` 工具逐步迁向 NIO
- **已废弃 API**：`FluentIterable`、`Function`、`Predicate`、`Range.greaterThan` 等已弃用，改用 Java Stream 与 Java 8+ 语法
- **依赖决策**：仅需单点能力（如 `BaseEncoding`）时，评估是否值得引入整个 Guava 依赖
