//
//  RtccProtocols.h
//  RtccSDK
//
//  Created by Charles Thierry on 28/02/15.
//  Copyright (c) 2015 Weemo SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <RtccSDK/RtccData.h>

/**
 ACD
 */

@protocol RtccACDDelegate
- (void)rtccACDPosition:(NSInteger)position inQueue:(NSInteger)queueLength;
- (void)rtccACDAccepted:(NSString *)uid;

@end

/**
 This delegate allows the app to be notified of Meeting Points changes.

 A meeting point is a virtual space. It is created by a Host and can be joined by Attendees. Hosts can update meeting
 point's details, fetch the list of user wishing to join, send invitations (once the call is started) and accept/or
 deny attendees join requests. Attendees can request to join a meeting point, and once accepted can call the conference.

 @since 5.3
 */
@protocol RtccMeetingPointDelegate <NSObject>

/**
 @brief Fired once the meeting point was created.

 Once this has been fired, the MP's ID can be shared to future Attendees and the call related to the Meeting Point can be created. Attendees can only be invited once this call has been created.
 @param mp The meeting point's details. Keys for the dictionary are `k_MPID`, `k_MPURLAttendee` and `k_MPURLHost`.

 If `nil`, an error occured.
 @sa [Rtcc meetingPointCreateWithTitle:atLocation:startDate:endDate:withType:]
 @since 5.3
 */
- (void)rtccMeetingPointCreated:(NSDictionary *)mp;

/**
 @brief Fired once a meeting point was deleted.

 @param mp The ID of the related meeting point. If `nil`, an error occured.
 @warning Can not delete Meeting point if it was created using `mpType_permanent`.
 @sa [Rtcc meetingPointDelete:]
 @since 5.3
 */
- (void)rtccMeetingPointDeleted:(NSString *)mp;

/**
 @brief Fired when a meeting point's details are requested.

 The request is sent through [Rtcc meetingPointGetDetails:]
 @param mp The meeting point's details. Keys for the dictionary are	`k_MPEnd`, `k_MPID`, `k_MPLocation`, `k_MPStart` and `k_MPTitle`. If `nil`, an error occured.
 @sa [Rtcc meetingPointGetDetails:]
 @since 5.3
 */
- (void)rtccMeetingPointDetails:(NSDictionary *)mp;

/**
 @brief Fired when a meeting point is created or updated.

 @param mp A dictionary containing the URLs needed to join the Wall pages. Keys are `k_MPID`, `k_MPURLAttendee` and `k_MPURLHost`. If `nil`, an error occured.
 @sa [Rtcc meetingPointGetDetails:]
 @since 5.3
 */
- (void)rtccMeetingPointURLs:(NSDictionary *)mp;

/**
 @brief Fired once a meeting point is updated.

 The info returned should match the data used to modify the meeting point.
 @param mp The new meeting point's details. Keys for the dictionary are `k_MPID`, `k_MPStart`, `k_MPEnd`, `k_MPLocation` and `k_MPTitle`. If `nil`, an error occured.
 @sa [Rtcc meetingPointUpdate:newTitle:newLocation:newStartDate:newEndDate:]
 @since 5.3
 */
- (void)rtccMeetingPointUpdated:(NSDictionary *)mp;

/**
 @brief The meeting was cancelled by the host.
 @param mpID The ID of the cancelled meeting point. If `nil`, an error occured.
 @since 5.3
 */
- (void)rtccMeetingPointCancelled:(NSString *)mpID;

/**
 @brief The meeting point was stopped.
 @param mpID The ID of the stopped meeting point. If `nil`, an error occured.
 @since 5.3
 */
- (void)rtccMeetingPointStopped:(NSString *)mpID;

/**
 @brief The user has accepted or denied an invite
 @param userUID The user's UID
 @param answer  The user's answer
 */
- (void)rtccMeetingPointUser:(NSString *)userUID answeredToInvite:(mpAttendeeStatus_t)answer;

@optional
/**
 *	An error occured while modifying a Meeting point.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @since 5.3
 *  @deprecated Since 5.6.3 - Please use rtccMeetingPointError:forMPID: which gives you the ID of the related meeting point.
 */
- (void)rtccMeetingPointError:(NSError *)err __attribute__((unavailable("Please use rtccMeetingPointError:forMPID:.")));

/**
 *  An error occured while modifying a Meeting point.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @param mpID The ID of the related Meeting Point.
 *  @since 5.6.3
 */
- (void)rtccMeetingPointError:(NSError *)err forMPID:(NSString *)mpID;

@end

/**
 This protocol describes the host's side of the meeting point usage.
 @since 5.3
 */
@protocol RtccHostDelegate <NSObject>

/**
 @brief A new attendee is entering.
 @param infos Data about the soon-to-become attendee. Keys for the dictionary are `k_MPContactName`, `k_MPDisplayName` and `k_MPID`.
 @since 5.3
 */
- (void)rtccHostNewAttendee:(NSDictionary *)infos;

