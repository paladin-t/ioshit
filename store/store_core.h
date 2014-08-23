#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

struct Products;

typedef void (* ProductsResponseFunc)(Products*);
typedef void (* PurchaseResponseFunc)(void);
typedef void (* PurchaseRestoreFunc)(const char*);

@interface Store : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    ProductsResponseFunc resp;
    PurchaseResponseFunc purchased;
    PurchaseResponseFunc failed;
    PurchaseRestoreFunc restored;
}

- (id) init: (ProductsResponseFunc) r
          p: (PurchaseResponseFunc) p
          f: (PurchaseResponseFunc) f
          s: (PurchaseRestoreFunc) s;

- (bool) canMakePay;

- (void) requestPurchase: (NSString*) type;
- (void) requestProductData: (NSArray*) product;
- (void) restorePurchase;

- (void) requestProUpgradeProductData;
- (void) purchasedTransaction: (SKPaymentTransaction*) transaction;
- (void) paymentQueue: (SKPaymentQueue*) queue
  updatedTransactions: (NSArray*) transactions;
- (void) completeTransaction: (SKPaymentTransaction*) transaction;
- (void) failedTransaction: (SKPaymentTransaction*) transaction;
- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue*) queue;
- (void) paymentQueue: (SKPaymentQueue*) paymentQueue restoreCompletedTransactionsFailedWithError: (NSError*) error;
- (void) restoreTransaction: (SKPaymentTransaction*) transaction;
- (void) provideContent: (NSString*) product;
- (void) recordTransaction: (NSString*) product;

@end
