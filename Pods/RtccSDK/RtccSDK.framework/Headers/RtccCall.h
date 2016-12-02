//
//  WeemoCall.h
//  iOS-SDK
//
//  Created by Charles Thierry on 7/16/13.
//  Copyright (c) 2013 Weemo. All rights reserved.
//
#import <RtccSDK/RtccData.h>
#import <RtccSDK/RtccVideoOut.h>

/** @name Call Creation dictionaries keys.*/

/**@brief Used in conjonction with [Rtcc createCallWithOptions:].
 The UID of the contact to call. Expects a NSString. Mandatory.*/
static NSString *k_ContactID = @"contactID";
/**
 *@brief Used to defined the type of contact you want to call.

 Use [NSNumber numberWithInt:] and a contactID_t. Defaults to contactID_internal.
 */
static NSString *k_ContactIDType = @"contactIDType";

/**@brief Used in conjonction with [Rtcc createCallWithOptions:].

 The display name of the contact to call. Expects a NSString. Mandatory.*/
static NSString *k_ContactDN = @"contactDisplayName";
/**@brief Used in conjonction with [Rtcc createCallWithOptions:].

 Should the call start with video enabled? To set, use [NSNumber numberWithBool:]. (Default: YES) */
static NSString *k_WithVideo = @"withVideo";
/**@brief Used in conjonction with [Rtcc createCallWithOptions:].

 \@"md" to start in MD, \@"sd" to start in a lower definition (default \@"sd") */
static NSString *k_VideoStartProfile = @"videoStartProfile";
/**@brief Used in conjonction with [Rtcc createCallWithOptions:].

 Should the call start with audio enabled? To set, use [NSNumber numberWithInt:] and a audioMode_t value. (Default: audio_active) */
static NSString *k_WithAudio = @"withAudio";
/**@brief Used in conjonction with [Rtcc createCallWithOptions:].

 Set the audio route. To set, use [NSNumber numberWithInt:] with a audioRoute_t.*/
static NSString *k_AudioRoute = @"audioRoute";

@class RtccContact;

/**
 Delegate for the RtccCall Singleton.

 Allows the Host Application to be notified upon events. All methods are optional.
 @since 5.0
 */
@protocol RtccCallDelegate <NSObject>
@optional
/**
 @brief Called when the call starts or stops receiving video.
 @param sender The RtccCall which property changed.
 @param isReceiving Answers "Are we receing video?".
 @sa [RtccCall receivingVideo]
 @since 5.0
 */
- (void)rtccCall:(id)sender videoReceiving:(BOOL)isReceiving;

/**
 @brief Called when the SDK receives cursor coordinates in the share view.

 This location is in percent, between 0 and 99 (width%, height%). If the cursor is out of the view, location is -1x-1.
 @param sender The RtccCall which property changed.
 @param location The inbound video cursor location. If -1x-1, the remote's cursor is not over the share view.
 @since 5.3
 */
- (void)rtccCall:(id)sender cursorLocationInShare:(CGPoint)location;

/**
 @brief Called when the SDK receives a cursor click event.

 This location is in percent, between 0 and 99 (width%, height%). If the cursor is out of the view, location is -1x-1.

 @param sender The RtccCall which property changed.
 @param action The type of action sent by the remote. 0 is cursor location, 1 is drawing (a.k.a. connects the dots) and 2 is drop (a predefined form is to be drawn at the coordinates).
 @param location The inbound cursor location. If -1x-1, the remote's cursor is not over the share view.
 @since 5.3
 */
- (void)rtccCall:(id)sender cursorClick:(int)action onShareInAt:(CGPoint)location;

/**
 @brief Fired when the SDK starts or stops receiving share data.
 @param sender The RtccCall which property changed.
 @param isReceiving Answers "Are we receiving share data?".
 @since 5.1
 */
- (void)rtccCall:(id)sender shareReceiving:(BOOL)isReceiving;

/**
 @brief Called when the call starts or stops sending video.
 @param sender The RtccCall which property changed.
 @param isSending Answers "Are we sending video?".
 @sa [RtccCall sendingVideo]
 @since 5.0
 */
//- (void)rtccCall:(id)sender videoSending:(BOOL)isSending;

/**
 @brief Fired when the SDK starts or stops sending share data.
 @param sender The RtccCall which property changed.
 @param isSending Answers "Are we sending share data?".
 @sa [RtccCall sendingShare]
 @since 5.1
 */
- (void)rtccCall:(id)sender shareSending:(BOOL)isSending;

