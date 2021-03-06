//
//  ALTableViewController.m
//  ALTableViewFramework
//
//  Created by Abimael Barea Puyana on 6/11/15.
//
//

#import "ALTableViewController.h"
#import "ALTableViewConstants.h"
#import "SectionManager.h"

@interface ALTableViewController ()

@property(strong, nonatomic) SectionManager *sectionManager;
@property(assign, nonatomic) CGRect frame;

@end

@implementation ALTableViewController


#pragma mark - Constructor

-(void) commonInitWithSections:(NSArray<__kindof SectionElement *> *) sections {
    self.sectionManager = [SectionManager sectionManagerWithSections:sections];
    self.sectionManager.delegate = self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self commonInitWithSections:nil];
    }
    return self;
}

+ (instancetype)tableViewControllerWithFrame:(CGRect)frame style:(UITableViewStyle)style backgroundView: (UIView*) backgroundView backgroundColor: (UIColor*) backgroundColor sections:(NSArray*)sections {
    return [[self alloc] initWithFrame:frame style:style backgroundView:backgroundView backgroundColor:backgroundColor sections:sections];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style backgroundView: (UIView*) backgroundView backgroundColor: (UIColor*) backgroundColor sections:(NSArray*)sections {
    self = [super initWithStyle:style];
    if (self) {
        self.frame = frame;
        [self commonInitWithSections:sections];
        
        self.tableView.backgroundView = backgroundView;
        self.tableView.backgroundColor = backgroundColor;
    }
    return self;
}

+ (instancetype)tableViewControllerWithParams:(NSMutableDictionary *) dic {
    return [[self alloc] initWithParams:dic];
}

- (instancetype)initWithParams:(NSMutableDictionary *) dic {
    self = [super initWithStyle:[dic[PARAM_ALTABLEVIEWCONTROLLER_STYLE] integerValue]];
    if (self) {
        self.frame = CGRectFromString(dic[PARAM_ALTABLEVIEWCONTROLLER_FRAME]);
        [self commonInitWithSections:dic[PARAM_ALTABLEVIEWCONTROLLER_SECTIONS]];

        self.tableView.backgroundView = dic[PARAM_ALTABLEVIEWCONTROLLER_BACKGROUND_VIEW];
        self.tableView.backgroundColor = dic[PARAM_ALTABLEVIEWCONTROLLER_BACKGROUND_COLOR];
        
        self.modeSectionsExpandable = dic[PARAM_ALTABLEVIEWCONTROLLER_MODE_SECTIONS_EXPANABLE];
        self.modeSectionsIndexTitles = dic[PARAM_ALTABLEVIEWCONTROLLER_MODE_SECTIONS_INDEX_TITLE];
        
        [self checkClassAttributes];
    }
    return self;
}

-(void) awakeFromNib {
    [self commonInitWithSections:nil];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = self.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

-(void) checkClassAttributes {
    // TODO: Check properties
}

-(BOOL) checkParametersSection: (NSInteger) section {
    if (!(section < [self.sectionManager getNumberOfSections])) {
        NSLog(@"Attempting to access a row in a non-existing section");
        return NO;
    }
    return YES;
}

-(BOOL) checkParametersSection: (NSInteger) section Row: (NSInteger) row {
    if (!(section < [self.sectionManager getNumberOfSections])) {
        NSLog(@"Attempting to access a row in a non-existing section");
        return NO;
    }
    
    if (!(row < [self.sectionManager getNumberOfRows:section])) {
        NSLog(@"Attempting to access a row from a non-existing row");
        return NO;
    }
    return YES;
}

- (void)setModeMoveCells:(BOOL) move {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
}


#pragma mark - Public methods

#pragma mark class register

-(void) registerClass: (Class) classToRegister CellIdentifier: (NSString *) cellIdentifier {
    [self.tableView registerClass:classToRegister forCellReuseIdentifier:cellIdentifier];
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}


#pragma mark Managing the replacement of new cells

-(BOOL) replaceRowElementAtIndexPath: (NSIndexPath *) indexPath WithRowElement: (RowElement *) rowElement{
    return [self replaceRowElementAtSection:indexPath.section Row:indexPath.row WithRowElement:rowElement];
}

-(BOOL) replaceRowElementAtSection: (NSInteger) section Row: (NSInteger) row WithRowElement: (RowElement *) rowElement{
    if (![self checkParametersSection:section Row:row]) {
        return NO;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithObject:indexPath];
    [self.sectionManager replaceRowElementAtSection:section Row:row WithRowElement:rowElement];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    return YES;
}


#pragma mark Managing the exchange of new cells

-(BOOL) exchangeRowElementAtIndexPath:(NSIndexPath *) indexPathFirst WithRowElementAtIndexPath:(NSIndexPath *) indexPathSecond {
    if (![self checkParametersSection:indexPathFirst.section Row:indexPathFirst.row]) {
        return NO;
    }
    if (![self checkParametersSection:indexPathSecond.section Row:indexPathSecond.row]) {
        return NO;
    }
    
    // Retrive rowElements
    RowElement * rowElementFirst = [self.sectionManager getRowElementAtIndexPath:indexPathFirst];
    RowElement * rowElementSecond = [self.sectionManager getRowElementAtIndexPath:indexPathSecond];
    
    // Exchange betwenn sections
    if (indexPathFirst.section != indexPathSecond.section) {
        [self replaceRowElementAtIndexPath:indexPathSecond WithRowElement:rowElementFirst];
        [self replaceRowElementAtIndexPath:indexPathFirst  WithRowElement:rowElementSecond];
        return YES;
    }
    
    // Exchange in current section
    [self.sectionManager replaceRowElementAtSection:indexPathFirst.section Row:indexPathFirst.row WithRowElement:rowElementFirst];
    [self.sectionManager replaceRowElementAtSection:indexPathSecond.section Row:indexPathSecond.row WithRowElement:rowElementSecond];
    
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:indexPathFirst toIndexPath:indexPathSecond];
    [self.tableView endUpdates];
    
    return YES;
}


#pragma mark Managing the insertion of new cells

-(BOOL) insertRowElement:(RowElement *) rowElement AtTheEndOfSection: (NSInteger) section {
    return [self insertRowElement:rowElement AtSection:section Row:[self.sectionManager getNumberOfRows:section]];
}

-(BOOL) insertRowElements:(NSMutableArray *) rowElements AtTheEndOfSection: (NSInteger) section {
    return [self insertRowElements:rowElements AtSection:section Row:[self.sectionManager getNumberOfRows:section]];
}

-(BOOL) insertRowElement:(RowElement *) rowElement AtTheBeginingOfSection: (NSInteger) section {
    return [self insertRowElement:rowElement AtSection:section Row:0];
}

-(BOOL) insertRowElements:(NSMutableArray *) rowElements AtTheBeginingOfSection: (NSInteger) section {
    return [self insertRowElements:rowElements AtSection:section Row:0];
}

-(BOOL) insertRowElement:(RowElement *) rowElement AtIndexPath: (NSIndexPath *) indexPath {
    return [self insertRowElement:rowElement AtSection:indexPath.section Row:indexPath.row];
}

-(BOOL) insertRowElement:(RowElement *) rowElement AtSection: (NSInteger) section Row: (NSInteger) row {
    if (![self checkParametersSection:section Row:row-1]) {
        return NO;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithObject:indexPath];
    [self.sectionManager insertRowElement:rowElement AtSection:section Row:row];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    return YES;
}

-(BOOL) insertRowElements:(NSMutableArray *) rowElements AtIndexPath: (NSIndexPath *) indexPath {
    return [self insertRowElements:rowElements AtSection:indexPath.section Row:indexPath.row];
}

-(BOOL) insertRowElements:(NSMutableArray *) rowElements AtSection: (NSInteger) section Row: (NSInteger) row {
    if (![self checkParametersSection:section Row:row-1]) {
        return NO;
    }
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < rowElements.count ; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:(row + i) inSection:section];
        [indexPathArray addObject:index];
    }
    [self.sectionManager insertRowElements:rowElements AtSection:section Row:row];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    return YES;
}


