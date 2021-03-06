//
//  SectionElement.m
//  ALTableViewFramework
//
//  Created by lorenzo villarroel perez on 6/11/15.
//
//

#import "SectionElement.h"
#import "ALTableViewConstants.h"
#import "RowElement.h"

@interface SectionElement ()

@property (strong, nonatomic) NSString * sectionTitleIndex;

@property (strong, nonatomic) UIView *viewHeader;
@property (strong, nonatomic) UIView *viewFooter;

@property (strong, nonatomic) NSNumber *heightHeader;
@property (strong, nonatomic) NSNumber *heightFooter;

@property (assign, nonatomic) BOOL isOpened;
@property (assign, nonatomic) BOOL isExpandable;
@property (strong, nonatomic) UITapGestureRecognizer *headerTapGesture;

@property (strong, nonatomic) NSMutableArray<__kindof RowElement *> * cellObjects;

@end

@implementation SectionElement

#pragma mark - Constructor

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)sectionElementWithParams:(NSDictionary *) dic {
    return [[self alloc] initWithParams:dic];
}

- (instancetype)initWithParams:(NSDictionary *) dic {
    self = [super init];
    if (self) {
        self.sectionTitleIndex = dic[PARAM_SECTIONELEMENT_SECTION_TITLE_INDEX];
        self.viewHeader = dic[PARAM_SECTIONELEMENT_VIEW_HEADER];
        self.viewFooter = dic[PARAM_SECTIONELEMENT_VIEW_FOOTER];
        self.heightHeader = dic[PARAM_SECTIONELEMENT_HEIGHT_HEADER];
        self.heightFooter = dic[PARAM_SECTIONELEMENT_HEIGHT_FOOTER];
        self.cellObjects = dic[PARAM_SECTIONELEMENT_CELL_OBJECTS];
        self.isExpandable = [dic[PARAM_SECTIONELEMENT_IS_EXPANDABLE] boolValue];

        NSMutableArray * sourceData = dic[PARAM_SECTIONELEMENT_SOUCE_DATA];
        Class classForRow = dic[PARAM_SECTIONELEMENT_CLASS_FOR_ROW];
        if (!self.cellObjects && sourceData && classForRow) {
            [self commonSourceData:sourceData classForRow:classForRow];
        }
        
        [self commonInit];
    }
    return self;
}

+ (instancetype)sectionElementWithSectionTitleIndex:(NSString *) titleIndex viewHeader:(UIView *) viewHeader viewFooter:(UIView *) viewFooter heightHeader:(NSNumber *) heightHeader heightFooter:(NSNumber *) heightFooter cellObjects:(NSMutableArray *) cellObjects isExpandable: (BOOL) isExpandable {
    return [[self alloc] initWithSectionTitleIndex:titleIndex viewHeader:viewHeader viewFooter:viewFooter heightHeader:heightHeader heightFooter:heightFooter cellObjects:cellObjects isExpandable:isExpandable];
}

- (instancetype)initWithSectionTitleIndex:(NSString *) titleIndex viewHeader:(UIView *) viewHeader viewFooter:(UIView *) viewFooter heightHeader:(NSNumber *) heightHeader heightFooter:(NSNumber *) heightFooter cellObjects:(NSMutableArray *) cellObjects isExpandable: (BOOL) isExpandable {
    self = [super init];
    if (self) {
        self.sectionTitleIndex = titleIndex;
        self.viewHeader = viewHeader;
        self.viewFooter = viewFooter;
        self.heightHeader = heightHeader;
        self.heightFooter = heightFooter;
        self.cellObjects = cellObjects;
        self.isExpandable = isExpandable;
        [self commonInit];
    }
    return self;
}

+ (instancetype)sectionElementWithSectionTitleIndex:(NSString *) titleIndex viewHeader:(UIView *) viewHeader viewFooter:(UIView *) viewFooter heightHeader:(NSNumber *) heightHeader heightFooter:(NSNumber *) heightFooter sourceData:(NSMutableArray *) sourceData classForRow:(Class) className isExpandable: (BOOL) isExpandable {
    return [[self alloc] initWithSectionTitleIndex:titleIndex viewHeader:viewHeader viewFooter:viewFooter heightHeader:heightHeader heightFooter:heightFooter sourceData:sourceData classForRow:className isExpandable:isExpandable];
}

- (instancetype)initWithSectionTitleIndex:(NSString *) titleIndex viewHeader:(UIView *) viewHeader viewFooter:(UIView *) viewFooter heightHeader:(NSNumber *) heightHeader heightFooter:(NSNumber *) heightFooter sourceData:(NSMutableArray *) sourceData classForRow:(Class) className isExpandable: (BOOL) isExpandable {
    self = [super init];
    if (self) {
        self.sectionTitleIndex = titleIndex;
        self.viewHeader = viewHeader;
        self.viewFooter = viewFooter;
        self.heightHeader = heightHeader;
        self.heightFooter = heightFooter;
        
        [self commonSourceData:sourceData classForRow:className];
        self.isExpandable = isExpandable;
        [self commonInit];
    }
    return self;
}

