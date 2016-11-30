//
//  LSLoggingDelegate.h
//  RtccSDK
//
//  Created by Charles Thierry on 17/11/15.
//  Copyright © 2015 Weemo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RtccSDK/RtccSDK.h>


/**
 *  This protocol allows for the SDK to send log to the bundle including it.
 */
@protocol RtccLogDelegate <NSObject>


/**
 *  The method to be used to log things. The serializing job is left to the delegate object.
 *
 *  @param caller		The function in which the log was created, if any.
 *  @param level		The log level.
 *  @param module		The log module.
 *  @param message	The message itself.
 *  @param ...			Content of the message.
 */
- (void)logWithSelector:(const char *)caller withLevel:(logLevel_t)level andModule:(logModule_t) module message:(NSString *) message, ... NS_REQUIRES_NIL_TERMINATION;

@end

