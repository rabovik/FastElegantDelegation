
# FastElegantDelegation

© 2013 Yan Rabovik ([@rabovik][twitter] on twitter)

**FastElegantDelegation** solves 3 problems:

1. [Elegant single delegation][single] without annoying `respondsToSelector:` checks;
2. Implementing [multi-delegate pattern in your own code][multiDelegatePattern];
3. Assigning [multiple delegates for a single third-party source][multipleToSingle].

## Single delegation
Delegation is often implemented like this:

```objective-c
@protocol SomeDelegateProtocol <NSObject>
@optional
-(void)someOptionalDelegateMethod;
// ...
@end

@interface MyClass : NSObject
@property (nonatomic,weak) id<SomeDelegateProtocol> delegate;
@end

@implementation MyClass
-(void)someMethod{
    if ([self.delegate respondsToSelector:@selector(someOptionalDelegateMethod)]) {
        [self.delegate someOptionalDelegateMethod];
    }
}
// ...
@end
```

With **FastElegantDelegation** you may get rid of annoying `respondsToSelector:` checks:

```objective-c
@implementation MyClass
fed_use_proxy_for_delegate // just add this macro
-(void)someMethod{
    [self.delegate someOptionalDelegateMethod];
}
// ...
@end
```

#### How it works
* `fed_use_proxy_for_delegate` macro synthesizes `delegate` and `setDelegate` methods;
* `delegate` returns a `FEDProxy` class that forwards messages to the real delegate. If delegate does not respond to an optional protocol method, proxy just does nothing like when the message is sent to `nil`.

#### Custom delegate names
You may use any name you like for the delegate property, but you should specify getter and setter names in the macro:
```objective-c
@interface MyClass : NSObject
@property (nonatomic,weak) id<SomeDelegateProtocol> myCoolDelegate;
@end

@implementation MyClass
fed_use_proxy_for_property(myCoolDelegate,setMyCoolDelegate)
// ...
@end
```

#### Return values
Delegate methods may return any value.
```objective-c
@implementation MyClass
fed_use_proxy_for_delegate
-(void)someMethod{
    BOOL return = self.delegate ? [self.delegate methodReturningBOOL] : YES; // YES by default
}
// ...
@end
```

#### Safeness
If the property is declared as `weak` then delegate is not retained. When delegate deallocates, proxy is automatically deallocated too. You will never get into a situation when proxy returned by `self.delegate` is alive, but real delegate is already deallocated.

`FEDProxy` does not break required/optional paradigm. If you try to call required method that is not implemented in the delegate, you'll get an exception.

#### Strong delegates
If for some reason you need to declare delegate as strong, it is OK. `FEDProxy` will be strongly stored in the ivar and will retain real delegate.

```objective-c
@interface MyClass : NSObject
@property (nonatomic, strong) id<SomeDelegateProtocol> myStrongDelegate;
@end
``` 

#### Performance
`FEDProxy` uses fast message forwarding (via `forwardingTargetForSelector:`) and a cache to prevent multiple internal `respondsToSelector:` checks.

## Multi-delegate pattern in your own code
With `fed_synthesize_multi_delegates` macro you may implement multi-delegate pattern in your own class so that the clients of your class may easily add and remove delegates.

Example:
```objective-c
@class MyClass;
@protocol MyClassDelegate <NSObject>
-(void)myClassDidStartSomeJob;
@end

@interface MyClass : NSObject
-(void)addDelegate:(id<MyClassDelegate>)delegate;
-(void)removeDelegate:(id<MyClassDelegate>)delegate;
@end

@implementation MyClass
fed_synthesize_multi_delegates(MyClassDelegate)
-(void)someJob{
    [self.delegates myClassDidStartSomeJob]; // will be sent to each delegate
}
@end
```
`fed_synthesize_multi_delegates ` synthesizes `addDelegate:`, `removeDelegate:` and `delegates` methods.

#### Custom method names
You can name methods as you like. For example you may use `listener` name instead of `delegate`:

```objective-c
@class MyClass;
@protocol MyClassListener <NSObject>
-(void)myClassDidStartSomeJob;
@end

@interface MyClass : NSObject
-(void)addListener:(id<MyClassListener>)delegate;
-(void)removeListener:(id<MyClassListener>)delegate;
@end

@implementation MyClass
fed_synthesize_multiproxy(MyClassListener, addListener, removeListener, listeners)
-(void)someJob{
    [self.listeners myClassDidStartSomeJob];
}
@end
```

#### Return values
If a method returns a value the return value will be from the first delegate in the list that responds to the selector.

## Multiple delegates for a single third-party source

`FEDMultiProxy` class is a `NSProxy` subclass that allows to add multiple delegates to a single third-party source.

For example, you may assign multiple delegates to a UIScrollView:

```objective-c
__typeof(self) __weak weakSelf = self;
FEDMultiProxy *multiProxy = [FEDMultiProxy proxyWithDelegates:@[firstDelegate, secondDelegate]
                                                     protocol:@protocol(UIScrollViewDelegate)
                                          retainedByDelegates:YES
                                                    onDealloc:^{
                                                        weakSelf.scrollView.delegate = nil;
                                                    }];
self.scrollView.delegate = multiProxy;
```

You do not need to keep a strong reference to `FEDMultiProxy` object. It is automatically retained by each delegate and will be deallocated when all delegates die. `onDealloc` block will be called at that moment and you may set targets delegate to `nil` there. 

## CocoaPods
Add `FastElegantDelegation ` to your _Podfile_.

## Requirements
* iOS 5.0+
* ARC
* [MAObjCRuntime][MAObjCRuntime]

## License
MIT License.

[twitter]: https://twitter.com/rabovik
[single]: #single-delegation
[multipleToSingle]: #multiple-delegates-for-a-single-third-party-source
[multiDelegatePattern]: #multi-delegate-pattern-in-your-own-code
[MAObjCRuntime]: https://github.com/mikeash/MAObjCRuntime
