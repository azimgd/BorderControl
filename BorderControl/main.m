//
//  main.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Cocoa/Cocoa.h>
#import "NetworkExtension.h"
#import "NetworkCommunication.h"
#import "ExtensionBundle.h"

@interface NetworkDelegate : NSObject<HostCommunication>

@end

@implementation NetworkDelegate

- (void)register:(void (^)(BOOL))completionHandler {
  NSLog(@"[#bordercontrol]: xpc logs were delivered");
}

@end

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    [[NetworkExtension shared] install];
    
    NetworkDelegate *networkDelegate = [NetworkDelegate new];
    [[NetworkCommunication shared]
      registerWithExtension:[[ExtensionBundle shared] extensionBundle:[NSBundle mainBundle]]
      delegate:networkDelegate
      completionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"[#bordercontrol]: xpc connection was established");
          
          [[NetworkCommunication shared] logger:@"long-message-string" responseHandler:^(BOOL result) {
            
          }];
        });
      }];
  }
  return NSApplicationMain(argc, argv);
}
