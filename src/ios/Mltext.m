#import "Mltext.h"
#import <Photos/Photos.h>
#import <MLKitVision/MLKitVision.h>

@implementation Mltext
#define NORMFILEURI ((int) 0)
#define NORMNATIVEURI ((int) 1)
#define FASTFILEURI ((int) 2)
#define FASTNATIVEURI ((int) 3)
#define BASE64 ((int) 4)

- (void)getText:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try
        {
            self.commandglo = command;
            int stype = NORMFILEURI; // sourceType
            NSString* name;
            self.image = NULL;
            @try {
                NSString *st =[self.commandglo argumentAtIndex:0 withDefault:@(0)];
                stype = [st intValue];
                name = [self.commandglo argumentAtIndex:1];
            }
            @catch (NSException *exception) {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:@"argument/parameter type mismatch error"];
                [self.commandDelegate sendPluginResult:result callbackId:self.commandglo.callbackId];
            }
            
            if (stype == NORMFILEURI || stype == NORMNATIVEURI || stype == FASTFILEURI || stype == FASTNATIVEURI)
            {
                if (stype==NORMFILEURI)
                {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
                    self.image = [UIImage imageWithData:imageData];
                }
                else if (stype==NORMNATIVEURI)
                {
                    NSString *urlString = [NSString stringWithFormat:@"%@", name];
                    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                    NSData *imageData = [self retrieveAssetDataPhotosFramework:url];
                    self.image = [UIImage imageWithData:imageData];
                }
                else if (stype==FASTFILEURI)
                {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
                    self.image = [UIImage imageWithData:imageData];
                    self.image = [self resizeImage:self.image];
                }
                else if (stype==FASTNATIVEURI)
                {
                    NSString *urlString = [NSString stringWithFormat:@"%@", name];
                    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                    NSData *imageData = [self retrieveAssetDataPhotosFramework:url];
                    self.image = [UIImage imageWithData:imageData];
                    self.image = [self resizeImage:self.image];
                }
                
            }
            else if (stype==BASE64)
            {
                NSData *data = [[NSData alloc]initWithBase64EncodedString:name options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self.image = [UIImage imageWithData:data];
            }
            else
            {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:@"sourceType argument should be 0,1,2,3 or 4"];
                [self.commandDelegate sendPluginResult:result callbackId:self.commandglo.callbackId];
            }
            
            
            if (self.image!=NULL)
            {
                MLKTextRecognizer *textRecognizer = [MLKTextRecognizer textRecognizer];
                MLKVisionImage *image = [[MLKVisionImage alloc] initWithImage:self.image];
                [textRecognizer processImage:image
                                  completion:^(MLKText *_Nullable result,
                                               NSError *_Nullable error) {
                                      if (error != nil || result == nil) {
                                          if (result==nil) {
                                              CDVPluginResult* resulta = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No text found in image"];
                                              [self.commandDelegate sendPluginResult:resulta callbackId: self.commandglo.callbackId];
                                          }
                                          else
                                          {
                                              CDVPluginResult* resulta = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error with Text Recognition Module"];
                                              [self.commandDelegate sendPluginResult:resulta callbackId: self.commandglo.callbackId];
                                          }
                                      }
                                      
                                      NSMutableDictionary* resultobjmut = [[NSMutableDictionary alloc] init];
                                      NSMutableDictionary* blockobj = [[NSMutableDictionary alloc] init];
                                      NSMutableDictionary* lineobj = [[NSMutableDictionary alloc] init];
                                      NSMutableDictionary* wordobj = [[NSMutableDictionary alloc] init];
                                      
                                      NSMutableArray* blocktext = [[NSMutableArray alloc] init];
                                      NSMutableArray* blockpoints = [[NSMutableArray alloc] init];
                                      NSMutableArray* blockframe = [[NSMutableArray alloc] init];
                                      
                                      NSMutableArray* linetext = [[NSMutableArray alloc] init];
                                      NSMutableArray* linepoints = [[NSMutableArray alloc] init];
                                      NSMutableArray* lineframe = [[NSMutableArray alloc] init];
                                      
                                      NSMutableArray* wordtext = [[NSMutableArray alloc] init];
                                      NSMutableArray* wordpoints = [[NSMutableArray alloc] init];
                                      NSMutableArray* wordframe = [[NSMutableArray alloc] init];
                                      
                                      
                                      //NSString *resultText = result.text; //Used to get text directly
                                      //NSLog(@"%@",resultText);
                                      
                                      for (MLKTextBlock *block in result.blocks) {
                                          
                                          //Block Text
                                          [blocktext addObject:block.text];
                                          
                                          //Block Corner Points
                                          NSString *x1 = [NSString stringWithFormat:@"%f",block.cornerPoints[0].CGPointValue.x];
                                          NSString *y1 = [NSString stringWithFormat:@"%f",block.cornerPoints[0].CGPointValue.y];
                                          
                                          NSString *x2 = [NSString stringWithFormat:@"%f",block.cornerPoints[1].CGPointValue.x];
                                          NSString *y2 = [NSString stringWithFormat:@"%f",block.cornerPoints[1].CGPointValue.y];
                                          
                                          NSString *x3 = [NSString stringWithFormat:@"%f",block.cornerPoints[2].CGPointValue.x];
                                          NSString *y3 = [NSString stringWithFormat:@"%f",block.cornerPoints[2].CGPointValue.y];
                                          
                                          NSString *x4 = [NSString stringWithFormat:@"%f",block.cornerPoints[3].CGPointValue.x];
                                          NSString *y4 = [NSString stringWithFormat:@"%f",block.cornerPoints[3].CGPointValue.y];
                                          
                                          NSDictionary* bpoobj = @{
                                                                   @"x1": x1,
                                                                   @"y1": y1,
                                                                   @"x2": x2,
                                                                   @"y2": y2,
                                                                   @"x3": x3,
                                                                   @"y3": y3,
                                                                   @"x4": x4,
                                                                   @"y4": y4,
                                                                   };
                                          [blockpoints addObject:bpoobj];
                                          
                                          //Block Frame
                                          CGFloat xfloat =  block.frame.origin.x;
                                          CGFloat yfloat =  block.frame.origin.y;
                                          CGFloat heightfloat =  block.frame.size.height;
                                          CGFloat widthfloat =  block.frame.size.width;
                                          
                                          NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                                          NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                                          NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                                          NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                                          
                                          NSDictionary* bframeobj = @{
                                                                      @"x": x,
                                                                      @"y": y,
                                                                      @"height": height,
                                                                      @"width": width
                                                                      };
                                          [blockframe addObject:bframeobj];
                                          
                                          for (MLKTextLine *line in block.lines) {
                                              
                                              //Line Text
                                              [linetext addObject:line.text];
                                                                                            
                                              ////Line Corner Points
                                              NSString *x1 = [NSString stringWithFormat:@"%f",line.cornerPoints[0].CGPointValue.x];
                                              NSString *y1 = [NSString stringWithFormat:@"%f",line.cornerPoints[0].CGPointValue.y];
                                              
                                              NSString *x2 = [NSString stringWithFormat:@"%f",line.cornerPoints[1].CGPointValue.x];
                                              NSString *y2 = [NSString stringWithFormat:@"%f",line.cornerPoints[1].CGPointValue.y];
                                              
                                              NSString *x3 = [NSString stringWithFormat:@"%f",line.cornerPoints[2].CGPointValue.x];
                                              NSString *y3 = [NSString stringWithFormat:@"%f",line.cornerPoints[2].CGPointValue.y];
                                              
                                              NSString *x4 = [NSString stringWithFormat:@"%f",line.cornerPoints[3].CGPointValue.x];
                                              NSString *y4 = [NSString stringWithFormat:@"%f",line.cornerPoints[3].CGPointValue.y];
                                              
                                              NSDictionary* lpoobj = @{
                                                                       @"x1": x1,
                                                                       @"y1": y1,
                                                                       @"x2": x2,
                                                                       @"y2": y2,
                                                                       @"x3": x3,
                                                                       @"y3": y3,
                                                                       @"x4": x4,
                                                                       @"y4": y4,
                                                                       };
                                              [linepoints addObject:lpoobj];
                                              
                                              //Line Frame
                                              CGFloat xfloat =  line.frame.origin.x;
                                              CGFloat yfloat =  line.frame.origin.y;
                                              CGFloat heightfloat =  line.frame.size.height;
                                              CGFloat widthfloat =  line.frame.size.width;
                                              
                                              NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                                              NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                                              NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                                              NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                                              
                                              NSDictionary* lframeobj = @{
                                                                          @"x": x,
                                                                          @"y": y,
                                                                          @"height": height,
                                                                          @"width": width
                                                                          };
                                              [lineframe addObject:lframeobj];
                                              
                                              for (MLKTextElement *element in line.elements) {
                                                  
                                                  //Word Text
                                                  [wordtext addObject:element.text];
                                                  
                                                  //Word Corner Points
                                                  NSString *x1 = [NSString stringWithFormat:@"%f",element.cornerPoints[0].CGPointValue.x];
                                                  NSString *y1 = [NSString stringWithFormat:@"%f",element.cornerPoints[0].CGPointValue.y];
                                                  
                                                  NSString *x2 = [NSString stringWithFormat:@"%f",element.cornerPoints[1].CGPointValue.x];
                                                  NSString *y2 = [NSString stringWithFormat:@"%f",element.cornerPoints[1].CGPointValue.y];
                                                  
                                                  NSString *x3 = [NSString stringWithFormat:@"%f",element.cornerPoints[2].CGPointValue.x];
                                                  NSString *y3 = [NSString stringWithFormat:@"%f",element.cornerPoints[2].CGPointValue.y];
                                                  
                                                  NSString *x4 = [NSString stringWithFormat:@"%f",element.cornerPoints[3].CGPointValue.x];
                                                  NSString *y4 = [NSString stringWithFormat:@"%f",element.cornerPoints[3].CGPointValue.y];
                                                  
                                                  NSDictionary* wpoobj = @{
                                                                           @"x1": x1,
                                                                           @"y1": y1,
                                                                           @"x2": x2,
                                                                           @"y2": y2,
                                                                           @"x3": x3,
                                                                           @"y3": y3,
                                                                           @"x4": x4,
                                                                           @"y4": y4,
                                                                           };
                                                  [wordpoints addObject:wpoobj];
                                                  
                                                  //Word Frame
                                                  CGFloat xfloat =  element.frame.origin.x;
                                                  CGFloat yfloat =  element.frame.origin.y;
                                                  CGFloat heightfloat =  element.frame.size.height;
                                                  CGFloat widthfloat =  element.frame.size.width;
                                                  
                                                  NSString *x = [NSString stringWithFormat:@"%f",xfloat];
                                                  NSString *y = [NSString stringWithFormat:@"%f",yfloat];
                                                  NSString *height = [NSString stringWithFormat:@"%f",heightfloat];
                                                  NSString *width = [NSString stringWithFormat:@"%f",widthfloat];
                                                  
                                                  NSDictionary* wframeobj = @{
                                                                              @"x": x,
                                                                              @"y": y,
                                                                              @"height": height,
                                                                              @"width": width
                                                                              };
                                                  [wordframe addObject:wframeobj];
                                              }
                                          }
                                      }
                                      
                                      
                                      blockobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                                   blocktext,@"blocktext",
                                                   blockpoints,@"blockpoints",
                                                   blockframe,@"blockframe", nil] mutableCopy];
                                      
                                      NSDictionary *bobj = [NSDictionary dictionaryWithDictionary:blockobj];
                                      
                                      
                                      lineobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                                  linetext,@"linetext",
                                                  linepoints,@"linepoints",
                                                  lineframe,@"lineframe", nil] mutableCopy];
                                      NSDictionary *lobj = [NSDictionary dictionaryWithDictionary:lineobj];
                                      
                                      
                                      wordobj = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                                  wordtext,@"wordtext",
                                                  wordpoints,@"wordpoints",
                                                  wordframe,@"wordframe", nil] mutableCopy];
                                      NSDictionary *wobj = [NSDictionary dictionaryWithDictionary:wordobj];
                                      
                                      
                                      resultobjmut = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                                       bobj,@"blocks",
                                                       lobj,@"lines",
                                                       wobj,@"words", nil] mutableCopy];
                                      NSDictionary *resultobj = [NSDictionary dictionaryWithDictionary:resultobjmut];
                                      
                                      CDVPluginResult* resultcor = [CDVPluginResult
                                                                    resultWithStatus:CDVCommandStatus_OK
                                                                    messageAsDictionary:resultobj];
                    [self.commandDelegate sendPluginResult:resultcor callbackId: self.commandglo.callbackId];
                                  }];
            }
            else
            {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:@"Error in uri or base64 data!"];
                [self.commandDelegate sendPluginResult:result callbackId: self.commandglo.callbackId];
            }
        }
        @catch (NSException *exception)
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Main loop Exception"];
            [self.commandDelegate sendPluginResult:result callbackId: self.commandglo.callbackId];
        }
    }];
}


-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600;
    float maxWidth = 600;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.50;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:imageData];
    
}

-(NSData *)retrieveAssetDataPhotosFramework:(NSURL *)urlMedia
{
    __block NSData *iData = nil;
    
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[urlMedia] options:nil];
    PHAsset *asset = [result firstObject];
    if (asset != nil)
    {
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        
        @autoreleasepool {
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                iData = [imageData copy];
            }];
        }
        //assert(iData.length != 0);
        return iData;
    }
    else
    {
        return NULL;
    }
    
}

@end


