//
//  HAPurchasesMagic.m
//  ControlHoras
//
//  Created by Hipolito Arias on 27/8/16.
//  Copyright © 2016 com.masterapps. All rights reserved.
//

#import "HAPurchasesMagic.h"

#import "AvePurchaseButton.h"
#import <StoreKit/StoreKit.h>
#import "MKStoreKit.h"

@interface HAPurchasesMagic () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *productAvailables;
}

@end

@implementation HAPurchasesMagic

- (HAPurchasesMagic *) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:(NSCoder *)aDecoder])
    {
        [self commitInit];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self reloadData];
}


- (void)commitInit
{
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.rowHeight = 54;
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    
    [self configurePurchases];
}


- (void)configurePurchases
{
    [[MKStoreKit sharedKit] startProductRequest];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         [self updateData];
     }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         [self updateData];
         NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
         
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         [self updateData];
         NSLog(@"Restored Purchases");
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         NSLog(@"Restore failed");
     }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         [self updateData];
         NSLog(@"Transaction Failed with error: %@", [note object]);
     }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitDownloadCompletedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note)
     {
         [self updateData];
         NSLog(@"Download complete Failed with error: %@", [note object]);
     }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productAvailables.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const CellIdentifier = @"Cell";
    
    UITableViewCell* cell = nil;
    
    if (indexPath.row != 0)
    {
        SKProduct *product = productAvailables[indexPath.row];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        
        // configure the cell
        cell.textLabel.text = product.localizedTitle;
        cell.detailTextLabel.text = product.localizedDescription;
        
        
        // add a buttons as an accessory and let it respond to touches
        AvePurchaseButton* button = [[AvePurchaseButton alloc] initWithFrame:CGRectZero];
        [button addTarget:self action:@selector(purchaseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        
        if(![[MKStoreKit sharedKit] isProductPurchased:product.productIdentifier])
        {
            button.confirmationTitle = @"COMPRAR";
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setLocale:product.priceLocale];
            button.normalTitle = [formatter stringFromNumber:product.price];
            
            //
            //            // if the item at this indexPath is being "busy" with purchasing, update the purchase
            //            // button's state to reflect so.
            //            if([_busyIndexes containsIndex:indexPath.row] == YES)
            //            {
            //                button.buttonState = AvePurchaseButtonStateProgress;
            //            }
        }
        else
        {
            button.confirmationTitle = @"COMPRADO";
            button.normalTitle = @"COMPRADO";
            // configure the purchase button in state normal
            button.buttonState = AvePurchaseButtonStateConfirmation;
        }
        
        [button sizeToFit];
        
    }
    else
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        cell.textLabel.text = productAvailables[0];
    }
    return cell;
}


- (void)updateData
{
    productAvailables = [NSMutableArray new];
    [productAvailables addObject:@"Restaurar compras"];
    [productAvailables addObjectsFromArray:[[MKStoreKit sharedKit] availableProducts]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectRowAtIndexPath:indexPath animated:YES];
    [[MKStoreKit sharedKit] restorePurchases];
}


- (void)purchaseButtonTapped:(AvePurchaseButton*)button
{
    NSIndexPath* indexPath = [self indexPathForCell:(UITableViewCell*)button.superview];
    NSInteger index = indexPath.row;
    
    SKProduct *product = productAvailables[index];
    
    
    // handle taps on the purchase button by
    switch(button.buttonState)
    {
        case AvePurchaseButtonStateNormal:
            // progress -> confirmation
            [button setButtonState:AvePurchaseButtonStateConfirmation animated:YES];
            break;
            
        case AvePurchaseButtonStateConfirmation:
            // confirmation -> "purchase" progress
            if(![[MKStoreKit sharedKit] isProductPurchased:product.productIdentifier])
            {
                [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:product.productIdentifier];
                [button setButtonState:AvePurchaseButtonStateProgress animated:YES];
            }
            break;
            
        case AvePurchaseButtonStateProgress:
            // progress -> back to normal
            [button setButtonState:AvePurchaseButtonStateNormal animated:YES];
            break;
    }
}


@end
