# UnevenRoundedWindow

An `NSWindow` with a different radius on each corner, which still adapts to the rounded corners of the display.

<video src="Media/demo.mp4" controls muted></video>

## Usage

Copy the `UnevenRoundedWindow` folder into your project:

```swift
let window = UnevenRoundedWindow(contentRect: rect, styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
window.cornerRadii = CornerRadii(topLeft: 6, topRight: 24, bottomLeft: 12, bottomRight: 20)
```

Set `cornerRadii` to `nil` to use the system's default radius.
