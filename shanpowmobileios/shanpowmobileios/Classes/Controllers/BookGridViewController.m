//
//  BookGridViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BookGridViewController.h"

@interface BookGridViewController ()

@property (nonatomic, assign) float headerHeight;
@property (nonatomic, assign) float bookCellHeight;

@end

@implementation BookGridViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
		self.bookCellHeight = 70.0;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.headerHeight = 40.0;
	if (IsSysVerGTE(7.0)) {
		self.tableView.separatorInset = UIEdgeInsetsZero;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTableCell:) name:MSG_DID_SELECT_BOOK object:nil];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_SELECT_BOOK object:nil];
	[super viewWillDisappear:animated];
}

- (void)setIsPlain:(BOOL)isPlain {
	if (isPlain != _isPlain) {
		_isPlain = isPlain;
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Event handler

- (void)didSelectTableCell:(NSNotification *)notification {
	NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];

	// Show table item selected animate
	for (BookInfoCell *cell in self.tableView.visibleCells) {
		if ([cell.bookInfoView.book.Id isEqualToString:bookId]) {
			[self.tableView selectRowAtIndexPath:cell.indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			[self.tableView deselectRowAtIndexPath:cell.indexPath animated:YES];
		}
	}
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.bookCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (self.isPlain) {
		return 0;
	}

	if ([[[self.books objectAtIndex:section] objectForKey:@"Books"] count] == 0) {
		return 0;
	}

	return self.headerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (isLastCell(tableView, indexPath)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_BOOKGRID_LOADMORE_TAPPED object:self];
	}

	return;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (self.isPlain) {
		return nil;
	}

	if ([[[self.books objectAtIndex:section] objectForKey:@"Books"] count] == 0) {
		return nil;
	}

	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width - 20, self.headerHeight)];
	headerLabel.text = [[self.books objectAtIndex:section] objectForKey:@"Category"];
	headerLabel.textColor = UIC_BRIGHT_GRAY(1.0);
	headerLabel.backgroundColor = [UIColor clearColor];

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
	[headerView addSubview:headerLabel];
	headerView.backgroundColor = UIC_WHISPER(1.0);

	return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	if (self.books == nil) {
		return 0;
	}
	if (self.isPlain) {
		return 1;
	}
	return [self.books count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	if (self.books == nil) {
		return 0;
	}
	if (self.isPlain) {
		if (self.needLoadMore) {
			return [self.books count] + 1;
		}
		else {
			return [self.books count];
		}
	}
	return self.needLoadMore ? [[[self.books objectAtIndex:section] objectForKey:@"Books"] count] + 1 : [[[self.books objectAtIndex:section] objectForKey:@"Books"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (isLastCell(tableView, indexPath) && self.needLoadMore) {
		static NSString *CellIdentifier = @"Cell1";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}

		cell.textLabel.text = @"点击加载更多";
		cell.textLabel.font = MEDIUM_FONT;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;

		return cell;
	}
	else {
		static NSString *CellIdentifier = @"Cell";
		BookInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		NSDictionary *bookInfo = @{};
		if (self.isPlain) {
			bookInfo = [self.books objectAtIndex:indexPath.row];
		}
		else {
			bookInfo = [[[self.books objectAtIndex:indexPath.section] objectForKey:@"Books"] objectAtIndex:indexPath.row];
		}

		if (cell == nil) {
			cell = [[BookInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.bookInfoView.style = BookInfoViewStyleMedium;
			cell.bookInfoView.colorStyle = BookInfoViewColorStyleDefault;
		}

		Book *book = [Book bookFromDictionary:bookInfo];
		[cell.bookInfoView setBook:book];

		if (book.summary) {
			cell.bookInfoView.hasBookDescription = YES;
		}
		if (book.simpleComment) {
			cell.bookInfoView.hasBookComment = YES;
		}

		UIView *cellBackground = [[UIView alloc] initWithFrame:cell.bounds];
		cellBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
		cell.selectedBackgroundView = cellBackground;

		cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];

		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
			cell.contentView.backgroundColor = cell.backgroundColor;
		}

		cell.indexPath = indexPath;

		[cell addSubview:cell.bookInfoView];

		return cell;
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

/*
   #pragma mark - Navigation

   // In a story board-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }

 */

@end
