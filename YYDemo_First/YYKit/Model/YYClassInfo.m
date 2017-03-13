//
//  YYClassInfo.m
//  YYKitDemo_First
//
//  Created by chen on 2017/3/7.
//  Copyright © 2017年 lucky. All rights reserved.
//

#import "YYClassInfo.h"


YYEncodingType YYEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return YYEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown;
    
    YYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return YYEncodingTypeBlock | qualifier;
            else
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
    }
}


// ivarClassInfo
@implementation YYClassIvarInfo
- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) {
        return nil;
    }
    self = [super init];
    if (self) {
        _ivar = ivar;
        const char* name = ivar_getName(ivar);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        const char* typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = YYEncodingGetType(typeEncoding);
        }
        _offset = ivar_getOffset(ivar);
    }
    return self;
}


@end

// method info
@implementation YYClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) {
        return nil;
    }
    self = [super init];
    if (self) {
        _method = method;
        _sel = method_getName(method);
        _imp = method_getImplementation(method);
        const char* name = sel_getName(method_getName(method));
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        
        const char* typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        }
        char* returnType = method_copyReturnType(method);
        if (returnType) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
            free(returnType);
        }
        
        unsigned int argumentCount = method_getNumberOfArguments(method);
        if (argumentCount > 0) {
            NSMutableArray* arguments = [NSMutableArray arrayWithCapacity:0];
            for (unsigned int i = 0; i < argumentCount; i ++) {
                char* argumentType = method_copyArgumentType(method, i);
                NSString* type = argumentType ? [NSString stringWithUTF8String:argumentType] : @"";
                [arguments addObject:type];
                if (argumentType) {
                    free(argumentType);
                }
            }
            _argumentTypeEncodings = arguments;
        }
        
    }
    return self;
}

@end



@implementation YYClassPropertyInfo
- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }
    self = [super init];
    _property = property;
    if (self) {
        const char* name = property_getName(property);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        
        YYEncodingType type = 0;
        unsigned int attrCount;
        objc_property_attribute_t* attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': { // type encoding
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = YYEncodingGetType(attrs[i].value);
                        
                        if ((type & YYEncodingTypeMask) == YYEncodingTypeObject && _typeEncoding.length) {
                            NSScanner* scanner = [NSScanner scannerWithString:_typeEncoding];
                            if (![scanner scanString:@"@\"" intoString:NULL]) {
                                continue;
                            }
                            
                            NSString* clsName = nil;
                            if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                if (clsName.length) {
                                    _cls = objc_getClass(clsName.UTF8String);
                                }
                            }
                            
                            // 获取代理
                            NSMutableArray* protocols = nil;
                            while ([scanner scanString:@"<" intoString:NULL]) {
                                NSString* protocol = nil;
                                if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                    if (!protocols) {
                                        protocols = [[NSMutableArray alloc] init];
                                    }
                                    [protocols addObject:protocol];
                                }
                                [scanner scanString:@">" intoString:NULL];
                            }
                            _protocols = protocols;
                        }
                    }
                } break;
                case 'V': { // instance variable
                    if (attrs[i].value) {
                        _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                    }
                } break;
                case 'R': {
                    type |= YYEncodingTypePropertyReadonly;
                } break;
                case 'C': {
                    type |= YYEncodingTypePropertyCopy;
                } break;
                case '&': {
                    type |= YYEncodingTypePropertyRetain;
                } break;
                case 'N': {
                    type |= YYEncodingTypePropertyNonatomic;
                } break;
                case 'D': {
                    type |= YYEncodingTypePropertyDynamic;
                } break;
                case 'W': {
                    type |= YYEncodingTypePropertyWeak;
                } break;
                case 'G': {
                    type |= YYEncodingTypePropertyCustomGetter;
                    if (attrs[i].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                    
                } break;
                case 'S': {
                    type |= YYEncodingTypePropertyCustomSetter;
                    if (attrs[i].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                } break;
                default:
                    break;
            }
        }
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }
        _type = type;
        if (_name.length) {
            if (!_getter) {
                _getter = NSSelectorFromString(_name);
            }
            if (!_setter) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
            }
        }
        
    }
    return self;
}

@end


@implementation YYClassInfo {
    BOOL _needupdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    self = [super init];
    if (self) {
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _isMeta = class_isMetaClass(cls);
        if (!_isMeta) {
            _metaCls = objc_getMetaClass(class_getName(cls));
        }
        _name = NSStringFromClass(cls);
        // 更新什么?
        [self _update];
        
        _superClassInfo = [self.class classInfoWithClass:_superCls];
    }
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
#error 这里要接着写
    
}


- (void)setNeddUpdate {
    _needupdate = YES;
}

- (BOOL)needUpdate {
    return _needupdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    YYClassInfo* info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void*)(cls));
    if (info && info->_needupdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[YYClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void*)(cls), (__bridge const void*)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}


@end
