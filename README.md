
# FastElegantDelegation

Sorry, README is not fully ready yet. :(

**FastElegantDelegation** solves 3 problems:

1. Elegant single delegation without annoying `respondsToSelector:` checks;
2. Assigning multiple delegates for a single third-party source;
3. Implementing multi-delegate pattern in your own code.


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
fed_use_proxy_for_delegate
-(void)someMethod{
    [self.delegate someOptionalDelegateMethod];
}
// ...
@end
```

## Multiple delegates for a single third-party source
…

## Multi-delegate pattern in your own code
…

## CocoaPods
Add `FastElegantDelegation ` to your _Podfile_. _(not ready yet)_

## Requirements
* iOS 5.0+
* ARC
* MAObjcRuntime

## License
MIT License.