/**
 @brief Fired when the video capture is paused or resumed.
 @param sender The RtccCall which property changed.
 @param pauseDidStart Answers "Is the video output paused?".
 @sa [RtccCall videoPaused]
 */
//- (void)rtccCall:(id)sender videoPause:(BOOL)pauseDidStart;

/**
 @brief Called when the incoming video profile changes.

 Use this method to know when the video incoming size/profile changes.
 @param sender The RtccCall which property changed.
 @param size The new profile used by the incoming video. Can be CGSizeZero.
 @sa [RtccCall setVideoInProfile:]
 @sa [RtccCall getVideoInSize]
 @since 5.1
 */
- (void)rtccCall:(id)sender videoInSizeChange:(CGSize)size;

/**
 @brief Called when the incoming video profile changes.

 Use this method to know when the video incoming size/profile changes.
 @param sender The RtccCall which property changed.
 @param profile The new profile used by the incoming video. Can be CGSizeZero.
 @param contact The contact whose video in changed.
 @sa [RtccCall setVideoInProfile:]
 @sa [RtccCall getVideoInSize]
 @since 5.1
 */
- (void)rtccCall:(id)sender videoInSizeChange:(CGSize)profile forContact:(RtccContact *)contact;

/**
 @brief Called when the incoming share frame size changes.

 @param sender	The RtccCall which property changed.
 @param size	The new size of the share frame. Can be CGSizeZero.
 @since 5.1
 */
- (void)rtccCall:(id)sender shareInSizeChange:(CGSize)size;

/**
 @brief Called when the outgoing video size changes (that is, even if the device rotates).
 @param sender The RtccCall which property changed.
 @param size The new size of the monitoring video. Can be CGSizeZero.
  @since 5.1
 */
- (void)rtccCall:(id)sender videoOutSizeChange:(CGSize)size __attribute__((unavailable("The video out size change is handled by the VideoOut source.")));

/**
 @brief Called when the video source changes.
 @param sender The RtccCall which property changed.
 @param source The source now in use.
 @since 5.0
 */
- (void)rtccCall:(id)sender videoSource:(videoSource_t)source __attribute__((unavailable("The video out source change is handled by the VideoOut source.")));

/**
 @brief Called when the zoom level changes

 @param sender The RtccCall which property changed
 @param zoom   The new zoom level
 @since 6.3
 */
- (void)rtccCall:(id)sender videoZoom:(CGFloat)zoom __attribute__((unavailable("The video out zoom change is handled by the VideoOut source.")));

/**
 The zoom threshold at which the captured image starts being upscaled

 @param sender The related RtccCall
 @param zoom   The zoom threshold
 @since 6.3
 */
- (void)rtccCall:(id)sender videoZoomThreshold:(CGFloat)zoom __attribute__((unavailable("The video out zoom change is handled by the VideoOut source.")));

/**
 The maximum zoom level available for the camera

 @param sender The related RtccCall
 @param zoom   The maximum zoom level
 @ since 6.3
 */
- (void)rtccCall:(id)sender videoZoomMax:(CGFloat)zoom __attribute__((unavailable("The video out zoom change is handled by the VideoOut source.")));

/**
 @brief Called when the microphone is muted.
 @param sender The RtccCall which property changed.
 @param isSending sending captured audio stream if true, sending empty packets otherwise.
 @sa [RtccCall audioStart]
 @sa [RtccCall audioStop]
 @since 5.0
 */
- (void)rtccCall:(id)sender audioSending:(BOOL)isSending;

/**
 @brief Called when the audio route changes.
 @param sender The RtccCall which property changed.
 @param route The new route used.
 @sa [RtccCall audioRoute]
 @since 5.0 - modified 5.5
 */
- (void)rtccCall:(id)sender audioRoute:(audioRoute_t)route;

/**
 @brief Called when the status of the call changes.
 @param sender The RtccCall which property changed.
 @param status The new status of the call (i.e. callStatus_ringing).
 @sa [RtccCall callStatus]
 @since 5.0
 */
- (void)rtccCall:(id)sender callStatus:(callStatus_t)status;

/**
 @brief The call unique SIP identifier as been received. This occurs *after* the call goes active. After this delegate method is fired, the [RtccCall getSipID] message can be fired anytime to retrieve this ID.
 @param sender The RtccCall which sipID was received.
 @param sipID The sipID.
 @sa [RtccCall getSipID]
 @since 5.2
 */
- (void)rtccCall:(id)sender sipID:(NSString *)sipID;

/**
 @brief You received raw data from the contact you are talking to.
 @param sender The call related to the data.
 @param data The data received.
 @since 5.3
 */
- (void)rtccCall:(id)sender receivedData:(NSData *)data;

