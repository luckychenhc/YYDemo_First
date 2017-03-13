//
//  YYClassInfo.h
//  YYKitDemo_First
//
//  Created by chen on 2017/3/7.
//  Copyright © 2017年 lucky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, YYEncodingType) {
    YYEncodingTypeMask       = 0xFF, ///< mask of type value
    YYEncodingTypeUnknown    = 0, ///< unknown
    YYEncodingTypeVoid       = 1, ///< void
    YYEncodingTypeBool       = 2, ///< bool
    YYEncodingTypeInt8       = 3, ///< char / BOOL
    YYEncodingTypeUInt8      = 4, ///< unsigned char
    YYEncodingTypeInt16      = 5, ///< short
    YYEncodingTypeUInt16     = 6, ///< unsigned short
    YYEncodingTypeInt32      = 7, ///< int
    YYEncodingTypeUInt32     = 8, ///< unsigned int
    YYEncodingTypeInt64      = 9, ///< long long
    YYEncodingTypeUInt64     = 10, ///< unsigned long long
    YYEncodingTypeFloat      = 11, ///< float
    YYEncodingTypeDouble     = 12, ///< double
    YYEncodingTypeLongDouble = 13, ///< long double
    YYEncodingTypeObject     = 14, ///< id
    YYEncodingTypeClass      = 15, ///< Class
    YYEncodingTypeSEL        = 16, ///< SEL
    YYEncodingTypeBlock      = 17, ///< block
    YYEncodingTypePointer    = 18, ///< void*
    YYEncodingTypeStruct     = 19, ///< struct
    YYEncodingTypeUnion      = 20, ///< union
    YYEncodingTypeCString    = 21, ///< char*
    YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
YYEncodingType YYEncodingGetType(const char *typeEncoding);

/**
 Instance variable information.
 */
@interface YYClassIvarInfo : NSObject
@property (assign, nonatomic, readonly) Ivar ivar;
@property (copy,   nonatomic, readonly) NSString* name;
@property (assign, nonatomic, readonly) ptrdiff_t offset;
@property (copy,   nonatomic, readonly) NSString* typeEncoding;
@property (assign, nonatomic, readonly) YYEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end

/**
 Method information.
 */

@interface YYClassMethodInfo : NSObject
@property (assign, nonatomic, readonly) Method method;
@property (copy,   nonatomic, readonly) NSString* name;
@property (assign, nonatomic, readonly) SEL sel;
@property (assign, nonatomic, readonly) IMP imp;
@property (copy,   nonatomic, readonly) NSString* typeEncoding;
@property (copy,   nonatomic, readonly) NSString* returnTypeEncoding;
@property (strong, nonatomic, readonly, nullable) NSArray<NSString*>* argumentTypeEncodings;


- (instancetype)initWithMethod:(Method)method;
@end


@interface YYClassPropertyInfo : NSObject
@property (assign, nonatomic) objc_property_t property;
@property (copy,   nonatomic) NSString* name;
@property (assign, nonatomic) YYEncodingType type;
@property (copy,   nonatomic) NSString* typeEncoding;
@property (copy,   nonatomic) NSString* ivarName;
@property (assign, nonatomic) Class cls;
@property (strong, nonatomic) NSArray<NSString*>* protocols;
@property (assign, nonatomic) SEL setter;
@property (assign, nonatomic) SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

/**
 Class information for a class.
 */
@interface YYClassInfo : NSObject
@property (assign, nonatomic) Class cls;
@property (assign, nonatomic) Class superCls;
@property (assign, nonatomic) Class metaCls;
@property (assign, nonatomic) BOOL isMeta;
@property (copy,   nonatomic) NSString* name;
@property (strong, nonatomic) YYClassInfo* superClassInfo;
@property (strong, nonatomic) NSDictionary<NSString*, YYClassIvarInfo*>* ivarInfos;
@property (strong, nonatomic) NSDictionary<NSString*, YYClassMethodInfo*>* methodInfos;
@property (strong, nonatomic) NSDictionary<NSString*, YYClassPropertyInfo*>* propertyInfos;

- (void)setNeddUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString*)className;

@end

NS_ASSUME_NONNULL_END
