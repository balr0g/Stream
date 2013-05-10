#import <Cocoa/Cocoa.h>
#import "AnaylizerSettingPopOverAccessoryViewController.h"

#import "StAnaylizer.h"

@class AnaylizerListViewItem;

@interface ColorGradientView : NSView
{
    NSColor *startingColor;
    NSColor *endingColor;
    int angle;
    NSMutableArray *additionalConstraints;
    IBOutlet NSButton *tlDisclosure;
    IBOutlet NSButton *tlTitle;
    IBOutlet NSButton *tlAction;
    
    NSNib *actionPopOverNib;
    IBOutlet NSPopUpButton *editorPopup;
    IBOutlet NSComboBox *utiComboBox;
    IBOutlet NSTextField *acceptsTextField;
    IBOutlet NSPopover *actionPopOver;
    IBOutlet NSView *accessoryView;
    NSArrayController *popupArrayController;
    NSTextField *labelUTI;
    NSTextField *labelEditor;

    id observableEditorView;
    id observableSourceUTI;
}

@property (assign) IBOutlet NSButton *tlTitle;
@property (assign) IBOutlet NSTextField *labelUTI;
@property (assign) IBOutlet NSTextField *labelEditor;
@property (assign) IBOutlet NSTextField *acceptsTextField;
@property (assign) IBOutlet AnaylizerListViewItem *viewOwner;

// Define the variables as properties
@property(nonatomic, retain) NSMutableArray *additionalConstraints;
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(nonatomic, retain) NSNib *actionPopOverNib;
@property(nonatomic, retain) NSArrayController *popupArrayController;
@property(nonatomic, retain) AnaylizerSettingPopOverAccessoryViewController *avc;
@property(nonatomic, assign) NSTreeController *blockTreeController;
@property(assign) BOOL boundAndObserved;
@property(assign) int angle;

- (IBAction)doPopOver:(id)sender;
- (IBAction)popOverOK:(id)sender;
- (IBAction)popOverCancel:(id)sender;
- (void)unbindAndUnobserve;
@end