#pragma mark - Conference delegation
/**
 @brief Fired when a participant's status changes.
 @param sender the Call which participant changed.
 @param contact A reference to the contact that changed. The changes is one of the following:

	* [RtccContact isMuted]
	* [RtccContact isDeaf]
	* [RtccContact isEmittingVideo]
	* [RtccContact isHandUp]
	* [RtccContact isAdmin]
	* [RtccContact isOnHold]
	* [RtccContact isTalking]

 @since 5.3
 */
- (void)rtccConference:(id)sender participantChange:(RtccContact *)contact;

/**
 Fired when the list of contacts changes. The whole list (of RtccContact) is dropped and rebuilt.
 @param sender The Call which participant list changed.
 @since 5.3
 */
- (void)rtccParticipantListChangeForConference:(id)sender;

/**
 Indicates that recording for this call started.
 @param sender The related RtccCall.
 @sa [RtccCall recordingStop]
 @sa [RtccCall recordingPause]
 @sa [RtccCall isRecording]
 @since 5.3
 */
- (void)rtccCallRecordStopped:(id)sender;

/**
 Indicates that recording for this call ended.
 @param sender The related RtccCall.
 @since 5.3
 @sa [RtccCall recordingStart:]
 @sa [RtccCall isRecording]
 */
- (void)rtccCallRecordStarted:(id)sender;

/**
 *  Called when the conference call record is paused
 *
 *  @param sender the related RtccCall
 */
- (void)rtccCallRecordPaused:(id)sender;

/**
 *  Called when the conference call record is resumed
 *
 *  @param sender the related RtccCall
 */
- (void)rtccCallRecordResumed:(id)sender;

@end

/**
 Represents a call to a contact or a conference. Such an object is created using [Rtcc createCall:].

 Remark regarding video capture: when the device is held in a non supported rotation, the monitoring view of the outgoing video is rotated to indicate that the rotation is not supported, though the outgoing video is sent correctly rotated.
 @since 5.0
 */
@interface RtccCall : NSObject
/** @name Call parameters*/

/**
 @brief The host app should set this value if it wants to be notified about call changes.
 @since 5.0
 */
@property(nonatomic, strong) id<RtccCallDelegate> delegate;

/**
 @brief The ID of the call.

 Not really used for now since only one call can be held at a time.
 @since 5.0
 */
@property(nonatomic, readonly) int callid;

/**
 @brief This is the duration of this call, in seconds.

 Not KVO, as it is updated only when the value is requested.
 @since 5.1
 */
@property(nonatomic, readonly) NSTimeInterval callDuration;

/**
 @brief Date of call start.
 @since 5.1
 */
@property(nonatomic, readonly) NSDate *startDate;

/**
 @brief ID of the contact or the conference being called.
 @sa [RtccCall contactDisplayName]
 @since 5.0
 */
@property(nonatomic, readonly) NSString *contactUID;

/**
 @brief Display name of the contact or conference being called.

 If this name is not set, a call to this variable returns the same value as [RtccCall contactUID]. The only way to set this variable is on call creation through [Rtcc createCall:andSetDisplayName:]
 @sa [RtccCall contactUID]
 @since 5.0
 */
@property(nonatomic, readonly) NSString *contactDisplayName;

/**
 @brief The sip ID of the call.
 This property is only available after the call is set to active.

 Fetching it before the [RtccCallDelegate rtccCall:sipID:] callback is fired will return `nil`. Fetching it with a callstatus different from `callStatus_active`, `callStatus_paused` or `callStatus_ended` will return `nil`.
 @sa [RtccCall callStatus]
 @sa [RtccCallDelegate rtccCall:sipID:]
 @since 5.2
 */
@property(nonatomic, readonly, getter=getSipID) NSString *sipID;

#pragma mark - Call status
/** @name Call Status*/
/**
 @brief Status of the call

 Upon change, [RtccCallDelegate rtccCall:callStatus:] is called.
 @sa [RtccCallDelegate rtccCall:callStatus:]
 @since 5.0
 */
@property(nonatomic, readonly) callStatus_t callStatus;

/**
 @brief Value changes after a [RtccCall toggleAudioRoute].

 Upon change, [RtccCallDelegate rtccCall:audioRoute:] is called.
 @sa [RtccCallDelegate rtccCall:audioRoute:]
 @since 5.0 - modified 5.5
 */
@property(nonatomic) audioRoute_t audioRoute;

/**
 @brief Whether or not the call is receiving video.

 This property changes when the video stream is started/ended on the other end. Upon change, [RtccCallDelegate rtccCall:videoReceiving:] is called.
 @sa [RtccCallDelegate rtccCall:videoReceiving:]
 @since 5.0
 */
