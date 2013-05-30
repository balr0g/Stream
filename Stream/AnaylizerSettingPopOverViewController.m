//
//  AnaylizerSettingPopOverViewController.m
//  Stream
//
//  Created by tim lindner on 8/13/11.
//  Copyright 2011 org.macmess. All rights reserved.
//

#import "AnaylizerSettingPopOverViewController.h"
#import "AnaylizerListViewItem.h"
#import "Analyzation.h"
#import "AnaylizerSettingPopOverAccessoryViewController.h"

@implementation AnaylizerSettingPopOverViewController

@synthesize popover;
@synthesize accessoryView;
@synthesize avc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)showPopover:(NSView *)aView
{
    [popover showRelativeToRect:[aView bounds] ofView:aView preferredEdge:NSMaxYEdge];
}

- (void)popoverWillClose:(NSNotification *)notification
{
    AnaylizerListViewItem *ro = self.representedObject;
    [ro popoverWillClose:notification];
}

- (IBAction)sourceUTIAction:(id)sender
{
#pragma unused (sender)
    AnaylizerListViewItem *ro = self.representedObject;
    [ro observeValueForKeyPath:@"sourceUTI" ofObject:[ro representedObject] change:nil context:ro];
}

- (void)setAccessoryView
{
    AnaylizerListViewItem *ro = self.representedObject;
    StData *data = (StData *)ro.selectedBlock;
    
    /* are we a blocker anaylizer? */
    if (data == nil) {
        /* nope, we are a filter anaylizer */
        data = ro.representedObject;
    }
    
    /* remove previous accesswory view */
    if (self.avc != nil) {
        NSArray *subViews = [self.accessoryView subviews];
        if ([subViews count] > 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }

        self.avc = nil;
    }
    
    /* get class object for current editor view (of current filter anaylizer, or current block) */
    Class anaClass = [[Analyzation sharedInstance] anaylizerClassforName:data.currentEditorView];
    NSString *nibName = [anaClass AnaylizerPopoverAccessoryViewNib];
    
    NSRect accessoryFrame = [accessoryView frame];
    CGFloat currentAVHeight = accessoryFrame.size.height;
    CGFloat newSubViewHeight;
    
    if( nibName != nil && ![nibName isEqualToString:@""] ) {
        self.avc = [[[AnaylizerSettingPopOverAccessoryViewController alloc] initWithNibName:nibName bundle:nil] autorelease];
        [self.avc setRepresentedObject:data];
        [self.avc loadView];
        
        newSubViewHeight = [[self.avc view] frame].size.height;
        accessoryFrame.size = [[self.avc view] frame].size;
        [accessoryView setFrame:accessoryFrame];
        [accessoryView addSubview:[self.avc view]];
    }
    else {
        accessoryFrame.size.height = 0;
        [accessoryView setFrame:accessoryFrame];
        newSubViewHeight = 0;
    }

    NSSize contentsize = [popover contentSize];
    contentsize.height += newSubViewHeight - currentAVHeight;
    [popover setContentSize:contentsize];
}

- (void)dealloc
{
    if (self.avc != nil) {
        NSArray *subViews = [self.accessoryView subviews];
        if ([subViews count] > 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        self.avc = nil;
    }
    
    [super dealloc];
}

@end
