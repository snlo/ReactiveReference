# ReactiveReference
> ###### 主流的响应式编程框架<a href= "https://github.com/ReactiveCocoa/ReactiveSwift" target="_blank">ReactiveSwift</a>、<a href= "https://github.com/ReactiveX/RxSwift" target="_blank">RxSwift</a>在iOS实际开发应用中的参考

[跳过](#build)

- 响应式编程（<a href= "https://en.wikipedia.org/wiki/Reactive_programming" target="_blank">Reactive Programming</a>）：是一种面向数据流和变化传播的声明式编程范式。可以很方便地表达静态或动态的数据流，而相关的计算模型会自动将**变化的值**通过数据流进行传播。

<p id = "build"></p>

## ReactiveSwift

**ReactiveSwift**提供了可组合的、声明性的和灵活的基本单元，这些基本单元是围绕**随时间流逝的数据流**的宏伟概念而构建的。

这些基本单元可用于统一表示常见的Cocoa和通用编程模式，这些模式从根本上来说是一种观察行为，例如：委托模式、回调、通知、控制动作、响应者链事件、[Futures/promises](https://en.wikipedia.org/wiki/Futures_and_promises)和[键值观察](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)（KVO）。

因为所有这些不同的机制都可以用*相同的*方式表示，所以很容易以声明的方式将它们组合在一起，而用较少的意大利面条式代码和状态来弥补差距。