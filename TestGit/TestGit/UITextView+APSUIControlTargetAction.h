//
//  UITextView+APSUIControlTargetAction.h
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

#import <UIKit/UIKit.h>

@interface UITextView (APSUIControlTargetAction)

/**
 *  <#Description#>
 *
 *  @param target        <#target description#>
 *  @param action        <#action description#>
 *  @param controlEvents <#controlEvents description#>
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  <#Description#>
 *
 *  @param target        <#target description#>
 *  @param action        <#action description#>
 *  @param controlEvents <#controlEvents description#>
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSSet *)allTargets;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (UIControlEvents)allControlEvents;

/**
 *  <#Description#>
 *
 *  @param target       <#target description#>
 *  @param controlEvent <#controlEvent description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent;

/**
 *  <#Description#>
 *
 *  @param action <#action description#>
 *  @param target <#target description#>
 *  @param event  <#event description#>
 */
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;

/**
 *  <#Description#>
 *
 *  @param controlEvents <#controlEvents description#>
 */
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

@end
