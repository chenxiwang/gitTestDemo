//
//  UITextView+APSUIControlTargetAction.m
//
//  Copyright (c) 2015 MONO (http://www.szhome.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UITextView+APSUIControlTargetAction.h"
#import <objc/runtime.h>

static void *APSUIControlTargetActionEventsTargetActionsMapKey = &APSUIControlTargetActionEventsTargetActionsMapKey;

@implementation UITextView (APSUIControlTargetAction)

/**
 *  <#Description#>
 *
 *  @param target        <#target description#>
 *  @param action        <#action description#>
 *  @param controlEvents <#controlEvents description#>
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSMutableSet *targetActions = self.aps_eventsTargetActionsMap[@(controlEvents)];
    if (targetActions == nil) {
        targetActions = [NSMutableSet set];
        self.aps_eventsTargetActionsMap[@(controlEvents)] = targetActions;
    }
    [targetActions addObject:@{ @"target": target, @"action": NSStringFromSelector(action) }];
    
    [self.aps_notificationCenter addObserver:self
                                    selector:@selector(aps_textViewDidBeginEditing:)
                                        name:UITextViewTextDidBeginEditingNotification
                                      object:self];
    [self.aps_notificationCenter addObserver:self
                                    selector:@selector(aps_textViewChanged:)
                                        name:UITextViewTextDidChangeNotification
                                      object:self];
    [self.aps_notificationCenter addObserver:self
                                    selector:@selector(aps_textViewDidEndEditing:)
                                        name:UITextViewTextDidEndEditingNotification
                                      object:self];
}

/**
 *  <#Description#>
 *
 *  @param target        <#target description#>
 *  @param action        <#action description#>
 *  @param controlEvents <#controlEvents description#>
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSMutableSet *targetActions = self.aps_eventsTargetActionsMap[@(controlEvents)];
    NSDictionary *targetAction = nil;
    for (NSDictionary *ta in targetActions) {
        if (ta[@"target"] == target && [ta[@"action"] isEqualToString:NSStringFromSelector(action)]) {
            targetAction = ta;
            break;
        }
    }
    if (targetAction) {
        [targetActions removeObject:targetAction];
    }
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSSet *)allTargets {
    NSMutableSet *targets = [NSMutableSet set];
    [self.aps_eventsTargetActionsMap enumerateKeysAndObjectsUsingBlock:^(id key, NSSet *targetActions, BOOL *stop) {
        for (NSDictionary *ta in targetActions) { [targets addObject:ta[@"target"]]; }
    }];
    return targets;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (UIControlEvents)allControlEvents {
    NSArray *arrayOfEvents = self.aps_eventsTargetActionsMap.allKeys;
    UIControlEvents allControlEvents = 0;
    for (NSNumber *e in arrayOfEvents) {
        allControlEvents = allControlEvents|e.unsignedIntegerValue;
    };
    return allControlEvents;
}

/**
 *  <#Description#>
 *
 *  @param target       <#target description#>
 *  @param controlEvent <#controlEvent description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent {
    NSMutableSet *targetActions = [NSMutableSet set];
    for (NSNumber *ce in self.aps_eventsTargetActionsMap.allKeys) {
        if (ce.unsignedIntegerValue & controlEvent) {
            [targetActions addObjectsFromArray:[self.aps_eventsTargetActionsMap[ce] allObjects]];
        }
    }
    
    NSMutableArray *actions = [NSMutableArray array];
    for (NSDictionary *ta in targetActions) {
        if (ta[@"target"] == target) [actions addObject:ta[@"action"]];
    }
    
    return actions.count ? actions : nil;
}

/**
 *  <#Description#>
 *
 *  @param action <#action description#>
 *  @param target <#target description#>
 *  @param event  <#event description#>
 */
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self.aps_application sendAction:action to:target from:self forEvent:event];
}

/**
 *  <#Description#>
 *
 *  @param controlEvents <#controlEvents description#>
 */
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    for (id target in self.allTargets.allObjects) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:controlEvents];
        for (NSString *action in actions) {
            [self sendAction:NSSelectorFromString(action) to:target forEvent:nil];
        }
    }
}

#pragma mark Notifications
/**
 *  <#Description#>
 *
 *  @param notification <#notification description#>
 */
- (void)aps_textViewDidBeginEditing:(NSNotification *)notification {
    [self aps_forwardControlEvent:UIControlEventEditingDidBegin fromSender:notification.object];
}

/**
 *  <#Description#>
 *
 *  @param notification <#notification description#>
 */
- (void)aps_textViewChanged:(NSNotification *)notification {
    [self aps_forwardControlEvent:UIControlEventEditingChanged fromSender:notification.object];
}

/**
 *  <#Description#>
 *
 *  @param notification <#notification description#>
 */
- (void)aps_textViewDidEndEditing:(NSNotification *)notification {
    [self aps_forwardControlEvent:UIControlEventEditingDidEnd fromSender:notification.object];
}

/**
 *  <#Description#>
 *
 *  @param controlEvent <#controlEvent description#>
 *  @param sender       <#sender description#>
 */
- (void)aps_forwardControlEvent:(UIControlEvents)controlEvent fromSender:(id)sender{
    NSArray *events = self.aps_eventsTargetActionsMap.allKeys;
    for (NSNumber *ce in events) {
        if (ce.unsignedIntegerValue & controlEvent) {
            NSMutableSet *targetActions = self.aps_eventsTargetActionsMap[ce];
            for (NSDictionary *ta in targetActions) {
                [ta[@"target"] performSelector:NSSelectorFromString(ta[@"action"])
                                    withObject:sender];
            }
        }
    }
}

#pragma mark Private
/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSMutableDictionary *)aps_eventsTargetActionsMap {
    NSMutableDictionary *eventsTargetActionsMap = objc_getAssociatedObject(self, APSUIControlTargetActionEventsTargetActionsMapKey);
    if (eventsTargetActionsMap == nil) {
        eventsTargetActionsMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(
                                 self,
                                 APSUIControlTargetActionEventsTargetActionsMapKey,
                                 eventsTargetActionsMap,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC
                                 );
    }
    return eventsTargetActionsMap;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSNotificationCenter *)aps_notificationCenter {
    return [NSNotificationCenter defaultCenter];
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (UIApplication *)aps_application {
    return UIApplication.sharedApplication;
}

@end
