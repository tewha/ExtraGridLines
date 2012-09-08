//
//  ViewController.m
//  TableTest
//
//  Created by Steven Fisher on 2012-08-28.
//

#import "ViewController.h"

static NSString *TitleKey = @"Title";
static NSString *RowsKey = @"Rows";

@interface ViewController ()<UISearchDisplayDelegate> {
    // Since we're using a search controller, we implement the UISearchDisplayDelegate protocol instead.
    NSString *_searchText;
    NSArray *_allData;
    NSArray *_matchingData;
}

@property (strong) IBOutlet UISearchBar *searchBar;

@end

@implementation ViewController

- (void)updateSearchResults {
    if ( [_searchText length] == 0 ) {
        _matchingData = _allData;
    } else {
        NSMutableArray *sections = [NSMutableArray array];
        for (NSDictionary *section in _allData) {
            NSString *title = [section objectForKey: TitleKey];
            if ([[title uppercaseString] hasPrefix: [_searchText uppercaseString]]) {
                [sections addObject: section];
                continue;
            }
            NSMutableArray *matchingRows = [NSMutableArray array];
            for (NSString *row in [section objectForKey: RowsKey] ) {
                if ([[row uppercaseString] hasPrefix: [_searchText uppercaseString]]) {
                    [matchingRows addObject: row];
                }
            }
            if ( [matchingRows count] ) {
                [sections addObject: @{TitleKey: title, RowsKey: [matchingRows copy]}];
            }
        }
        _matchingData = sections;
    }
    // we don't call reloadData on the table anymore, since we're now called from searchDisplayController:shouldReloadTableForSearchString which shouldn't do so.
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // respond to searchDisplayController:shouldReloadTableForSearchString instead of searchBar:textDidChange:
    _searchText = searchString;
    [self updateSearchResults];
    
    // return YES to signal the table should be reloaded
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_matchingData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [[[_matchingData objectAtIndex: section] objectForKey: RowsKey] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = [_matchingData objectAtIndex: indexPath.section];
    if ( indexPath.row ) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"Row"];
        cell.indentationLevel = 1;
        NSArray *rows = [section objectForKey: RowsKey];
        cell.textLabel.text = [rows objectAtIndex: indexPath.row - 1];
        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"Section"];
        cell.indentationLevel = 0;
        cell.textLabel.text = [section objectForKey: TitleKey];
        return cell;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self updateSearchResults];
    // since updateSearchResults no longer recalls reloadData on the table, we must
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _allData = @[
    @{TitleKey:@"Fruit", RowsKey:@[@"Apple", @"Apricot", @"Banana", @"Date", @"Mango ", @"Melon", @"Orange", @"Peach", @"Pear", @"Plum"]},
    @{TitleKey:@"Meats", RowsKey:@[@"Chicken",@"Beef"]},
    @{TitleKey:@"Vegetables", RowsKey:@[@"Carrots",@"Peas"]},
    ];
    self.tableView.tableHeaderView = _searchBar;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
