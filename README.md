# Swift Signal

**Swift Signal** is a Swift package that provides reactivity computation inspired by [Solid](https://www.solidjs.com/).

If you're familiar with Solid or signals, this package will be easy to get started with. The API design is mostly the same as Solid, except for language style differences.

The package is divided into two libraries: core library, and SwiftUI integration library.

> [!WARNING]
> This is an experimental package. Please use with caution if you are developing a production app.

## Getting Started

In your `Package.swift` manifest file, add the following dependency to your dependencies argument:

```swift
.package(url: "https://github.com/unixzii/swift-signal.git", branch: "main"),
```

Add the dependency to any targets you've declared in your manifest:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "SwiftSignal", package: "swift-signal"),
        // Also add this if you need SwiftUI integration.
        .product(name: "SwiftUISignal", package: "swift-signal"),
    ]
),
```

## Basic Usage

### The `Signal` Type

Signals are the most basic reactive primitive. They track a single value that changes over time. To create a signal, simply instantiate a `Signal` object:

```swift
let count = Signal(initialValue: 1)
let ready = Signal(initialValue: true)
```

You can call the signal as a function to read its current value:

```swift
print(count())
```

To set or update the value of a signal, call `set` or `update` method respectively:

```swift
count.set(42)
count.update { $0 + 1 }
```

### Effects

Effect is a general way to make arbitrary code ("side effects") run whenever its dependencies change. Effect creates a computation that runs the given closure in a tracking scope, thus automatically tracking its dependencies, and automatically reruns the closure whenever the dependencies update. To create an effect, call `createEffect` function:

```swift
let count = Signal(initialValue: 0)

let disposeEffect = createEffect {
    print(count())
    return nil
}

count.set(1)
```

Running the code will receive the below output:

```
0
1
```

To dispose (destroy) an effect, just invoke the returned closure of `createEffect`.

You can return a cleanup closure inside `createEffect`, the closure will be invoked every time the effect's dependencies change:

```swift
createEffect {
    return {
        print("cleanup code here")
    }
}
```

### Computed (Derived) Values

`createComputed` creates a computed (derived) value by executing the given closure. It returns a getter closure to retrieve the computed value. The compute closure will only get executed when its dependencies change.

```swift
let signalA = Signal(initialValue: 0)
let signalB = Signal(initialValue: 0)
let sum = createComputed {
    return signalA() + signalB()
}
```

This primitive is like [`createMemo`](https://www.solidjs.com/docs/latest/api#creatememo) in Solid. You can wrap time-consuming computations with `createComputed` to optimize the performance. It's usually a good practice to memorize computations that will execute more than once.

> [!NOTE]
> Unlike `createEffect`, computed closure will only get executed when it's read explicitly or observed by effects. Use `createEffect` if you want to react to the changes of signals or computed values.

## Using in SwiftUI

By importing `SwiftUISignal` module, you can integrate signals with SwiftUI. We will demonstrate it via a simple app.

First, create some reactive values:

```swift
let counterA = Signal(initialValue: 1)
let counterB = Signal(initialValue: 1)
let selectedCounter = Signal(initialValue: 1)
let message = createComputed {
    if selectedCounter() == 1 {
        return "Counter A: \(counterA())"
    } else {
        return "Counter B: \(counterB())"
    }
}
let sum = createComputed {
    return counterA() + counterB()
}
```

Then you can read it from SwiftUI views using `ObservedComputed`:

```swift
struct MessageView: View {
    @ObservedObject private var observedMessage = ObservedComputed {
        return message()
    }

    var body: some View {
        Text(observedMessage())
    }
}

struct SumView: View {
    @ObservedObject private var observedSum = ObservedComputed {
        return "Sum: \(sum())"
    }

    var body: some View {
        Text(observedSum())
    }
}
```

Every time the dependencies change, the dependent view will be updated automatically.

Finally, composite them in the root view:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            MessageView()
            SumView()

            Toggle("Selected Counter", isOn: .init(get: {
                return selectedCounter() == 2
            }, set: { newValue in
                selectedCounter.write(newValue ? 2 : 1)
            }))
            .toggleStyle(SwitchToggleStyle())

            HStack {
                Button("+A") {
                    counterA.update { $0 + 1 }
                }
                Button("+B") {
                    counterB.update { $0 + 1 }
                }
            }
        }
        .padding()
    }
}
```

You can play with the app, and explore the fine-grained reactivity by observing the updates of each view.

## Contributing

Pull requests are welcomed. At this stage, we are still evaluate the possibility of signals in Swift. Please open an issue before making significant changes.

## License

Licensed under MIT License, see [LICENSE](./LICENSE) for more information.
