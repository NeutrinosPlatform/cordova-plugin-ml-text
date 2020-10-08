#import <Cordova/CDV.h>
@import MLKitTextRecognition;

@interface Mltext : CDVPlugin

@property CDVInvokedUrlCommand* commandglo;
// @property GMVDetector* textDetector;
@property UIImage* image;

- (void) getText:(CDVInvokedUrlCommand*)command;
- (UIImage *)resizeImage:(UIImage *)image;
- (NSData *)retrieveAssetDataPhotosFramework:(NSURL *)urlMedia;

@end
