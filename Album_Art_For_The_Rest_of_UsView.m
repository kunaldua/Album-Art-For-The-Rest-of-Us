//
//  Album_Art_For_The_Rest_of_UsView.m
//  Album Art For The Rest of Us
//
//  Created by Kunal Dua on 25/9/06.
//  Copyright (c) 2006, Kunal Dua. All rights reserved.
//

#import "Album_Art_For_The_Rest_of_UsView.h"
#define runScriptName @"getArtWork"
#define runScriptType @"scpt"
#define maxWidth 300
#define maxHeight 300


@implementation Album_Art_For_The_Rest_of_UsView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:2];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
	NSAppleScript *getArtScript;
	NSAppleEventDescriptor *descriptor;
	NSString *pictureFormat;
	NSData *pictureData, *pictureDataWithoutHeader;
	NSRange pictureRange;
	int picture_length;
	NSImage *pictureImage;
	NSDictionary *errorInfo;

	NSString *scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource: runScriptName ofType: runScriptType];
	NSURL *scriptURL = [NSURL fileURLWithPath: scriptPath];
	
	getArtScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
	
	descriptor = [getArtScript executeAndReturnError:&errorInfo];
	
	if (descriptor==nil) {
		NSLog(@"%s",[errorInfo description]);
		return;
	}

	pictureFormat = [[descriptor descriptorAtIndex:6] stringValue];
	pictureData = [[descriptor descriptorAtIndex:5] data];
	picture_length = [pictureData length];
	
	pictureRange = NSMakeRange(222, (picture_length-222));
	pictureDataWithoutHeader = [pictureData subdataWithRange:pictureRange];
	
	pictureImage = [[[NSImage alloc] initWithData:pictureDataWithoutHeader] autorelease];
	
	if ((pictureImage != 0) && [pictureImage isValid])
	{
		NSSize imageSize = [pictureImage size];
		
		if (imageSize.width > maxWidth || imageSize.height > maxHeight) {
			[pictureImage setScalesWhenResized: YES];
			
			float aspectRatio;
			aspectRatio = imageSize.width / imageSize.height;
			
			if (aspectRatio >= 1) {
				imageSize.width = maxWidth;
				imageSize.height = maxWidth/ aspectRatio;
			}
			else
			{
				imageSize.height = maxHeight;
				imageSize.width = aspectRatio * maxHeight;
			}
			
			[pictureImage setSize:imageSize];
		}
		
		
		NSPoint randomPoint;
		
		randomPoint.x = SSRandomIntBetween( (int) (0 - (imageSize.width * 2/3)), (int) ( [self bounds].size.width) - (imageSize.width * 2/3));
		randomPoint.y = SSRandomIntBetween( (int) (0 - (imageSize.height * 2/3)), (int) ( [self bounds].size.height) - (imageSize.height * 2/3));
		

		[pictureImage compositeToPoint:randomPoint operation:NSCompositeSourceAtop fraction:0.5]; 
	}	
	
	
	[getArtScript release];
	
	
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
