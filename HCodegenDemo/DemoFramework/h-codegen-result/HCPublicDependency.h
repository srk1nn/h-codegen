// This file was automatically generated and should not be edited.

#import <Foundation/Foundation.h>
#import "InteroperabilityMacro.h"
#import <DemoFramework/DemoFramework-Swift.h>

@class HCPublicClass;

@interface HCPublicDependency : NSObject <HCPublicProtocol>
@property (nonatomic, readonly, strong) HCPublicClass * _Nonnull publicClass;
- (nonnull instancetype)initWithPublicClass:(HCPublicClass * _Nonnull)publicClass OBJC_DESIGNATED_INITIALIZER;
- (void)protocolPublicMethod;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end
