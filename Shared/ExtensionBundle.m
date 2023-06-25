//
//  ExtensionBundle.m
//  BorderControl
//
//  Created by azimgd on 14.06.2023.
//

#import <Foundation/Foundation.h>
#import "ExtensionBundle.h"

@implementation ExtensionBundle

static ExtensionBundle *sharedInstance = nil;

+ (ExtensionBundle *)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ExtensionBundle alloc] init];
  });
  return sharedInstance;
}

- (NSBundle *)extensionBundle:(NSBundle *)bundle; {
  NSURL *extensionsDirectoryURL = [NSURL
    fileURLWithPath:@"Contents/Library/SystemExtensions"
    relativeToURL:[[NSBundle mainBundle] bundleURL]];
  NSArray<NSURL *> *extensionURLs;
  NSError *error;

  extensionURLs = [[NSFileManager defaultManager]
    contentsOfDirectoryAtURL:extensionsDirectoryURL
    includingPropertiesForKeys:nil
    options:NSDirectoryEnumerationSkipsHiddenFiles
    error:&error];

  if (error) {
    NSString *errorMessage = [NSString
      stringWithFormat:@"Failed to get the contents of %@: %@",
      extensionsDirectoryURL.absoluteString,
      error.localizedDescription];

    @throw [NSException
      exceptionWithName:NSGenericException
      reason:errorMessage
      userInfo:nil];
  }

  if (extensionURLs.count == 0) {
    @throw [NSException
      exceptionWithName:NSGenericException
      reason:@"Failed to find any system extensions"
      userInfo:nil];
  }

  NSBundle *extensionBundle = [NSBundle bundleWithURL:extensionURLs.firstObject];
  if (!extensionBundle) {
    NSString *errorMessage = [NSString
      stringWithFormat:@"Failed to create a bundle with URL %@",
      extensionURLs.firstObject.absoluteString];

    @throw [NSException exceptionWithName:NSGenericException reason:errorMessage userInfo:nil];
  }

  return extensionBundle;
}


- (NSString *)extensionBundleMachService:(NSBundle *)bundle {
  NSDictionary *networkExtensionKeys = [bundle objectForInfoDictionaryKey:@"NetworkExtension"];
  NSString *machServiceName = networkExtensionKeys[@"NEMachServiceName"];

  if (!machServiceName) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Mach service name is missing from the Info.plist"
      userInfo:nil];
  }

  return machServiceName;
}

@end