- (void)rtccMeetingPoint:(NSString *)mpID answer:(mpAttendeeStatus_t)answer fromAttendee:(NSString *)userUID;

/**
 @brief An invite operation was cancelled.
 @warning It is the app's responsability to remember which operation has been cancelled (invite or join request). Consider the answers to arrive in the same order as the requests.
 @since 5.3
 */
- (void)rtccOperationCancelled;

/**
 @brief Fired when the Meeting Point global authorization status was updated.

 Answers a host call to [Rtcc meetingPoint:setAuthorizationStatus:].
 @param mpID The ID of the related meeting point.
 @param status The new status.
 @sa [Rtcc meetingPoint:setAuthorizationStatus:]
 @since 5.3
 */
- (void)rtccMeetingPoint:(NSString *)mpID statusUpdate:(mpAuthorizationMode_t)status;

/**
 @brief Fired when a meeting point is started.

 Answers a [Rtcc meetingPointStart:] by the host. Its "stopped" pendant is fired in the RtccMeetingPointDelegate.
 @param mpID The ID of the related meeting point.
 @sa [Rtcc meetingPointStart:]
 @sa [RtccMeetingPointDelegate rtccMeetingPointStopped:]
 @since 5.3
 */
- (void)rtccMeetingPointStarted:(NSString *)mpID;

@optional

/**
 *  An error occured after an host request.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @deprecated Since 5.6.3 - Please use [RtccHostDelegate rtccHostError:forMPID:] which gives you the ID of the related meeting point.
 */
- (void)rtccHostError:(NSError *)err __attribute__((unavailable("Please use rtccHostError:forMPID:")));

/**
 *  An error occured after an host request.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @param mpID The ID of the related Meeting Point.
 *  @since 5.6.3
 */
- (void)rtccHostError:(NSError *)err forMPID:(NSString *)mpID;
@end

/**
 This protocol described the attendee's side of the meeting point usage.
 @since 5.3
 */
@protocol RtccAttendeeDelegate <NSObject>

/**
 @brief A join request operation was cancelled.
 @warning It is the app's responsability to remember which operation has been cancelled (invite or join request). Consider the answer to arrive in the same order as the requests.
 @since 5.3
 */
- (void)rtccOperationCancelled;

/**
 @brief The attendee asked to join a MP, this is the answer.
 @param status If `mpAtt_pending` the Host did not accept nor refuse yet, `mpAtt_granted` the Host granted access, `mpAtt_denied` the Host denied access.
 @param mpID The ID of the related meeting point.
 @since 5.3
 */
- (void)rtccAttendeeAuthorization:(mpAttendeeStatus_t)status forMeeting:(NSString *)mpID;

/**
 @brief The attendee is invited to join a conference call by a user.
 Please note that being invited to join a Conference call does not mean you will join the Meeting Point itself.
 You answer that invite by calling [Rtcc meetingPoint:attendeeAnswersToInvite:from:]

 @param mpID    The mpID related to that conference call
 @param userUID the user that invited the attendee
 */
- (void)rtccAttendeeWasInvitedToMeeting:(NSString *)mpID byUser:(NSString *)userUID;

@optional
/**
 @brief The attendee was invited to a meeting point.
 @param mpID The ID of the related meeting point.
 @since 5.3
 @deprecated Since 6.2.4 - Please use [RtccAttendeeDelegate rtccAttendeeWasInvitedToMeeting:byUser:] which gives you the ID of the person that invited you.
 */
- (void)rtccAttendeeWasInvitedToMeeting:(NSString *)mpID;

/**
 *  An error occured after an attendee request.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @since 5.3
 *  @deprecated Since 5.6.3 - Please use [RtccAttendeeDelegate rtccAttendeeError:forMPID:] which gives you the ID of the related meeting point.
 */
- (void)rtccAttendeeError:(NSError *)err __attribute__((unavailable("Please use rtccAttendeeError:forMPID:")));

/**
 *  An error occured after an attendee request.
 *
 *  @param err An error whose code is an errorCode_t value.
 *  @param mpID The ID of the related Meeting Point.
 *  @since 5.6.3
 */
- (void)rtccAttendeeError:(NSError *)err forMPID:(NSString *)mpID;

@end

/**
 This protocol presents the callbacks related to the presence part of the SDK.

 This notifies the app of registration status changes and roster&single contact presence udpate.
 */
@protocol RtccPresenceDelegate <NSObject>

/**
 @brief Called when the user registration changes.

 Usually arrives on connection establishment or after a disconnection from another device.
 @param registrationUpdate The new user's registration udpate status.
 @since 5.4
 */
- (void)rtccPresenceRegistrationUpdate:(registrationUpdate_t)registrationUpdate;

/**
 @brief A Contact changed its presence.
 @param contact The contactUID whose presence changed.
 @param presence The new value of the presence.
 @since 5.4
 */
- (void)rtccPresenceContact:(NSString *)contact changedPresence:(NSNumber *)presence;

