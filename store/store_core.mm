#import "store_core.h"
#import "store.h"

@implementation Store

- (id) init: (ProductsResponseFunc) r
          p: (PurchaseResponseFunc) p
          f: (PurchaseResponseFunc) f
          s: (PurchaseRestoreFunc) s {
	if((self = [super init])) {
		[[SKPaymentQueue defaultQueue] addTransactionObserver: self];
        resp = r;
        purchased = p;
        failed = f;
        restored = s;
    }

	return self;
}

- (bool) canMakePay {
    return [SKPaymentQueue canMakePayments];
}

- (void) requestPurchase: (NSString*) type {
	if ([SKPaymentQueue canMakePayments]) {
        SKPayment* payment = nil;
		payment = [SKPayment paymentWithProductIdentifier: type];
		[[SKPaymentQueue defaultQueue] addPayment: payment];
	} else {
		printf("IAP unpurchasable.\n");
		UIAlertView* alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                           message: @"Cannot purchase in App Store."
                                                          delegate: nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil
                                 ];

		[alerView show];
		[alerView release];

        if(failed)
            failed();
    }
}

- (void) requestProductData: (NSArray*) product {
	if ([SKPaymentQueue canMakePayments]) {
		NSSet* nsset = [NSSet setWithArray: product];
		SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
		request.delegate = self;
		[request start];
		[product release];
	} else {
		printf("IAP unpurchasable.\n");
		UIAlertView* alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                           message: @"Cannot connect to App Store."
                                                          delegate: nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil
                                 ];

		[alerView show];
		[alerView release];
    }
}

- (void) restorePurchase {
	if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	} else {
		printf("IAP unpurchasable.\n");
		UIAlertView* alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                           message: @"Cannot connect to App Store."
                                                          delegate: nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil
                                 ];

		[alerView show];
		[alerView release];

        if(failed)
            failed();
    }
}

- (void) productsRequest: (SKProductsRequest*) request didReceiveResponse: (SKProductsResponse*) response {
	NSArray* myProduct = response.products;

    printf("IAP received %d products data.\n", [myProduct count]);

    Products ps;
    ps.count = [myProduct count];

    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter autorelease];

	for (SKProduct* product in myProduct) {
        [numberFormatter setLocale: product.priceLocale];
        NSString* formattedPrice = [numberFormatter stringFromNumber: product.price];

        ps.lst.push_back(Product());
        Product &p = ps.lst.back();
        p.desc = [[product description] UTF8String];
        p.locTitle = [[product localizedTitle] UTF8String];
        p.locDesc = [[product localizedDescription] UTF8String];
        p.price = [formattedPrice UTF8String];
        p.id = [[product productIdentifier] UTF8String];
	}

    resp(&ps);

	[request autorelease];
}

- (void) requestProUpgradeProductData {
	NSSet* productIdentifiers = [NSSet setWithObject: @"com.productid"];
	SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (void) purchasedTransaction: (SKPaymentTransaction*) transaction {
	NSArray* transactions = [[NSArray alloc] initWithObjects: transaction, nil];
	[self paymentQueue: [SKPaymentQueue defaultQueue] updatedTransactions: transactions];
	[transactions release];
}

- (void) request: (SKRequest*) request didFailWithError: (NSError*) error {
    printf("IAP Cannot cannect to App Store now.\n");
}

- (void) requestDidFinish: (SKRequest*) request {
}

- (void) paymentQueue: (SKPaymentQueue*) queue updatedTransactions: (NSArray*) transactions {
	for (SKPaymentTransaction* transaction in transactions) {
        UIAlertView* alerView = NULL;
		switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction: transaction];
                printf("IAP Purchased.\n");
                alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                      message: @"Purchased!"
                                                     delegate: nil
                                            cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                            otherButtonTitles: nil
                            ];

                [alerView show];
                [alerView release];

                if (purchased)
                    purchased();

                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction: transaction];
                printf(
                    "IAP Failed: %d; %s.\n",
                    transaction.error.code,
                    [[transaction.error localizedDescription] UTF8String]
                );
                alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                      message: @"Purchase canceled or failed."
                                                     delegate: nil
                                            cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                            otherButtonTitles: nil
                            ];

                [alerView show];
                [alerView release];

                if (failed)
                    failed();

                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction: transaction];

                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            case SKPaymentTransactionStatePurchasing:
                break;
            default:
                break;
		}
	}
}

- (void) completeTransaction: (SKPaymentTransaction*) transaction {
	NSString* product = transaction.payment.productIdentifier;
	if ([product length] > 0) {
		NSArray* tt = [product componentsSeparatedByString: @"."];
		NSString* bookid = [tt lastObject];
		if ([bookid length] > 0) {
			[self recordTransaction: bookid];
			[self provideContent: bookid];
		}
	}

	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction*) transaction {
	if (transaction.error.code != SKErrorPaymentCancelled) {
        //
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue*) queue {
    NSMutableArray* purchasedItemIds = [[NSMutableArray alloc] init];
    printf("%d\n", queue.transactions.count);
    if (queue.transactions.count) {
        for (SKPaymentTransaction* t in queue.transactions) {
            NSString* pid = t.payment.productIdentifier;
            [purchasedItemIds addObject: pid];

            if(restored)
                restored([pid UTF8String]);
            printf("IAP restored %s.\n", [pid UTF8String]);
        }

        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                           message: @"Restored!"
                                                          delegate: nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil
                                 ];

        [alerView show];
        [alerView release];
    } else {
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle: @"Message"
                                                           message: @"Nothing to restore."
                                                          delegate: nil
                                                 cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                 otherButtonTitles: nil
                                 ];

        [alerView show];
        [alerView release];

        if (failed)
            failed();

        printf("IAP nothing to restore.\n");
    }
}

- (void) paymentQueue: (SKPaymentQueue*) paymentQueue restoreCompletedTransactionsFailedWithError: (NSError*) error {
    if (failed)
        failed();
}

- (void) restoreTransaction: (SKPaymentTransaction*) transaction {
}

- (void) recordTransaction: (NSString*) product {
}

- (void) provideContent: (NSString*) product {
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data {
	NSLog(@"%@", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease]);
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
}

- (void) connection: (NSURLConnection*) connection didReceiveResponse: (NSURLResponse*) response {
}

- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error {
}

- (void) dealloc {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
	[super dealloc];
}

@end