@property(nonatomic, readonly, getter=isReceivingVideo) BOOL receivingVideo;

/**
 @brief Whether or not the call has an outbound view share ongoing.

 This property changes when the share starts. Upon change, [RtccCallDelegate rtccCall:shareReceiving:] is called.
 @sa [RtccCallDelegate rtccCall:shareReceiving:]
 @since 5.1
 */
@property(nonatomic, readonly, getter=isReceivingShare) BOOL receivingShare;

/**
 @brief Whether or not the call has an outbound view share ongoing.

 This property changes when the network acknowledge the share is ongoing.
 Upon change, [RtccCallDelegate rtccCall:shareSending:] is called.
 @sa [RtccCallDelegate rtccCall:shareSending:]
 @since 5.1
 */
@property(nonatomic, readonly, getter=isSendingShare) BOOL sendingShare;

/**
 @brief Whether or not the call is sending captured audio packet.

 This property changes when the network acknowledge the microphone status change on this end.
 Upon change, [RtccCallDelegate rtccCall:audioSending:] is called.
 @sa [RtccCallDelegate rtccCall:audioSending:]
 @since 5.0
 */
@property(nonatomic, readonly, getter=isSendingAudio) BOOL sendingAudio;

/** @name Videos & Share Screens*/
/**
 @brief The view in wich the call should display the incoming share.

 Set by the host application.
 @sa [RtccCall viewShareOut]
 @since 5.1
 */
@property(nonatomic, weak) UIView *viewShareIn;

/**
 @brief The view in wich the call should display the outgoing share.

 Set by the host application.
 @sa [RtccCall viewShareIn]
 @since 5.3
 */
@property(nonatomic, weak) UIView *viewShareOut;

/**
 @brief The view in wich the call should display the incoming video.

 Set by the host application.
 @sa videoOut
 @since 5.0
 */
@property(nonatomic, weak) UIView *viewVideoIn;

/**
 @brief  Ask the remote to change the quality of the video it sends. The remote is not compelled to do so.

 @param videoProfile	The wanted profile
 @sa [RtccCall getVideoInSize]
 */
- (void)setVideoInProfile:(VideoProfile_t)videoProfile;

/**
 *  Module to deal with VideoOut.
 */
@property(nonatomic, readonly) RtccVideoOut *videoOut;

/** @name Conference Call*/
/**
 @brief Answers the question "Is this call a conference?".
 @since 5.3
 */
@property(nonatomic, readonly) BOOL isConference;

/**
 @brief The list of participants in the call, own user excluded.

 This dictionary is composed of couples <`NSNumber *`, `RtccContact *`>, where the `NSNumber *` indicates the contact's location in the floorlist.

 The logged user (a.k.a. `myself`) is not represented in this array.

 @sa [RtccCall myself]
 @since 5.3
 */
@property(nonatomic, readonly) NSDictionary <NSNumber *, RtccContact *>*participantsDictionary;

/**
 @brief Only used in case of conference. Not present in the participantsList.
 @since 5.3
 */
@property(nonatomic, readonly) RtccContact *myself;

/**
 YES if the app is hosting the conference. NO if attendee.
 @sa [Rtcc meetingPointCreateWithTitle:atLocation:startDate:endDate:withType:]
 @since 5.3
 */
@property(nonatomic, readonly) BOOL isHost;

/**
 *  YES if the conference is being recorded. The delegate is notified of a change through rtccCallRecordStarted: and rtccCallRecordStopped:
 @sa [RtccCall recordingStart:]
 @sa [RtccCall recordingStop]
 */
@property(nonatomic, readonly, getter=isRecording) BOOL recording;

/**
 *  YES if the conference is being recorded but this recording is paused.
	The delegate is notified of a change through rtccCallRecordStarted: and rtccCallRecordStopped:
 @sa [RtccCall recordingStart:]
 @sa [RtccCall recordingStop]
 */
@property(nonatomic, readonly, getter=isRecordingPaused) BOOL recordingPaused;

/**
 @brief Setting this mutes/unmutes all the conference participants.

 YES if all contacts are muted. Same as iterating throught the contacts list and checking if everyone is muted.

 Setting this to YES sends a global command to the conference bridge.
 @since 5.3
 */
@property(nonatomic, getter=areAllMuted) BOOL muteAll;

/**
 @brief Setting this deafens/undeafens all the conference participants.

 YES if all contacts are deaf. Same as iterating throught the contacts list and checking if everyone is deaf.

 Setting this to YES sends a global command to the conference bridge.
 @since 5.3
 */