#pragma mark Managing the deletion of cells

-(BOOL) deleteRowElementAtTheBeginingOfSection: (NSInteger) section {
    return [self deleteRowElementAtSection:section Row:0];
}

-(BOOL) deleteRowElements:(NSInteger) numberOfElements AtTheBeginingOfSection: (NSInteger) section {
    return [self deleteRowElements:numberOfElements AtSection:section Row:0];
}

-(BOOL) deleteRowElementAtTheEndOfSection: (NSInteger) section {
    return [self deleteRowElementAtSection:section Row:([self.sectionManager getNumberOfRows:section] - 1)];
}

-(BOOL) deleteRowElements:(NSInteger) numberOfElements AtTheEndOfSection: (NSInteger) section {
    return [self deleteRowElements:numberOfElements AtSection:section Row:([self.sectionManager getNumberOfRows:section] - numberOfElements)];
}

-(BOOL) deleteRowElementAtIndexPath: (NSIndexPath *) indexPath {
    return [self deleteRowElementAtSection:indexPath.section Row:indexPath.row];
}

-(BOOL) deleteRowElementAtSection: (NSInteger) section Row: (NSInteger) row {
    if (![self checkParametersSection:section Row:row]) {
        return NO;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithObject:indexPath];
    [self.sectionManager deleteRowElementAtSection:section Row:row];
    //    [self.sectionManager insertRowElement:rowElement AtSection:section Row:row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    return YES;
}

