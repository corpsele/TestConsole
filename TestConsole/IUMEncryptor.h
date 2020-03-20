//
//  IUMEncryptor.h
//  IUMCore
//
//  Created by Chenly on 2016/11/1.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IUMEncryptor : NSObject

+ (NSString *)encryptDES:(NSString *)plainText;
+ (NSString *)decryptDES:(NSString *)plainText;

@end
