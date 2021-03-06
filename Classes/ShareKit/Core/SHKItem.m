//
//  SHKItem.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/18/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKItem.h"

#import "SHKConfiguration.h"
#import "NSData+SaveItemAttachment.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SHKFormFieldSettings.h"

NSString * const SHKAttachmentSaveDir = @"SHKAttachmentSaveDir";

@interface SHKItem()

@property (nonatomic, strong) NSMutableDictionary *custom;

- (NSString *)shareTypeToString:(SHKShareType)shareType;

@end

//CONDUIT **************start*
@implementation SHKItem_ShareInfo

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_comment forKey:@"comment"];
    [encoder encodeObject:_emailBody forKey:@"emailBody"];
    [encoder encodeObject:_emailSubject forKey:@"emailSubject"];
    [encoder encodeObject:_fbDesc forKey:@"fbDesc"];
    [encoder encodeObject:_shortDesc forKey:@"shortDesc"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_twitterFrom forKey:@"twitterFrom"];
    [encoder encodeObject:_twitterTitle forKey:@"twitterTitle"];
    [encoder encodeObject:_url forKey:@"url"];
    [encoder encodeObject:_userImageUrl forKey:@"userImageUrl"];
    [encoder encodeObject:_picture forKey:@"picture"];
    [encoder encodeObject:_image forKey:@"image"];

}

- (id) initWithCoder: (NSCoder *) decoder {
    if (self = [super init]) {
        self.comment = [decoder decodeObjectForKey: @"comment"];
        self.emailBody = [decoder decodeObjectForKey: @"emailBody"];
        self.emailSubject = [decoder decodeObjectForKey: @"emailSubject"];
        self.fbDesc = [decoder decodeObjectForKey: @"fbDesc"];
        self.shortDesc = [decoder decodeObjectForKey: @"shortDesc"];
        self.title = [decoder decodeObjectForKey: @"title"];
        self.twitterFrom = [decoder decodeObjectForKey: @"twitterFrom"];
        self.twitterTitle = [decoder decodeObjectForKey: @"twitterTitle"];
        self.url = [decoder decodeObjectForKey: @"url"];
        self.userImageUrl = [decoder decodeObjectForKey: @"userImageUrl"];
        self.picture = [decoder decodeObjectForKey: @"picture"];
        self.image = [decoder decodeObjectForKey: @"image"];

    }
    return (self);
}

@end
//**********************end***

@implementation SHKItem

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self setExtensionPropertiesDefaultValues];
    }
    return self;
}

- (void)setExtensionPropertiesDefaultValues {
    
    _printOutputType = [SHKCONFIG(printOutputType) intValue];
    
    _mailToRecipients = SHKCONFIG(mailToRecipients);
    _mailJPGQuality = [SHKCONFIG(mailJPGQuality) floatValue];
    _isMailHTML = [SHKCONFIG(isMailHTML) boolValue];
    _mailShareWithAppSignature = [SHKCONFIG(sharedWithSignature) boolValue];
    
    _facebookURLShareDescription = SHKCONFIG(facebookURLShareDescription);
    _facebookURLSharePictureURI = SHKCONFIG(facebookURLSharePictureURI);
    
    _textMessageToRecipients = SHKCONFIG(textMessageToRecipients);
	_popOverSourceRect = CGRectFromString(SHKCONFIG(popOverSourceRect));
}

//CONDUIT **************start*
+ (id)shareInfo:(SHKItem_ShareInfo *)shareInfo contentType:(SHKURLContentType)type {
    SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeURL;
    if (type == SHKURLFacebookLike)
        item.shareType = SHKFacebookLike;
    else if (type == SHKURLFacebookUnLike)
        item.shareType = SHKFacebookUnLike;
    else if (type == SHKURLFacebookComment)
        item.shareType = SHKFacebookComment;
    else if (type == SHKURLFacebookDialogWithHtml)
        item.shareType = SHKFacebookDialogWithHtml;
    else if (type == SHKURLContentTypeImage)
    {
        item.shareType = SHKShareTypeImage;
        item.image = shareInfo.image;
    }

    item.URLContentType = type;
	item.shareInfo = shareInfo;
    item.title = shareInfo.title;
    item.URL = [NSURL URLWithString: shareInfo.url];
    item.text = shareInfo.fbDesc;
    item.emailBody = shareInfo.emailBody;
    item.facebookURLShareDescription = shareInfo.fbDesc;
    //item.facebookURLSharePictureURI = shareInfo.picture;
	return item;
}
//**********************end***

+ (id)URL:(NSURL *)url
{
	return [self URL:url title:nil contentType:SHKURLContentTypeWebpage];
}

+ (id)URL:(NSURL *)url title:(NSString *)title
{
	return [self URL:url title:title contentType:SHKURLContentTypeWebpage];
}