-(BOOL) deleteRowElements: (NSInteger) numberOfElements AtIndexPath: (NSIndexPath *) indexPath {
    return  [self deleteRowElements:numberOfElements AtSection:indexPath.section Row:indexPath.row];
}

-(BOOL) deleteRowElements: (NSInteger) numberOfElements AtSection: (NSInteger) section Row: (NSInteger) row {
    if (![self checkParametersSection:section Row:row]) {
        return NO;
    }
    if (numberOfElements > ([self.sectionManager getNumberOfRows:section] - row)) {
        NSLog(@"Attempting to delete more elements that there are on this section");
        return NO;
    }
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < numberOfElements ; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:(row + i) inSection:section];
        [indexPathArray addObject:index];
    }
    [self.sectionManager deleteRowElements:numberOfElements AtSection:section Row:row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    return YES;
}


#pragma mark Manage Sections

-(BOOL) insertSectionAtBegining:(SectionElement *) section {
    return [self insertSection:section AtPosition:0];
}

-(BOOL) insertSectionAtEnd:(SectionElement *) section {
    return [self insertSection:section AtPosition:[self.sectionManager getNumberOfSections]];
}

-(BOOL) insertSection:(SectionElement *) section AtIndexPath: (NSIndexPath *) indexPath {
    return [self insertSection:section AtPosition:indexPath.section];
}

-(BOOL) insertSection:(SectionElement *) section AtPosition:(NSInteger) position {
    if (![self checkParametersSection:position]) {
        return NO;
    }
    
    [self.sectionManager insertSection:section AtPosition:position];
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:position] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    return YES;
}

-(BOOL) reloadSection:(SectionElement *) section AtIndexPath: (NSIndexPath *) indexPath {
    return [self reloadSection:section AtPosition:indexPath.section];
}

-(BOOL) reloadSection:(SectionElement *) section AtPosition:(NSInteger) position {
    if (![self checkParametersSection:position]) {
        return NO;
    }
    [self.sectionManager replaceSection:section AtPosition:position];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:position] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    return YES;
}

-(BOOL) removeSectionAtIndexPath: (NSIndexPath *) indexPath {
    return [self removeSectionAtPosition:indexPath.section];
}

