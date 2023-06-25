//
//  main.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Cocoa/Cocoa.h>
#import "NetworkExtension.h"
#import "SecurityExtension.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
//    [[NetworkExtension shared] install];
    [[SecurityExtension shared] install];
  }
  return NSApplicationMain(argc, argv);
}