-(void) commonSourceData:(NSMutableArray *) sourceData classForRow:(Class) className  {
    NSMutableArray * rows = [NSMutableArray array];
    for (NSObject * object in sourceData) {
        NSNumber * height = @40;
        RowElement * rowElement = [RowElement rowElementWithClassName:className object:object heightCell:height cellIdentifier:nil];
        rowElement.estimateHeightMode = YES;
        [rows addObject:rowElement];
    }
    
    self.cellObjects = [[NSMutableArray alloc] initWithArray:rows];
}

-(void) commonInit {
    self.isOpened = YES;
    [self checkClassAttributes];
    [self setUpHeaderRecognizer];
}


#pragma mark - Private Methods

-(void) checkClassAttributes {
    if (!self.sectionTitleIndex) {
        self.sectionTitleIndex = @"";
    }
    if (!self.heightHeader) {
        if (self.viewHeader) {
            self.heightHeader = [NSNumber numberWithDouble:self.viewHeader.frame.size.height];
        } else {
            self.heightHeader = [NSNumber numberWithInt:0];
        }
    }
    if (!self.heightFooter) {
        if (self.viewFooter) {
            self.heightFooter = [NSNumber numberWithDouble:self.viewFooter.frame.size.height];
        } else {
            self.heightFooter = [NSNumber numberWithInt:0];
        }
    }
    if (!self.viewHeader) {
        self.viewHeader = [UIView new];
    }
    if (!self.viewFooter) {
        self.viewFooter = [UIView new];
    }
    
    if (!self.cellObjects) {
        self.cellObjects = [NSMutableArray array];
    }
    
    if (!self.isExpandable) {
        self.isExpandable = NO;
    }
}


#pragma mark - Getters

-(UIView *) getHeader {
    return self.viewHeader;
}

-(UIView *) getFooter {
    return self.viewFooter;
}

-(CGFloat) getHeaderHeight {
    return self.heightHeader.floatValue;
}

-(CGFloat) getFooterHeight {
    return self.heightFooter.floatValue;
}

-(NSInteger) getNumberOfRows {
    if (self.isOpened) {
        return [self.cellObjects count];
    } else {
        return 0;
    }
}

-(NSInteger) getNumberOfRealRows {
    return [self.cellObjects count];
}

-(NSInteger) getTotalNumberOfRows {
    return [self.cellObjects count];
}

-(RowElement *) getRowAtPosition:(NSInteger) position {
    if (position > self.cellObjects.count || position < 0) {
        NSLog(@"%@Attempting to get a Row from a position that exceeds the limit of the elements array", warningString);
        return nil;
    }
    return self.cellObjects[position];
}

-(CGFloat) getRowHeightAtPosition:(NSInteger) position {
    if (position > self.cellObjects.count || position < 0) {
        NSLog(@"%@Attempting to get a Row from a position that exceeds the limit of the elements array", warningString);
        return -1;
    }
    return [self.cellObjects[position] getHeightCell];
}

-(NSString *) getSectionTitleIndex {
    return self.sectionTitleIndex;
}



#pragma mark - Managing the insertion of new cells

-(void) insertRowElement: (RowElement *) rowElement AtIndex: (NSInteger)index {
    [self.cellObjects insertObject:rowElement atIndex:index];
}

-(void) insertRowElements: (NSMutableArray *) rowElements AtIndex: (NSInteger)index {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(index,rowElements.count)];
    [self.cellObjects insertObjects:rowElements atIndexes:indexes];
}

#pragma mark - Managing the deletion of new cells

-(void) deleteRowElementAtIndex: (NSInteger)index {
    [self.cellObjects removeObjectAtIndex:index];
}

-(void) deleteRowElements: (NSInteger) numberOfRowElements AtIndex: (NSInteger)index {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(index,numberOfRowElements)];
    [self.cellObjects removeObjectsAtIndexes:indexes];
}

#pragma mark - Managing the replacement of new cells

-(void) replaceRowElementAtIndex: (NSInteger) index WithRowElement: (RowElement *) rowElement {
    [self.cellObjects replaceObjectAtIndex:index withObject:rowElement];
}

#pragma mark - Managing the opening and close of section

-(void) setUpHeaderRecognizer {
    //    NSLog(@"setUpHeaderRecognizer");
    [self.viewHeader setUserInteractionEnabled:YES];
    self.headerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
    [self.viewHeader addGestureRecognizer:self.headerTapGesture];
}

- (IBAction)toggleOpen:(id)sender {
    //    NSLog(@"toggleOpen");
    if (self.isExpandable) {
        [self toggleOpenWithUserAction:YES];
    }
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    if (self.delegate) {
        self.isOpened = !self.isOpened;
        
        // if this was a user action, send the delegate the appropriate message
        if (userAction) {
            if (self.isOpened) {
                if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                    [self.delegate sectionHeaderView:self sectionOpened:0];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                    [self.delegate sectionHeaderView:self sectionClosed:0];
                }
            }
        }
    }
    // toggle the disclosure button state
    
}

@end
