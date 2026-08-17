---
name: prefer-pure-function
description: 编码时优先纯函数与不可变风格，避免原地修改、使用纯函数命名方式、隔离可变性。触发：纯函数、不可变、函数式风格。
---

# Prefer Pure Function — 优先纯函数与不可变风格

## 核心原则

当前Skill的出发点是AI-Coding的很多函数都不注重提取不可变性，常常在函数最后放副作用。
写新方法时先问「返回 void 还是新实例？」
写代码时考虑能否隔离可变性，纯函数和副作用隔离，只在上帝方法中组合两者。
纯函数可以放宽要求，日志可以容忍，从黑盒角度考虑，内部的状态只要在外部不能观察到就视为纯函数。
有时可以结合返回不可变对象：线程安全、debug友好、可读性好。

```python
if 返回的是新增的内容 && 可以由当前需求控制：
	优先使用不可变对象
if 返回的对象和原有可变语义相结合：
	原有语义即可  
```

## 函数名参考

采用纯函数常用的函数命名模式，可参考：Plus, prepend / append, with / updated / copy, stream, sorted, minus, removed, to* / map / flatMap, getOrElse / orElse, recover / recoverWith, as*

## 可接受原地修改的例子

- 对象本身的职责就是状态容器（原子容器、连接池、缓存）——这些用不着伪装成纯函数
- 全局状态对象、可变相关的设计模式（如状态模式）
- 已有契约或者历史代码： DTO、POJO 等对象
