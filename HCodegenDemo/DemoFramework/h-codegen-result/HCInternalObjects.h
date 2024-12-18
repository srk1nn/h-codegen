// This file was automatically generated and should not be edited.

#import <Foundation/Foundation.h>
#import "InteroperabilityMacro.h"

@protocol HCInternalProtocol
- (void)protocolInternalMethod;
@end

@interface HCInternalClass : NSObject
+ (void)classInternalMethod;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM_NAMED(NSInteger, HCInternalNestedEnum, "HCInternalNestedEnum", closed) {
  HCInternalNestedEnumOne = 0,
  HCInternalNestedEnumTwo = 1,
};

@interface HCInternalClass (SWIFT_EXTENSION(DemoFramework)) <HCInternalProtocol>
- (void)protocolInternalMethod;
@end