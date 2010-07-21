//
//  UrlLoader.m
//  a simple class to make a http request. 
//
//  Created by EddyL on 2010/04/06.
//  Copyright 2010 EddyL. All rights reserved.
//

#import "UrlLoader.h"
NSString * const URLLOADER_DID_LOAD_SUCCESSFULLY = @"URLLOADER_DID_LOAD_SUCCESSFULLY";
NSString * const URLLOADER_DID_LOAD_FAILED = @"URLLOADER_DID_LOAD_FAILED";

@interface UrlLoader () 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
+ (NSString *) convertDictionaryToUrlParamString: (NSDictionary *) dict;
@end

@implementation UrlLoader : NSObject {
}
	@synthesize urlRequest = _urlRequest;
	@synthesize receivedData = _receivedData;
	@synthesize urlConnection = _urlConnection;
	+ (UrlLoader *) urlLoaderWith: (NSString *) iUrl andPostVariable: (NSDictionary *) postVar andGetVariable: (NSDictionary *) getVar {
		
		NSMutableString *url = [NSString stringWithString:iUrl];
		//process the get variable
			if (getVar != nil && [getVar count] > 0) {
				[url appendFormat:@"?%@", [self convertDictionaryToUrlParamString:getVar]];
			}
		
		//create the request
			NSMutableURLRequest *iUrlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		
		
		//process the post variable
			if (postVar != nil) {
				[iUrlRequest setHTTPMethod:@"POST"];
				
				//create the post variable
					[iUrlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
				
				//create the body
					NSString *postString = [UrlLoader convertDictionaryToUrlParamString:postVar];
					NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
					[iUrlRequest setHTTPBody:postData];
				
				//set content length
					[iUrlRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
			}
			else {
				[iUrlRequest setHTTPMethod:@"GET"];
			}
		
		
		
		//create the loader
			UrlLoader *urlLoader = [[[UrlLoader alloc] init] autorelease];
			
			urlLoader.urlRequest = iUrlRequest;
			urlLoader.receivedData = nil;
			urlLoader.urlConnection = nil;
		return urlLoader;
	}
	- (void) load {
		//retain myself
			[[[self retain] autorelease] retain];
		
		//create the received data
			self.receivedData = [NSMutableData data];
		//start loading
			self.urlConnection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
	}
	- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
		[self.receivedData setLength:0];
	}
	- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
		[self.receivedData appendData:data];
	}
	- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
		[[NSNotificationCenter defaultCenter] postNotificationName:URLLOADER_DID_LOAD_FAILED 
															object:self userInfo:nil];
		[self release];
	}
	- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
		[[NSNotificationCenter defaultCenter] postNotificationName:URLLOADER_DID_LOAD_SUCCESSFULLY 
															object:self userInfo:nil];
		[self release];
	}
	- (void) dealloc {
		[self.urlRequest release];
		if (self.receivedData != nil) {
			[self.receivedData release];
		}
		if (self.urlConnection != nil) {
			[self.urlConnection release];
		}
		[super dealloc];
	}
	+ (NSString *) urlEncodeString: (NSString *) str {
		return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)str,  NULL,  (CFStringRef)@"!*'();:@&=+$,/?%#[]",  kCFStringEncodingUTF8);
	}
	+ (NSString *) convertDictionaryToUrlParamString: (NSDictionary *) dict {
		NSMutableString *paramString = [NSMutableString string];
		for (id key in dict) {
			[paramString appendFormat:@"%@=%@&", [UrlLoader urlEncodeString:key], [UrlLoader urlEncodeString:[dict objectForKey:key]]];
		}
		
		return paramString;
	}
@end
