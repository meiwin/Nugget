//
//  Event.m
//  Pie
//
//  Created by Meiwin Fu on 1/12/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import "NugEvent.h"
#import "NugWeakProxy.h"
#import "NugWeakProxySubclass.h"

NSString * NugEventInfoKey = @"event_info";

#pragma mark - NugEventSubscriberProxy
@class NugEventSubscriberProxy;
@protocol NugEventSubscriberProxyDelegate
@optional
- (void)eventSubscriberProxyDidReceiveNotificationButNotInTargetThread:(NugEventSubscriberProxy *)proxy;
- (void)eventSubscriberProxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy;
@end

@interface NugEventSubscriberProxy : NugWeakProxy
@property (nonatomic, strong, readonly) NSString * identifier;
@property (nonatomic, weak) id<NugEventSubscriberProxyDelegate> delegate;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSThread * targetThread;
+ (instancetype)eventSubscriberWithTarget:(id)target selector:(SEL)selector targetThread:(NSThread *)targetThread;
- (void)invoke:(NSNotification *)notification;
- (void)processNotifications;
@end

@interface NugEventSubscriberProxy () <NugEventSubscriberProxyDelegate>
{
  struct {
    int didReceiveNotificationButNotInTargetThread;
    int didBecomeInvalid;
  } _delegateFlags;
  
  NSMutableArray * _notifications;
  NSLock * _lock;
  
}
- (void)setSelector:(SEL)selector;
- (void)setTargetThread:(id)targetThread;
@end

@implementation NugEventSubscriberProxy
+ (instancetype)eventSubscriberWithTarget:(id)target selector:(SEL)selector targetThread:(NSThread *)targetThread
{
  NugEventSubscriberProxy * proxy = [[NugEventSubscriberProxy alloc] init];
  [proxy setTarget:target];
  proxy.selector = selector;
  proxy.targetThread = targetThread;
  return proxy;
}
- (id)init
{
  self = [super init];
  if (self)
  {
    _identifier = [[NSUUID UUID] UUIDString];
    _notifications = [NSMutableArray array];
    _lock = [[NSLock alloc] init];
  }
  return self;
}
- (void)processNotifications
{
  [_lock lock];
  NSArray * notifications = [_notifications copy];
  [_notifications removeAllObjects];
  [_lock unlock];
  
  id safeTarget = self.safeTarget;
  if (safeTarget)
  {
    [notifications enumerateObjectsUsingBlock:^(NSNotification * notification, NSUInteger idx, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [safeTarget performSelector:_selector withObject:notification];
#pragma clang diagnostic pop
    }];
  }
  else
  {
    [self didBecomeInvalid];
  }
}
- (void)invoke:(NSNotification *)notification
{
  if (_targetThread == nil)
  {
    id safeTarget = self.safeTarget;
    if (safeTarget)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [safeTarget performSelector:_selector withObject:notification];
#pragma clang diagnostic pop
    }
    else
    {
      [self didBecomeInvalid];
    }
  }
  else
  {
    [_lock lock];
    [_notifications addObject:notification];
    [_lock unlock];
    
    if ([NSThread currentThread] == _targetThread)
    {
      [self processNotifications];
    }
    else
    {
      [self didReceiveNotificationButNotInTargetThread];
    }
  }
}
#pragma mark Private Methods
- (void)setSelector:(SEL)selector
{
  _selector = selector;
}
- (void)setTargetThread:(id)targetThread
{
  _targetThread = targetThread;
}
#pragma mark Delegate
- (void)setDelegate:(id<NugEventSubscriberProxyDelegate>)delegate
{
  _delegate = delegate;
  _delegateFlags.didReceiveNotificationButNotInTargetThread = _delegate && [(id)_delegate respondsToSelector:@selector(eventSubscriberProxyDidReceiveNotificationButNotInTargetThread:)];
  _delegateFlags.didBecomeInvalid = _delegate && [(id)_delegate respondsToSelector:@selector(eventSubscriberProxyDidBecomeInvalid:)];
}
- (void)didReceiveNotificationButNotInTargetThread
{
  if (_delegateFlags.didReceiveNotificationButNotInTargetThread) [_delegate eventSubscriberProxyDidReceiveNotificationButNotInTargetThread:self];
}
- (void)didBecomeInvalid
{
  if (_delegateFlags.didBecomeInvalid) [_delegate eventSubscriberProxyDidBecomeInvalid:self];
}

@end

#pragma mark - NugEventInternal
@class NugEventInternal;
@protocol EventInternalDelegate
@optional
- (void)eventInternal:(NugEventInternal *)eventInternal proxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy;
@end

