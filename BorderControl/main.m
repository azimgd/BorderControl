//
//  main.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Cocoa/Cocoa.h>
#import "NetworkExtension.h"
#import "ExtensionBundle.h"
#import "HostCommunication.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    HostCommunication *hostCommunication = [HostCommunication new];
    [hostCommunication connect];

    [[NetworkExtension shared] install];
  }
  return NSApplicationMain(argc, argv);
}
