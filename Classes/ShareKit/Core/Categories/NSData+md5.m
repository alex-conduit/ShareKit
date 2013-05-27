#import "NSData+md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (md5)

-(NSString*)md5{
	const char *cStr = [self bytes];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, [self length], digest );
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
								 digest[0], digest[1], 
								 digest[2], digest[3],
								 digest[4], digest[5],
								 digest[6], digest[7],
								 digest[8], digest[9],
								 digest[10], digest[11],
								 digest[12], digest[13],
								 digest[14], digest[15]];
	return s;
}

@end

@implementation NSString(md5)

- (NSString*)md5
{
	// Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
 	// Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
	// Create 16 bytes MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
	// Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end