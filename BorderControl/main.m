//
//  main.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Cocoa/Cocoa.h>
#import "NetworkExtension.h"
#import "NetworkCommunication.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    [[NetworkExtension shared] install];
    
    NSObject *delegate = [NSObject new];
    NetworkCommunication *sharedConnection = [NetworkCommunication shared];
    [sharedConnection
      registerWithExtension:[sharedConnection extensionBundle]
      delegate:delegate
      completionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"#bordercontrol: xpc connection was established");
          
          [[NetworkCommunication shared] logger:@"long-message-string" responseHandler:^(BOOL) {
            NSLog(@"#bordercontrol: xpc logs were delivered");
          }];
        });
      }];
  }
  return NSApplicationMain(argc, argv);
}