+ (id)URL:(NSURL *)url title:(NSString *)title contentType:(SHKURLContentType)type {
    
    SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeURL;
	item.URL = url;
	item.title = title;
    item.URLContentType = type;
	
	return item;
    
}

+ (id)image:(UIImage *)image
{
	return [SHKItem image:image title:nil];
}

+ (id)image:(UIImage *)image title:(NSString *)title
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeImage;
	item.image = image;
	item.title = title;
	
	return item;
}

+ (id)text:(NSString *)text
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeText;
	item.text = text;
	
	return item;
}

+ (id)filePath:(NSString *)path title:(NSString *)title;
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeFile;
    
    SHKFile *file = [[SHKFile alloc] initWithFilePath:path];
    item.file = file;
	item.title = title;
	
	return item;
}

+ (id)fileData:(NSData *)data filename:(NSString *)filename title:(NSString *)title
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeFile;
    
    if (!filename) filename = title;
    
    SHKFile *file = [[SHKFile alloc] initWithFileData:data filename:filename];
    item.file = file;
	item.title = title;
	
	return item;
}

+ (id)file:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType title:(NSString *)title {
    
    return [[self class] fileData:data filename:filename title:title];
}

- (void)convertImageShareToFileShareOfType:(SHKImageConversionType)conversionType quality:(CGFloat)quality {
    
    if (!self.image) return;
    
    self.shareType = SHKShareTypeFile;
    
    NSData *imageData = nil;
    NSString *extension = nil;
    
    switch (conversionType) {
        case SHKImageConversionTypeJPG:
            imageData = UIImageJPEGRepresentation(self.image, quality);
            extension = @"jpg";
            break;
        case SHKImageConversionTypePNG:
            imageData = UIImagePNGRepresentation(self.image);
            extension = @"png";
            break;
        default:
            break;
    }
    
    NSString *rawFileName = nil;
    if (self.title.length > 0) {
        rawFileName = self.title;
    } else {
        rawFileName = @"Image";
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@.%@", rawFileName, extension];
    SHKFile *aFile = [[SHKFile alloc] initWithFileData:imageData filename:filename];
    self.file = aFile;
    
    self.image = nil;
}

#pragma mark -

- (void)setCustomValue:(id)value forKey:(NSString *)key
{
	if (self.custom == nil)
		self.custom = [NSMutableDictionary dictionaryWithCapacity:0];
	
	if (value == nil)
		[self.custom removeObjectForKey:key];
		
	else
		[self.custom setObject:value forKey:key];
}

- (NSString *)customValueForKey:(NSString *)key
{
	return [self.custom objectForKey:key];
}

- (BOOL)customBoolForSwitchKey:(NSString *)key
{
	return [[self.custom objectForKey:key] isEqualToString:SHKFormFieldSwitchOn];
}

#pragma mark -
#pragma mark NSCoding

#pragma mark ---
#pragma mark NSCoding

static NSString *kSHKShareType = @"kSHKShareType";
static NSString *kSHKURLContentType = @"kSHKURLContentType";
static NSString *kSHKURL = @"kSHKURL";
static NSString *kSHKTitle = @"kSHKTitle";
static NSString *kSHKText = @"kSHKText";
static NSString *kSHKEmailBody = @"kSHKEmailBody";
static NSString *kSHKTags = @"kSHKTags";
static NSString *kSHKCustom = @"kSHKCustom";
static NSString *kSHKFile = @"kSHKFile";
static NSString *kSHKImage = @"kSHKImage";
static NSString *kSHKPrintOutputType = @"kSHKPrintOutputType";
static NSString *kSHKMailToRecipients = @"kSHKMailToRecipients";
static NSString *kSHKIsMailHTML = @"kSHKIsMailHTML";
static NSString *kSHKMailJPGQuality = @"kSHKMailJPGQuality";
static NSString *kSHKMailShareWithAppSignature = @"kSHKMailShareWithAppSignature";
static NSString *kSHKFacebookURLShareDescription = @"kSHKFacebookURLShareDescription";
static NSString *kSHKFacebookURLSharePictureURI = @"kSHKFacebookURLSharePictureURI";
static NSString *kSHKTextMessageToRecipients = @"kSHKTextMessageToRecipients";
static NSString *kSHKPopOverSourceRect = @"kSHKPopOverSourceRect";

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (self) {
        
        _shareType = [decoder decodeIntForKey:kSHKShareType];
        _URLContentType = [decoder decodeIntForKey:kSHKURLContentType];

        _URL = [decoder decodeObjectForKey:kSHKURL];
        _title = [decoder decodeObjectForKey:kSHKTitle];
        _text = [decoder decodeObjectForKey:kSHKText];
        _emailBody = [decoder decodeObjectForKey:kSHKEmailBody];
        _tags = [decoder decodeObjectForKey:kSHKTags];
        _custom = [decoder decodeObjectForKey:kSHKCustom];
        _file = [decoder decodeObjectForKey:kSHKFile];
        _image = [decoder decodeObjectForKey:kSHKImage];
        _printOutputType = [decoder decodeIntForKey:kSHKPrintOutputType];
        _mailToRecipients = [decoder decodeObjectForKey:kSHKMailToRecipients];
        _isMailHTML = [decoder decodeBoolForKey:kSHKIsMailHTML];
        _mailJPGQuality = [decoder decodeFloatForKey:kSHKMailJPGQuality];
        _mailShareWithAppSignature = [decoder decodeBoolForKey:kSHKMailShareWithAppSignature];
        _facebookURLShareDescription = [decoder decodeObjectForKey:kSHKFacebookURLShareDescription];
        _facebookURLSharePictureURI = [decoder decodeObjectForKey:kSHKFacebookURLSharePictureURI];
        _textMessageToRecipients = [decoder decodeObjectForKey:kSHKTextMessageToRecipients];
        _popOverSourceRect = CGRectFromString([decoder decodeObjectForKey:kSHKPopOverSourceRect]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeInt:self.shareType forKey:kSHKShareType];
    [encoder encodeInt:self.URLContentType forKey:kSHKURLContentType];
    [encoder encodeObject:self.URL forKey:kSHKURL];
    [encoder encodeObject:self.title forKey:kSHKTitle];
    [encoder encodeObject:self.text forKey:kSHKText];
    [encoder encodeObject:self.emailBody forKey:kSHKEmailBody];
    [encoder encodeObject:self.tags forKey:kSHKTags];
    [encoder encodeObject:self.custom forKey:kSHKCustom];
    [encoder encodeObject:self.file forKey:kSHKFile];
    [encoder encodeObject:self.image forKey:kSHKImage];
    [encoder encodeInt:self.printOutputType forKey:kSHKPrintOutputType];
    [encoder encodeObject:self.mailToRecipients forKey:kSHKMailToRecipients];
    [encoder encodeBool:self.isMailHTML forKey:kSHKIsMailHTML];
    [encoder encodeFloat:self.mailJPGQuality forKey:kSHKMailJPGQuality];
    [encoder encodeBool:self.mailShareWithAppSignature forKey:kSHKMailShareWithAppSignature];
    [encoder encodeObject:self.facebookURLShareDescription forKey:kSHKFacebookURLShareDescription];
    [encoder encodeObject:self.facebookURLSharePictureURI forKey:kSHKFacebookURLSharePictureURI];
    [encoder encodeObject:self.textMessageToRecipients forKey:kSHKTextMessageToRecipients];
    [encoder encodeObject:NSStringFromCGRect(self.popOverSourceRect) forKey:kSHKPopOverSourceRect];
}

#pragma mark -

- (NSString *)description {

    NSString *result = [NSString stringWithFormat:@"Share type: %@\nURL:%@\n\
                                                    URLContentType: %i\n\
                                                    Image:%@\n\
                                                    Title: %@\n\
                                                    Text: %@\n\
                                                    EmailBody: %@\n\
                                                    Tags:%@\n\
                                                    Custom fields:%@\n\n\
                                                    Sharer specific\n\n\
                                                    Print output type: %i\n\
													mailToRecipients: %@\n\
                                                    isMailHTML: %i\n\
                                                    mailJPGQuality: %f\n\
                                                    mailShareWithAppSignature: %i\n\
                                                    facebookURLSharePictureURI: %@\n\
                                                    facebookURLShareDescription: %@\n\
                                                    textMessageToRecipients: %@\n\
                                                    popOverSourceRect: %@",
						
                                                    [self shareTypeToString:self.shareType],
                                                    [self.URL absoluteString],
                                                    self.URLContentType,
                                                    [self.image description], 
                                                    self.title, self.text, self.emailBody,
                                                    self.tags, 
                                                    [self.custom description],
                                                    self.printOutputType,
													self.mailToRecipients,
                                                    self.isMailHTML,
                                                    self.mailJPGQuality,
                                                    self.mailShareWithAppSignature,
                                                    self.facebookURLSharePictureURI,
                                                    self.facebookURLShareDescription,
                                                    self.textMessageToRecipients,
													NSStringFromCGRect(self.popOverSourceRect)];    
    return result;
}

- (NSString *)shareTypeToString:(SHKShareType)type {
    
    NSString *result = nil;
    
    switch(type) {
            
        case SHKShareTypeUndefined:
            result = @"SHKShareTypeUndefined";
            break;
        case SHKShareTypeURL:
            result = @"SHKShareTypeURL";
            break;
        case SHKShareTypeText:
            result = @"SHKShareTypeText";
            break;
        case SHKShareTypeImage:
            result = @"SHKShareTypeImage";
            break;
        case SHKShareTypeFile:
            result = @"SHKShareTypeFile";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}

@end
