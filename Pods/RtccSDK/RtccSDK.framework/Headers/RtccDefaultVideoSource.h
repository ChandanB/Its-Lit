//
//  RtccDefaultVideoSource.h
//  RtccSDK
//
//  Created by Charles Thierry on 17/05/16.
//  Copyright © 2016 Weemo, Inc. All rights reserved.
//

#import <RtccSDK/RtccData.h>
#import <RtccSDK/RtccProtocols.h>

/**
 The Source delegate informs the application about the size of the captured frames. Upon rotating the device or changing the video profile,
 the size of the captured video will change.
 */
@protocol RtccDefaultVideoSourceDelegate

/**
 This method is fired when the captured video changes size (due to a rotation or other).
 This method is not called on the main thread. Beware.
 @sa videoSize
 */
- (void)videoSourceSizeChanged:(CGSize)newSize;
@end

/**
 * This is a default implementation of a video source for the RtccCall videoOut. This source allows the application to switch between `front` and `back` camera.
 *
 * The application must set this instance as the videoOut.source in order for video capture to work.
 *
 * The video captured is rendered in a subview of the renderView. The renderView must be set (and retained) by the application.
 *
 * @warning Do not subclass this class. Implements the RtccVideoSource protocol to create your own source.
 *
 * @sa RtccVideoOut
 * @sa RtccCall
 */
@interface RtccDefaultVideoSource : NSObject <RtccVideoSource>

/**
 @brief The source delegate should be set by the application in order to be informed of the size of the video that is captured and resize the render view that is used.
 */
@property(nonatomic, weak) id<RtccDefaultVideoSourceDelegate> delegate;

/**
 @brief This property must be set by application. Upon setting it, a subview is added that contains the camera render layer.

 This subview is added with contraints to keep it the same size as the renderView.

 The layer content is set to fit the subview. As such, it will always preserve the video ratio of the capture.
 @sa [RtccCall viewVideoIn]
 */
@property(nonatomic, weak) UIView *renderView;

/**
 @brief The video size that is captured. When this size changes, the delegate is notified through the videoSourceSizeChanged: method.
 @sa RtccDefaultVideoSourceDelegate
 */
@property(nonatomic, readonly) CGSize videoSize;

/**
 @brief This property informs the application about the camera's orientation (videoSource_front or videoSource_back) that is set.
 */
@property(nonatomic) videoSource_t currentCamera;

@end
