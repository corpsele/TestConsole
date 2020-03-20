//
//  IUMEncryptor.m
//  IUMCore
//
//  Created by Chenly on 2016/11/1.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "IUMEncryptor.h"
#import <CommonCrypto/CommonCryptor.h>

size_t const kKeySize = kCCKeySizeAES128;

static NSString *publicKey = @"ea84f809a711eaae";
static NSString *publicIv  = @"873209a711eaae32";

@implementation IUMEncryptor

+ (NSString *)encryptDES:(NSString *)plainText {
//    return [self encryptDES:plainText operation:kCCEncrypt];
    return [IUMEncryptor hg_encryptAES:plainText];
}

+ (NSString *)decryptDES:(NSString *)plainText {
//    return [self encryptDES:plainText operation:kCCDecrypt];
    return [IUMEncryptor hg_decryptAES:plainText];
}

+ (NSString *)encryptDES:(NSString *)plainText operation:(CCOperation)operation {
    
    NSString *key = @"12345678";
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (operation == kCCEncrypt) {
        
        NSData *encryptData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [encryptData length];
        vplainText = (const void *)[encryptData bytes];
    }
    else {
        // 先 Base64 解密
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:plainText options:NSDataBase64DecodingIgnoreUnknownCharacters];
        plainTextBufferSize = [decodedData length];
        vplainText = [decodedData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [key UTF8String];
    Byte  iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
    
    ccStatus = CCCrypt(operation,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeDES,
                       iv,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
        
    NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    
    NSString *result;
    if (operation == kCCEncrypt) {
        // DES 加密后，使用 Base64 加密。
        result = [data base64EncodedStringWithOptions:0];
    }
    else {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    }
    return result;
}



//////////////////////////////////////////////////////////
/////////////////////////   AES加解密   ///////////////////
//////////////////////////////////////////////////////////

+ (NSString *)hg_encryptAES:(NSString *)content{
    
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [publicKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    
    NSData *initVector = [publicIv dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        NSData * temData = [NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize];
        NSString * temString = [temData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString * encryptString = [IUMEncryptor encodeString:temString];
        return [NSString stringWithFormat:@"%@",encryptString];
    }
    free(encryptedBytes);
    return nil;
}

+ (NSString *)hg_decryptAES:(NSString *)content{

    NSString * decodedString = [IUMEncryptor decodeString:content];
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:decodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;

    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [publicKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    
    NSData *initVector = [publicIv dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        NSData * temData = [NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize];
        NSString * temStr = [[NSString alloc] initWithData:temData encoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@",temStr];
    }
    free(decryptedBytes);
    return nil;
}

//编码
+ (NSString*)encodeString:(NSString*)uncodeString{
    NSCharacterSet * charSet = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"] invertedSet];
//    NSString * encodedString = (NSString *)CFBridgingRelease((__bridge CFTypeRef _Nullable)([uncodeString stringByAddingPercentEncodingWithAllowedCharacters:charSet]));
    NSString * encodedString = [uncodeString stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    return encodedString;
}
//解码
+ (NSString*)decodeString:(NSString*)decodeString{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)decodeString, CFSTR("")));
}

@end
