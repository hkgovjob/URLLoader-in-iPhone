//
//  UrlLoader.h
//  make a http request
//
//  Created by eddy on 2010/04/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const URLLOADER_DID_LOAD_SUCCESSFULLY;
extern NSString * const URLLOADER_DID_LOAD_FAILED;


@interface UrlLoader : NSObject {
	NSURLRequest *_urlRequest;
	NSMutableData *_receivedData;
	NSURLConnection *_urlConnection;
}
@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
+ (UrlLoader *) urlLoaderWith: (NSString *) url andPostVariable: (NSDictionary *) postVar andGetVariable: (NSDictionary *) getVar;
+ (NSString *) urlEncodeString: (NSString *) str;
- (void) load;
@end
