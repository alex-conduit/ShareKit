//
//  SHKFormFieldLargeTextSettings.m
//  ShareKit
//
//  Created by Vilem Kurz on 30/07/2013.
//
//

#import "SHKFormFieldLargeTextSettings.h"

@implementation SHKFormFieldLargeTextSettings

+ (SHKFormFieldLargeTextSettings *)label:(NSString *)l
                                     key:(NSString *)k
                                    type:(SHKFormFieldType)t
                                   start:(NSString *)s
                           maxTextLength:(NSUInteger)maxTextLength
                                   image:(UIImage *)image
                         imageTextLength:(NSUInteger)imageTextLength
                                 hasLink:(BOOL)hasLink
                          allowEmptySend:(BOOL)allowEmpty
                                  select:(BOOL)select {
    
    SHKFormFieldLargeTextSettings *result = [[SHKFormFieldLargeTextSettings alloc] initWithLabel:l key:k type:t start:s];
    result.maxTextLength = maxTextLength;
    result.image = image;
    result.imageTextLength = imageTextLength;
    result.hasLink = hasLink;
    result.allowSendingEmptyMessage = allowEmpty;
    result.select = select;
    
    return result;
}

- (BOOL)isValid {
    
    BOOL emptyCriterium = self.allowSendingEmptyMessage || [self.valueToSave length] > 0;
    BOOL maxTextLenCriterium = [self.valueToSave length] <= self.maxTextLength;
    
    if (emptyCriterium && maxTextLenCriterium) {
        return YES;
    } else {
        return NO;
    }
}

@end