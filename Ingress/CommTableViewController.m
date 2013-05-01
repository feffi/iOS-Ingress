//
//  CommTableViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "CommTableViewController.h"

@implementation CommTableViewController

@synthesize factionOnly = _factionOnly;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	self.factionOnly = NO;
	
	[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	
	[self refresh];
	
}

- (void)refresh {
	[self.refreshControl beginRefreshing];
	[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	[[API sharedInstance] loadCommunicationForFactionOnly:self.factionOnly completionHandler:^(NSArray *messages) {
		_messages = [messages mutableCopy];
		[self.tableView reloadData];
		[self.refreshControl endRefreshing];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSAttributedString *atrstr = _messages[indexPath.row][@"message"];
	
	CGFloat width = tableView.frame.size.width;
	width -= 74;
	
	CGRect rect = [atrstr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
	
	//CGSize size = [atrstr.string sizeWithFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16] constrainedToSize:CGSizeMake(width, (unsigned int)-1)];
	
	return rect.size.height;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CommTableViewCell *cell = (CommTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"msgCell" forIndexPath:indexPath];
	
	//NSLog(@"messages[indexPath.row]: %@", messages[indexPath.row]);

	cell.timeLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12];
	cell.timeLabel.text = [dateFormatter stringFromDate:_messages[indexPath.row][@"date"]];
	
	//cell.messageLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	cell.messageLabel.attributedText = _messages[indexPath.row][@"message"];
	cell.messageLabel.numberOfLines = 0;
	
	return cell;
	
}

@end
