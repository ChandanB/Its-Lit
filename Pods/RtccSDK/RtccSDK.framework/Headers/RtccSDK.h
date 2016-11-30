//
//  RtccSDK.h
//  RtccSDK
//
//  Created by Charles Thierry on 22/06/15.
//  Copyright (c) 2015 Weemo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for RtccSDK.
FOUNDATION_EXPORT double RtccSDKVersionNumber;

//! Project version string for RtccSDK.
FOUNDATION_EXPORT const unsigned char RtccSDKVersionString[];

#define RtccSDKBundleVersion ( @"6.5.8" )

// In this header, you should import all the public headers of your framework using statements like #import <RtccSDK/PublicHeader.h>
#import <RtccSDK/RtccData.h>
#import <RtccSDK/RtccProtocols.h>
#import <RtccSDK/RtccContact.h>
#import <RtccSDK/RtccVideoOut.h>
#import <RtccSDK/RtccCall.h>
#import <RtccSDK/Rtcc.h>

#import <RtccSDK/RtccLogDelegate.h>

#import <RtccSDK/RtccDefaultVideoSource.h>
