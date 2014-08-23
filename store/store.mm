#include "store.h"
#include "store_core.h"

struct _Store {
	_Store() {
        self = this;

		store = [[Store alloc] init: _Store::responsed
                                  p: _Store::purchased
                                  f: _Store::failed
                                  s: _Store::restored
                 ];
	}
	~_Store() {
        self = NULL;

		[store release];
	}

	static void responsed(Products* p) {
        if(self->productsResponseHandler)
            self->productsResponseHandler(p);
	}
    static void purchased(void) {
        if(self->transactionPurchasedHandler)
            self->transactionPurchasedHandler();
    }
    static void failed(void) {
        if(self->transactionFailedHandler)
            self->transactionFailedHandler();
    }
    static void restored(const char* p) {
        if(self->transactionRestoredHandler)
            self->transactionRestoredHandler(p);
    }

    static _Store* self;
	Store* store;
	ProductsResponseHandler productsResponseHandler;
	TransactionPurchasedHandler transactionPurchasedHandler;
	TransactionFailedHandler transactionFailedHandler;
    TransactionRestoredHandler transactionRestoredHandler;
};

_Store* _Store::self = NULL;

static _Store* store = NULL;

void IAP::open(void) {
	assert(!store);
	store = new _Store;
}

void IAP::close(void) {
	assert(store);
	delete store;
	store = NULL;
}

void IAP::requestProducts(const ProductIdList &ids, ProductsResponseHandler h) {
    assert(store);

    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (ProductIdList::const_iterator it = ids.begin(); it != ids.end(); ++it) {
        NSString* str = [NSString stringWithUTF8String: it->c_str()];
        [arr addObject: str];
    }
    store->productsResponseHandler = h;
	[store->store requestProductData: arr];
}

void IAP::requestPayment(const ProductIdList &ids, TransactionPurchasedHandler p, TransactionFailedHandler f) {
    assert(store);

    store->transactionPurchasedHandler = p;
    store->transactionFailedHandler = f;
	[store->store requestPurchase: [NSString stringWithUTF8String: ids.front().c_str()]];
}

void IAP::restorePurchases(TransactionRestoredHandler r, TransactionFailedHandler f) {
    assert(store);

    store->transactionRestoredHandler = r;
    store->transactionFailedHandler = f;
    [store->store restorePurchase];
}