-(BOOL) removeSectionAtPosition:(NSInteger) position {
    if (![self checkParametersSection:position]) {
        return NO;
    }
    [self.sectionManager removeSectionAtPosition:position];
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:position] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    return YES;
}

-(void) reloadAllSections:(NSMutableArray *) sections {
    [self.sectionManager replaceAllSections:sections];
    [self.tableView reloadData];
}

-(NSMutableArray *) getAllSections {
    return [self.sectionManager getAllSections];
}


#pragma mark - SectionManager protocol

-(void) sectionOpenedAtIndex: (NSInteger) index NumberOfElements:(NSInteger)numberOfElements {
    NSLog(@"section %d opened, numberOfElements: %d", index, numberOfElements);
    NSInteger countOfRowsToInsert = numberOfElements;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:index]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void) sectionClosedAtIndex: (NSInteger) index NumberOfElements:(NSInteger)numberOfElements {
    NSLog(@"section %d closed, numberOfElements: %d", index, numberOfElements);
    NSInteger countOfRowsToInsert = numberOfElements;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:index]];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionManager getNumberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRows %d InSection %d", [self.sectionManager getNumberOfRows:section], section);
    return [self.sectionManager getNumberOfRows:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.sectionManager getCellFromTableView:tableView IndexPath:indexPath];
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.modeSectionsIndexTitles) {
        return [self.sectionManager getSectionIndexTitles];
    } else {
        return [NSArray array];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


#pragma mark - UITableView Delegate

#pragma mark Configuring Rows

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.sectionManager getCellHeightFromIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ([self.sectionManager getNumberOfSections] - 1) && indexPath.row == ([self.sectionManager getNumberOfRows:indexPath.section] - 1)) {
        //We reached the end of the tableView
        if ([self.additionalDelegate respondsToSelector:@selector(tableViewDidReachEnd)]) {
            [self.additionalDelegate performSelector:@selector(tableViewDidReachEnd)];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewReachedEnd" object:nil];
        }
    }
}


#pragma mark Managing Selections

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(executeAction:)]) {
        [cell executeAction:self];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}


#pragma mark Modifying Header and Footer of Sections

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionElement * sectionElement = [self getAllSections][section];
    NSLog(@"%d, %d",section, [sectionElement getTotalNumberOfRows]);
    if (self.modeSectionsExpandable) {
        [self.sectionManager setUpHandlerForSectionAtIndex:section];
    }
    return [self.sectionManager getSectionHeaderFromSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [self.sectionManager getSectionFooterFromSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.sectionManager getSectionHeaderHeightFromSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self.sectionManager getSectionFooterHeightFromSection:section];
}


#pragma mark Tracking the Removal of Views

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ////NSLog(@"hiding cell at indexPath: %d,%d",indexPath.row,indexPath.section);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    ////NSLog(@"hiding headerView");
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    ////NSLog(@"hiding footerView");
}


#pragma mark - Move Cells

// TODO: Review and clean up

- (IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: { // Start
            if (!indexPath) {
                break;
            }
            sourceIndexPath = indexPath;
            
            // Take a snapshot of the selected row using helper method.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            snapshot = [self customSnapshoFromView:cell];
            
            // Add the snapshot as subview, centered at cell's center...
            __block CGPoint center = cell.center;
            snapshot.center = center;
            snapshot.alpha = 0.0;
            [self.tableView addSubview:snapshot];
            
            [UIView animateWithDuration:0.25 animations:^{
                // Offset for gesture location.
                center.y = location.y;
                snapshot.center = center;
                snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapshot.alpha = 0.98;
                cell.alpha = 0.0;
            } completion:^(BOOL finished) {
                cell.hidden = YES;
            }];
            break;
        }
        case UIGestureRecognizerStateChanged: { // Movement
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                // move rows & update datasource
                [self exchangeRowElementAtIndexPath:indexPath WithRowElementAtIndexPath:sourceIndexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: { // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            break;
        }
    }
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
