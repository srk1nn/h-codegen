// This file was automatically generated and should not be edited.

#import <Foundation/Foundation.h>
#import "InteroperabilityMacro.h"

@protocol HCInternalProtocol
- (void)internalFunc;
@end

@interface HCInternalClass : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM_NAMED(NSInteger, HCInternalNestedEnum, "HCInternalNestedEnum", closed) {
  HCInternalNestedEnumOne = 0,
  HCInternalNestedEnumTwo = 1,
};

@interface HCInternalClass (SWIFT_EXTENSION(DemoFramework)) <HCInternalProtocol>
- (void)internalFunc;
@end