@interface NugEventInternal : NSObject <NSMachPortDelegate>
{
  NSMutableDictionary * _subscribers;
  NSMutableSet * _subscriberIdsWithPendingNotifications;
  struct {
    int proxyDidBecomeInvalid;
  } _delegateFlags;
}
@property (nonatomic, strong, readonly) NSThread * thread;
@property (nonatomic, strong, readonly) NSMachPort * notificationPort;
@property (nonatomic, strong, readonly) NSLock * notificationLock;
@property (nonatomic, weak) id<EventInternalDelegate> delegate;
- (instancetype)initWithThreadName:(NSString *)threadName;
- (instancetype)initWithThread:(NSThread *)thread;
@end

@implementation NugEventInternal
- (id)initWithThreadName:(NSString *)threadName
{
  self = [super init];
  if (self)
  {
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadEntryPoint:) object:nil];
    _thread.name = threadName;
    [_thread start];
  }
  return self;
}
- (id)initWithThread:(NSThread *)thread
{
  self = [super init];
  if (self)
  {
    _thread = thread;
    if ([NSThread currentThread] == _thread)
    {
      [self threadEntryPoint:nil];
    }
    else
    {
      [self performSelector:@selector(threadEntryPoint:) onThread:_thread withObject:nil waitUntilDone:NO];
    }
  }
  return self;
}
- (void)threadEntryPoint:(id)__unused object
{
  NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
  _notificationPort = [[NSMachPort alloc] init];
  _notificationPort.delegate = self;
  [runLoop addPort:_notificationPort forMode:NSRunLoopCommonModes];
  _notificationLock = [[NSLock alloc] init];
  _subscribers = [NSMutableDictionary dictionary];
  _subscriberIdsWithPendingNotifications = [NSMutableSet set];
  if (runLoop.currentMode == nil)
  {
    [runLoop run];
  }
}

#pragma mark Delegate
- (void)setDelegate:(id<EventInternalDelegate>)delegate
{
  _delegate = delegate;
  _delegateFlags.proxyDidBecomeInvalid = _delegate && [(id)_delegate respondsToSelector:@selector(eventInternal:proxyDidBecomeInvalid:)];
}
- (void)proxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy
{
  if (_delegateFlags.proxyDidBecomeInvalid) [_delegate eventInternal:self proxyDidBecomeInvalid:proxy];
}

#pragma mark NSMachPortDelegate
- (void)handleMachMessage:(void *)msg
{
  [_notificationLock lock];
  NSDictionary * subscribers = [_subscribers copy];
  NSSet * subscribersWithPendingNotifications = [_subscriberIdsWithPendingNotifications copy];
  [_subscriberIdsWithPendingNotifications removeAllObjects];
  [_notificationLock unlock];
  
  [subscribersWithPendingNotifications enumerateObjectsUsingBlock:^(NSString * subscriberId, BOOL *stop) {
    NugEventSubscriberProxy * proxy = subscribers[subscriberId];
    [proxy processNotifications];
  }];
}

#pragma mark EventSubscriberProxyDelegate
- (void)eventSubscriberProxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy
{
  [_notificationLock lock];
  [_subscribers removeObjectForKey:proxy.identifier];
  [_notificationLock unlock];
  [self proxyDidBecomeInvalid:proxy];
}
- (void)eventSubscriberProxyDidReceiveNotificationButNotInTargetThread:(NugEventSubscriberProxy *)proxy
{
  [_notificationLock lock];
  [_subscriberIdsWithPendingNotifications addObject:proxy.identifier];
  _subscribers[proxy.identifier] = proxy;
  [_notificationLock unlock];
  [_notificationPort sendBeforeDate:[NSDate date]
                         components:nil
                               from:nil
                           reserved:0];
}
@end

#pragma mark - NugEventRegistry
@interface NugEventRegistry : NSObject
{
  NSLock * _registryLock;
  NSMutableDictionary * _registries;
}
+ (instancetype)sharedInstance;
- (NugEventInternal *)eventInternalNamed:(NSString *)name;
@end

@implementation NugEventRegistry
+ (instancetype)sharedInstance
{
  static NugEventRegistry * _sharedRegistry;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedRegistry = [[NugEventRegistry alloc] init];
  });
  return _sharedRegistry;
}
- (instancetype)init
{
  self = [super init];
  if (self)
  {
    _registryLock = [[NSLock alloc] init];
    _registries = [NSMutableDictionary dictionaryWithCapacity:5];
  }
  return self;
}
- (NugEventInternal *)eventInternalNamed:(NSString *)name
{
  NugEventInternal * eventInternal = _registries[name];
  if (!eventInternal)
  {
    [_registryLock lock];
    eventInternal = [[NugEventInternal alloc] initWithThreadName:name];
    _registries[name] = eventInternal;
    [_registryLock unlock];
  }
  return eventInternal;
}
@end

#pragma mark - Event
@interface NugEvent () <NugEventSubscriberProxyDelegate, EventInternalDelegate>
{
  NSLock * _lock;
  NSMutableArray * _proxies;
}
@end

@implementation NugEvent