@property(nonatomic, getter=areAllDeafen) BOOL deafenAll;

#pragma mark - Basic controls
/** @name Basic Call Controls*/
/**
 @brief Hang up the call and stop it
 @since 5.0
 */
- (void)hangup;

/**
 @brief Resume the call if it was paused. Pick it up if it is ringing.
 @since 5.0
 */
- (void)resume;

- (void)resumeWithParameters:(NSDictionary *)parameters;

/**
 @brief Pick up a call without activating the outgoing video.
 @since 5.2
 */
- (void)resumeWithoutVideo;

//- (void)sendArbitraryVideoFrame:(uint8_t *)ref ofSize:(CGSize)size withFormat:(frameFormat_t)format;

/**
 @brief Start the share view and set the view to be shared.

 @param view This view is *NOT* retained by the SDK (a.k.a. its reference is kept with a `weak` property).
 @warning Not available on iOS version earlier than the 7.0.
 @since 5.1
 */
- (void)screenShareStart:(UIView *)view;

/**
 @brief Stops the share. If the incoming video stream was active, it is resumed.
 @since 5.1
 */
- (void)screenShareStop;

- (void)shareCursorAt:(CGPoint)location;
- (void)shareCursorClick:(int)action at:(CGPoint)location;

/**
 @brief Start sending audio from the microphone.

 While the outgoing audio stream starts automatically upon call start, it is possible to mute the microphone, thus sending only empty frames. This function starts the sending of captured audio packet.

 Upon change, [RtccCallDelegate rtccCall:audioSending:] is called.
 @sa [RtccCallDelegate rtccCall:audioSending:]
 @since 5.0
 */
- (void)audioStart;

/**
 @brief Stop sending audio from the microphone.

 The function stops the sending of captured audio packet. Enpty audio frames are sent instead.

 Upon change, [RtccCallDelegate rtccCall:audioSending:] is called.
 @sa [RtccCallDelegate rtccCall:audioSending:]
 @since 5.0
 */
- (void)audioStop;

/**
 @brief Changes the audio route used by the call.

 This toggle the speaker override, turns on the device's speaker or changes back to the default equipement of the device (or the headset if a compatible headset is connected.)

 Upon change, [RtccCallDelegate rtccCall:audioRoute:] is called.
 @sa [RtccCallDelegate rtccCall:audioRoute:]
 @sa [RtccCall audioRoute]
 @since 5.0
 @deprecated Since 5.5. Set [RtccCall audioRoute] to change the outgoing audio route.
 */
- (void)toggleAudioRoute __attribute__((unavailable("Use setAudioRoute:")));

#pragma mark - Views and Video
/** @name Video and Share Streams*/

/**
 @brief Returns the incoming video size. Use it to resize [RtccCall viewVideoIn].
 @return The size of the video.
 @since 5.2
 */
- (CGSize)getVideoInSize;

/**
 @brief Returns the incoming share size. Use it to resize [RtccCall viewShareIn].
 @return The size of the video.
 @since 5.1
 */
- (CGSize)getShareInSize;

#pragma mark - Pointers

/** @name Inband Messages*/
/**
 Send raw data to the call recipient. Could be anything.
 @param data The data to send.
 @since 5.3
 */
- (void)sendData:(NSData *)data;

#pragma mark - Conference
/** @name Conference Controls*/

/**
 @brief Kicks a participant out of the call. Only an admin can call this method and be obeyed.
 @param participantID The ID of the participant to kick out.
 @since 5.3
 */
- (void)kickParticipant:(NSNumber *)participantID __attribute__((nonnull(1)));

/**
 @brief Start recording the video to the specified URL. Conference calls only.
 @param serverURL The server to which the MVS will send the video streams.
 @since 5.3
 */
- (void)recordingStart:(NSString *)serverURL;

/**
 @brief Pause the recording. Conference calls only.
 @since 5.3
 */
- (void)recordingPause;

/**
 @brief Resume the recording. Conference calls only.
 */
- (void)recordingResume;

/**
 @brief Stop the recording. Conference calls only.
 @since 5.3
 */
- (void)recordingStop;

/**
 @brief Create a bookmark in a recording. Conference calls only.
 @since 5.3
 */
- (void)recordingBookmark;

/**
 @brief Use this method to disable/enable the full quality main speaker video stream. Conference calls only.
 @param onlyThumbnails	If set to YES, only the thumbnails of the videos will be received for the conference.
 @since 5.6
 */
- (void)setThumbnailsOnly:(BOOL)onlyThumbnails;

@end
