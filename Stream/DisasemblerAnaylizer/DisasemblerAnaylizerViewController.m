//
//  DisasemblerAnaylizerViewController.m
//  Stream
//
//  Created by tim lindner on 4/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DisasemblerAnaylizerViewController.h"
#import "DisasemblerAnaylizer.h"
#import "StAnaylizer.h"
#import "StBlock.h"
#import "StStream.h"

@interface DisasemblerAnaylizerViewController ()

@end

@implementation DisasemblerAnaylizerViewController

@synthesize textView;
@synthesize lastAnaylizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) setRepresentedObject:(id)inRepresentedObject
{
    super.representedObject = inRepresentedObject;

    if( [inRepresentedObject respondsToSelector:@selector(addSubOptionsDictionary:withDictionary:)] )
    {
        [inRepresentedObject addSubOptionsDictionary:[DisasemblerAnaylizer anaylizerKey] withDictionary:[DisasemblerAnaylizer defaultOptions]];
    }
}

- (void) loadView
{
    [super loadView];
    [self reloadView];
}

- (void)reloadView
{
//    [self stopObserving];

    id ro = [self representedObject];

    [textView setUsesFontPanel:YES];
    [textView setRichText:NO];
    [textView setEditable:![[[self representedObject] valueForKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.readOnly"] boolValue]];
    [textView setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
    
    NSData *bytes;
    if( [ro isKindOfClass:[StAnaylizer class]] )
    {
        bytes = [[ro parentStream] valueForKey:@"bytesCache"];
    }
    else if( [ro isKindOfClass:[StBlock class]] )
    {
        bytes = [ro getData];
    }
    else if( [ro isKindOfClass:[NSData class]] )
    {
        bytes = ro;
    }
    else {
        [textView setString:@"No data supplied"];
        return;
    }
    
    DisasemblerAnaylizer *modelObject = (DisasemblerAnaylizer *)[ro anaylizerObject];
    [textView setString:[modelObject disasemble6809:bytes]];
    [self startObserving];
 }

- (void)startObserving
{
    if (observationsActive) {
        [self stopObserving];
    }
    
    self.lastAnaylizer = [self representedObject];
    
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.directPageValue" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.transferAddresses" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.offsetAddress" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.support6309" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showAddresses" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showOS9" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showHex" options:NSKeyValueChangeSetting context:self];
    [self.lastAnaylizer addObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.followPC" options:NSKeyValueChangeSetting context:self];
    
    observationsActive = YES;
}

- (void)stopObserving
{
    if (observationsActive) {
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.directPageValue" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.transferAddresses" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.offsetAddress" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.support6309" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showAddresses" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showOS9" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.showHex" context:self];
        [self.lastAnaylizer removeObserver:self forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.followPC" context:self];
        self.lastAnaylizer = nil;
        observationsActive = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == self) {
        if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.transferAddresses"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.offsetAddress"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.support6309"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.showAddresses"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.showOS9"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.showHex"]) {
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.followPC"]) {
            BOOL followPC = [[self.lastAnaylizer valueForKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.followPC"] boolValue];
            [self.lastAnaylizer setValue:[NSNumber numberWithBool:followPC ] forKeyPath:@"optionsDictionary.DisasemblerAnaylizerViewController.transferAddressEnable"];
            [self reloadView];
        } else if ([keyPath isEqualToString:@"optionsDictionary.DisasemblerAnaylizerViewController.directPageValue"]) {
            [self reloadView];
        } else {
            NSLog( @"DisasemblerAnaylizerViewController: Unknown keypath for observerValueForKeyPath:ofObject:change:context: %@", keyPath );
        }    
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [self stopObserving];
    self.lastAnaylizer = nil;
    
    [super dealloc];
}

- (NSString *)nibName
{
    return @"DisasemblerAnaylizerViewController";
}

@end