- (id)init
{
  self = [super init];
  if (self)
  {
    _proxies = [NSMutableArray arrayWithCapacity:100];
    _lock = [[NSLock alloc] init];
  }
  return self;
}
+ (instancetype)defaultEvent
{
  static NugEvent * _defaultEvent;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _defaultEvent = [[NugEvent alloc] init];
  });
  return _defaultEvent;
}

#pragma mark Private
- (NugEventInternal *)eventInternalForMainThread
{
  static NugEventInternal * _mainEventInternal;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _mainEventInternal = [[NugEventInternal alloc] initWithThread:[NSThread mainThread]];
    _mainEventInternal.delegate = self;
  });
  return _mainEventInternal;
}

#pragma mark Private Methods
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector thread:(NugEventThread)thread threadName:(NSString *)threadName
{
  NSThread * threadObject = nil;
  id<NugEventSubscriberProxyDelegate> proxyDelegate = nil;
  if (thread == NugEventThreadCurrent)
  {
    proxyDelegate = self;
    threadObject = nil;
  }
  else if (thread == NugEventThreadMain)
  {
    proxyDelegate = (id<NugEventSubscriberProxyDelegate>)[self eventInternalForMainThread];
    threadObject = [NSThread mainThread];
  }
  else if (thread == NugEventThreadBackground)
  {
    NugEventInternal * eventInternal = [[NugEventRegistry sharedInstance] eventInternalNamed:@"com.pie.eventInternal.background"];
    eventInternal.delegate = self;
    proxyDelegate = (id<NugEventSubscriberProxyDelegate>)eventInternal;
    threadObject = eventInternal.thread;
  }
  else if (thread == NugEventThreadUserDefined)
  {
    NugEventInternal * eventInternal = [[NugEventRegistry sharedInstance] eventInternalNamed:threadName];
    eventInternal.delegate = self;
    proxyDelegate = (id<NugEventSubscriberProxyDelegate>)eventInternal;
    threadObject = eventInternal.thread;
  }
  else
  {
    NSAssert1(NO, @"Invalid event thread: %d", thread);
  }

  NugEventSubscriberProxy * proxy = [NugEventSubscriberProxy eventSubscriberWithTarget:target selector:selector targetThread:threadObject];
  proxy.delegate = proxyDelegate;
  [[NSNotificationCenter defaultCenter] addObserver:proxy selector:@selector(invoke:) name:name object:object];
  
  [_lock lock];
  [_proxies addObject:proxy];
  [_lock unlock];
}

#pragma mark Publishing
- (NSDictionary *)notificationUserInfo:(id)data
{
  if (!data) return @{};
  return @{ NugEventInfoKey : data };
}
- (void)publish:(NSString *)name sender:(id)sender userInfo:(id)userInfo
{
  NSNotification * notification = [[NSNotification alloc] initWithName:name object:sender userInfo:[self notificationUserInfo:userInfo]];
  [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)publishEventually:(NSString *)name sender:(id)sender userInfo:(id)userInfo
{
  NSNotification * notification = [[NSNotification alloc] initWithName:name object:sender userInfo:[self notificationUserInfo:userInfo]];
  [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                             postingStyle:NSPostASAP
                                             coalesceMask:NSNotificationCoalescingOnName|NSNotificationCoalescingOnSender
                                                 forModes:@[ NSRunLoopCommonModes ]];
}

#pragma mark Subscription
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector
{
  [self subscribe:name object:object target:target selector:selector thread:NugEventThreadCurrent threadName:nil];
}
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector thread:(NugEventThread)thread
{
  [self subscribe:name object:object target:target selector:selector thread:thread threadName:nil];
}
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector threadName:(NSString *)threadName
{
  [self subscribe:name object:object target:target selector:selector thread:NugEventThreadUserDefined threadName:threadName];
}
- (void)unsubscribe:(id)target
{
  [_lock lock];
  NSMutableArray * proxiesToRemove = [NSMutableArray array];
  [_proxies enumerateObjectsUsingBlock:^(NugEventSubscriberProxy * proxy, NSUInteger idx, BOOL *stop) {
    if (proxy.safeTarget == nil || proxy.safeTarget == target) // proxy.safeTarget == nil, take the opportunity to clean up
    {
      [proxiesToRemove addObject:proxy];
      [[NSNotificationCenter defaultCenter] removeObserver:proxy];
    }
  }];
  [_proxies removeObjectsInArray:proxiesToRemove];
  [_lock unlock];
}

#pragma mark EventSubscriberProxyDelegate
- (void)eventSubscriberProxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy
{
  [[NSNotificationCenter defaultCenter] removeObserver:proxy];
  [_lock lock];
  [_proxies removeObject:proxy];
  [_lock unlock];
}

#pragma mark EventInternalDelegate
- (void)eventInternal:(NugEventInternal *)eventInternal proxyDidBecomeInvalid:(NugEventSubscriberProxy *)proxy
{
  [[NSNotificationCenter defaultCenter] removeObserver:proxy];
  [_lock lock];
  [_proxies removeObject:proxy];
  [_lock unlock];
}
@end
