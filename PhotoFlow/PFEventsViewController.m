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
    
    self.events = [self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    [self.tableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"JoinEvent"]) {
        PFJoinEventViewController * viewController = segue.destinationViewController;
        viewController.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"ViewEventPhotos"]) {
        PFPhotosViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
        viewController.event = [self.events objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

- (void)joinEventViewControllerCancelled:(PFJoinEventViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    
    cell.dateLabel.text = [self.dateFormatter stringFromDate:event.date];
    cell.locationLabel.text = event.location;
    cell.descriptionLabel.text = event.descriptionShort;
    [cell.bannerImageView setImageWithURL:[NSURL URLWithString:((PFPhoto *)[[event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"imageLocation" ascending:YES]]] objectAtIndex:0]).imageLocation]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)devButtonTouched:(UIButton *)devButton {
    WebDevViewController * viewController = [[WebDevViewController alloc] initWithNibName:@"WebDevViewController" bundle:[NSBundle mainBundle]];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)webDevViewControllerDidFinish:(WebDevViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
