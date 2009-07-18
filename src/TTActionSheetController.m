#import "Three20/TTActionSheetController.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTActionSheet : UIActionSheet {
  UIViewController* _popupViewController;
}

@property(nonatomic,retain) UIViewController* popupViewController;

@end

@implementation TTActionSheet

@synthesize popupViewController = _popupViewController;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _popupViewController = nil;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [_popupViewController autorelease];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActionSheetController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title delegate:(id)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _URLs = [[NSMutableArray alloc] init];
    
    self.actionSheet.title = title;
  }
  return self;
}

- (id)initWithTitle:(NSString*)title {
  return [self initWithTitle:title delegate:nil];
}

- (id)init {
  return [self initWithTitle:nil delegate:nil];
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_URLs);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  TTActionSheet* actionSheet = [[[TTActionSheet alloc] initWithTitle:nil delegate:self
                                                       cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                       otherButtonTitles:nil] autorelease];
  actionSheet.popupViewController = self;
  self.view = actionSheet;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInViewController:(UIViewController*)parentViewController animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.actionSheet showInView:parentViewController.view];
  [self viewDidAppear:animated];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex
                    animated:animated];
  [self viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  [_delegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

- (void)actionSheetCancel:(UIActionSheet*)actionSheet {
  [_delegate actionSheetCancel:actionSheet];
}

- (void)willPresentActionSheet:(UIActionSheet*)actionSheet {
  [_delegate willPresentActionSheet:actionSheet];
}

- (void)didPresentActionSheet:(UIActionSheet*)actionSheet {
  [_delegate didPresentActionSheet:actionSheet];
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
  [_delegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  if (URL) {
    TTOpenURL(URL);
  }
  [_delegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIActionSheet*)actionSheet {
  return (UIActionSheet*)self.view;
}

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  if (URL) {
    [_URLs addObject:URL];
  } else {
    [_URLs addObject:[NSNull null]];
  }
  return [self.actionSheet addButtonWithTitle:title];
}

- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.cancelButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.cancelButtonIndex;
}

- (NSInteger)addDestructiveButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.destructiveButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.destructiveButtonIndex;
}

- (NSString*)buttonURLAtIndex:(NSInteger)index {
  id URL = [_URLs objectAtIndex:index];
  return URL != [NSNull null] ? URL : nil;
}

@end