/**
 @brief The roster changed: either contact were added, or they were removed.

 In case of "add one and remove one", this callback will be fired twice, once with a positive variation and the second with a negative one.
 @param currentSize The size of the updated roster.
 @param variation The delta between the previous roster size and the current roster size.
 @since 5.4
 */
- (void)rtccRosterSize:(NSNumber *)currentSize update:(NSNumber *)variation;

/**
 @brief The content of a part of the roster.

 This is usually an answer to [Rtcc getPresenceForContacts:]] with `@[ContactUID@, ContactUID2, ...]` as parameter.
 @param contactsPresence A dictionary of `<NSString *ContactUID: NSNumber *Presence>`, Presence an unsigned char.
 @sa [RtccPresenceDelegate rtccRosterUpdate:]
 @since 5.4
 */
- (void)rtccPresenceForContacts:(NSDictionary *)contactsPresence;

/**
 @brief The content of the whole roster.

 This is an answer to [Rtcc getPresenceForContacts:] using `nil` as parameter.
 @param updatedRoster A dictionary <NSString *ContactUID: NSNumber *Presence>, with `Presence` an unsigned char.
 @since 5.4
 */
- (void)rtccRosterUpdate:(NSDictionary *)updatedRoster;

@end

/**
 This protocol presents the callbacks related to the data part of the SDK.

 This notifies the app of message reception and their acknowledgement. You need to be registered to send and receive messages, registration happening automatically upon login. You are registered as soon as [RtccPresenceDelegate rtccPresenceRegistrationUpdate:] is fired with either `registration_registered` or `registration_alreadyRegistered` as parameter.
 @sa RtccPresenceDelegate
 */
@protocol RtccDataDelegate <NSObject>

/**
 @brief Fired when a contact calls [Rtcc dataSend:toContactUIDs:withID:] with your UID as one of the `contactUID`s parameter.

 You don't need to be in this contact's roster to receive message from them, no more than you need to have them in your roster.

 @param data The data received.
 @param contactUID The UID of the contact who send the message.
 @param messageID The id the remote contact attributed to the message. Used to acknowledge the message.
 @sa [Rtcc dataSend:toContactUIDs:withID:]
 */
- (void)rtccReceivedData:(NSData *)data from:(NSString *)contactUID withID:(uint8_t)messageID;

/**
 @brief Called when a remote contact calls [Rtcc dataAcknowledge:ofContact:withFlag:] with your UID as `contactUID`.

 While this is mainly used to convey a notion of acknowledgment, this can be used to transmit other thing (i.e. a status like "writing a message").

 @param messageID The ID of the message acknowledged.
 @param contactUID The UID of the contact who sent the message.
 @param flag This is implentation dependant. You can call [Rtcc dataAcknowledge:ofContact:withFlag:] multiple times for the same ID.
 @sa [Rtcc dataAcknowledge:ofContact:withFlag:]
 */
- (void)rtccReceivedAckForID:(uint8_t)messageID fromContact:(NSString *)contactUID withFlag:(uint8_t)flag;

@end

/**
 *  The sink received data from the MediaSources
 */
@protocol RtccMediaSink <NSObject>

@end

/**
 *  This specialized sink deals with data from VideoSources
 */
@protocol RtccVideoSink <RtccMediaSink>
/**
 *  This method is to be used by MediaSource that creates video. The source deals implicitely with the framerate.
 *
 *  @param data   The data in binary format
 *  @param width  The width of the stream
 *  @param height The height of the stream
 *  @param stride The stride of the stream. Note that the stride is the number of Bytes in a frame's row, independently of the frame format. (i.e ARGB8888 format for a 320px wide picture with no padding will yield a 320*4 total stride).
 *  @param format The format of the frame
 *
 *  @return YES if the frame could be sent, NO otherwise.
 */
- (BOOL)pushVideoFrame:(uint8_t *)data ofWidth:(size_t)width ofHeight:(size_t)height ofStride:(size_t)stride andFormat:(frameFormat_t)format;

@end

/**
 *  The MediaSource is an object that creates data and send it to the sink.
 */
@protocol RtccMediaSource <NSObject>
/**
 *  Called when self.isSendingVideo is YES and, if needed, on setting the source.
 */
- (void)start;
/**
 *  Called when self.isSendingVideo is NO and on removing the source.
 */
- (void)stop;

@property(nonatomic, weak) id<RtccMediaSink> sink;
@end

typedef NS_ENUM(NSInteger, VideoProfile_t) { videoProfile_sd = 0, videoProfile_md, videoProfile_mhd, videoProfile_hd };

/**
 *  This specialized source creates video frames and image.
 */
@protocol RtccVideoSource <RtccMediaSource>

/**
 *  The expected video profile.
 */
@property(nonatomic) video_profile_t videoProfile __attribute__((deprecated("Replaced by [RtccCall.videoOut preferedVideoProfile]. Implements requestedVideoProfileChange: to be notified.")));
@property(nonatomic, weak) id<RtccVideoSink> sink;

@optional
- (void)requestedVideoProfileChange:(VideoProfile_t)requestedProfile;

@end
