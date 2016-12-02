//
//  RtccCall(VideoOut).h
//  RtccSDK
//
//  Created by Charles Thierry on 16/05/16.
//  Copyright © 2016 Weemo, Inc. All rights reserved.
//
#import <RtccSDK/RtccProtocols.h>
#import <UIKit/UIkit.h>

@class RtccCall;

/**
 *  This category of the RtccCall is dedicated to handling the VideoOut stream.
 */
@interface RtccVideoOut : NSObject

/**
 *  The video Source must be set by the app using the SDK. That source deals with the framerate and should observe the result of the Sink's push method. A default implementation of this object is instantiable throught RtccDefaultVideoSource.
 */
@property(nonatomic) id<RtccVideoSource> source;

/**
 *  The Sink is implemented by the SDK and sends frame only when self.isSendingVideo.
 */
@property(nonatomic, readonly) id<RtccVideoSink> sink;

/**
 *  A reference to the call
 */
@property(nonatomic, readonly, weak) RtccCall *call;

/**
 *  If true, the system is waiting for frames. If no, the system will not send frames.
 */
@property(nonatomic, getter=isSendingVideo) BOOL sendingVideo;

/**
 *  A value set by the SDK. This value reflects what the remote is wanting you to send.
 */
@property(nonatomic, readonly) VideoProfile_t requestedProfile;

/**
 *  Asks the SDK to start sending video frames. After this call, the VideoSource start method will be called.
 */
- (void)start;

/**
 *  Asks the SDK to stop sending video frames. After this call, the VideoSource stop method will be called.
 */
- (void)stop;

@end
