//
//  PFEventsViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFEventsViewController.h"
#import "PFPhotosViewController.h"
#import "PFEventCell.h"
#import "UIImageView+AFNetworking.h"

@interface PFEventsViewController ()
@property (nonatomic, strong, readonly) NSDateFormatter * dateFormatter;
- (void) loadImageForCell:(PFEventCell *)cell atIndexPath:(NSIndexPath *)indexPath fromEvent:(PFEvent *)event;
- (void) loadImagesForVisibleCells;
@end

@implementation PFEventsViewController

@synthesize dateFormatter=_dateFormatter;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.events = [self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    [self.tableView reloadData];
    
    UIImage * titleImage = [UIImage imageNamed:@"branding_text.png"];
    UIImageView * titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    titleImageView.frame = CGRectMake(0, 3, titleImage.size.width, titleImage.size.height + 3);
    titleImageView.contentMode = UIViewContentModeBottom;
    [self.navigationItem setTitleView:titleImageView];
    
    UIImage * buttonImage = [UIImage imageNamed:@"btn_add_event.png"];
    UIButton * normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    normalButton.frame = CGRectMake(0, 0, buttonImage.size.width + 15 /* COULD HAVE ALSO DONE THIS WITH A FIXED SPACE UIBARBUTTONITEM */, buttonImage.size.height);
    [normalButton setImage:buttonImage forState:UIControlStateNormal];
    [normalButton setImage:[UIImage imageNamed:@"btn_add_event_highlight.png"] forState:UIControlStateHighlighted];
    [normalButton addTarget:self.addEventButton.target action:self.addEventButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.addEventButton setCustomView:normalButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_medium_texture.png"]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    [self.tableView reloadData]; // Fixing a weird bug coming from a landscape photos banner view controller (which actually is still oriented as portrait, because landscape banner is not allowed).
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ViewEventPhotos"]) {
        PFPhotosViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
        viewController.event = [self.events objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

- (void)addEventButtonTouched:(id)sender {
    // This is rather non-standard...
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * CellIdentifier = @"EventCell";
    PFEventCell * cell = (PFEventCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFEvent * event = [self.events objectAtIndex:indexPath.row];
    
    cell.dateLabel.text = [self.dateFormatter stringFromDate:event.date].uppercaseString;
    cell.locationLabel.text = event.location.uppercaseString;
    cell.descriptionLabel.text = event.descriptionShort;
    [self loadImageForCell:cell atIndexPath:indexPath fromEvent:event];
    
    return cell;
}

- (void) loadImagesForVisibleCells {
    for (PFEventCell * cell in self.tableView.visibleCells) {
        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
        PFEvent * event = [self.events objectAtIndex:indexPath.row];
        [self loadImageForCell:cell atIndexPath:indexPath fromEvent:event];
    }
}

- (void) loadImageForCell:(PFEventCell *)cell atIndexPath:(NSIndexPath *)indexPath fromEvent:(PFEvent *)event {
    if (event.photos.count > 0) {
        [cell layoutIfNeeded];
        [cell.bannerImageView setImageWithURL:[NSURL URLWithString:[[PFHTTPClient sharedClient] imageURLStringForPhoto:((PFPhoto *)[[event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]] objectAtIndex:0]).eid boundingWidth:cell.bannerImageView.bounds.size.width*2 boundingHeight:cell.bannerImageView.bounds.size.height*2 quality:60 mode:UIViewContentModeScaleAspectFill]] placeholderImage:nil];
    } else {
        cell.bannerImageView.image = nil;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PFEvent * event = self.events[indexPath.row];
        NSLog(@"deleting event with eid %@", event.eid);
        [self.moc deleteObject:event];
        [self.moc saveCoreData];
        self.events = [self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//}

//- (void)devButtonTouched:(UIButton *)devButton {
//    WebDevViewController * viewController = [[WebDevViewController alloc] initWithNibName:@"WebDevViewController" bundle:[NSBundle mainBundle]];
//    viewController.delegate = self;
//    [self presentViewController:viewController animated:YES completion:NULL];
//}

- (void)webDevViewControllerDidFinish:(WebDevViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self loadImagesForVisibleCells];
}

@end
