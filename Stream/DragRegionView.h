//
//  DragRegionView.h
//  Stream
//
//  Created by tim lindner on 8/2/11.
//  Copyright 2011 org.macmess. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AnaylizerListViewItem;

@interface DragRegionView : NSView
{
//    BOOL ignoreEvent;
    float rowHeight;
    IBOutlet NSView *customView;
    NSView *retainView;
    
}

@property (assign) IBOutlet AnaylizerListViewItem *viewOwner;
@property (assign) BOOL doingLiveResize;

- (void)setCustomSubView:(NSView *)view paneExpanded:(BOOL)paneExpanded;

@end
