//
//  WeemoContact.h
//  WeemoSDK
//
//  Created by Charles Thierry on 6/16/14.
//  Copyright (c) 2014 Weemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RtccSDK/RtccData.h>
#import <UIKit/UIKit.h>

/**
 Pre declaration to avoid include looping
 */
@class RtccCall;

/**
 Represents the data available on any contact present in the related call.

 All calls have at least two contacts. One is [RtccCall myself], the other is either a single remote contact (in case of a 1:1 call, his ID describes the call) or are available from a list of contacts during conferences, using [RtccCall participantsDictionary].
 */
@interface RtccContact : NSObject

/** @name Generic informations */
/**
 The call in which this contact exists.
 */
@property(nonatomic, readonly, weak) RtccCall *relatedCall;

/**
 The contact display name.
 */
@property(nonatomic, readonly) NSString *displayName;

/**
 The contact UID. This value is immutable during call.
 */
@property(nonatomic, readonly) NSString *UID;

/**
 The contact number in the call. This value is immutable during a call.
 */
@property(nonatomic, readonly) NSNumber *contactID;

#pragma mark - Video in
/** @name Video Parameters */
/**
 The view in which the call is rendered.
 */
@property(nonatomic, weak) UIView *renderView;

/**
 The video profile
 */
@property(nonatomic) video_profile_t videoInProfile;

/**
 The incoming video size for this contact. Each contact have their own video.
 @sa [RtccCall getVideoInSize] is used as a proxy when only one remote contact.
 */
- (CGSize)getVideoInSize;

/** @name Conference Parameters */
/**
 Conference status, can only be set if the user is the conference admin.
 */
@property(nonatomic, getter=isMuted) BOOL muted;

/**
 Conference status, can only be set if the user is the conference admin.
 */
@property(nonatomic, getter=isDeaf) BOOL deaf;

/**
 Conference status.
 */
@property(nonatomic, readonly) BOOL isEmittingVideo;

/**
 Conference status. Any user can set their own.
 */
@property(nonatomic, getter=isHandUp) BOOL handUp;

/**
 Conference status. Set by the conference bridge.
 */
@property(nonatomic, readonly) BOOL isAdmin;

/**
 Conference status. Is the contact on hold.
 */
@property(nonatomic, getter=isOnHold) BOOL onHold;

/**
 *  Set the user as main speaker, can only be set if the user is the conference admin.
 */
@property(nonatomic, getter=isLocked) BOOL lock;

/**
 Conference status.
 */
@property(nonatomic, readonly) BOOL isTalking;

@end
