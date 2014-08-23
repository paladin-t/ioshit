#ifndef __STORE_H__
#define __STORE_H__

#include <list>
#include <string>

typedef std::list<std::string> ProductIdList;

struct Product {
	std::string desc;
	std::string locTitle;
	std::string locDesc;
	std::string price;
    std::string id;
};
typedef std::list<Product> ProductList;

struct Products {
	int count;
	ProductList lst;
};

typedef void (* ProductsResponseHandler)(Products*);

typedef void (* TransactionPurchasingHandler)(void);
typedef void (* TransactionPurchasedHandler)(void);
typedef void (* TransactionFailedHandler)(void);
typedef void (* TransactionRestoredHandler)(const char*);

struct IAP {
	static void open(void);
	static void close(void);
	static void requestProducts(const ProductIdList &ids, ProductsResponseHandler h);
	static void requestPayment(const ProductIdList &ids, TransactionPurchasedHandler p, TransactionFailedHandler f);
    static void restorePurchases(TransactionRestoredHandler r, TransactionFailedHandler f);
};

#endif // __STORE_H__
