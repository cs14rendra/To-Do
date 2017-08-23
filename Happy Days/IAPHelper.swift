//
//  IAPHelper.swift
//  Happy Days
//
//  Created by surendra kumar on 7/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import  StoreKit

protocol IAPHelperDelegate {
    func didItemPurchasedSuccessfully()
}

class IAPHelper : NSObject {
    
    public static let sharedInstance = IAPHelper()
    var delegate : IAPHelperDelegate?
    var istransationinProgress = false
    var localProductID  = [String]()
    var productArray = [SKProduct](){
        didSet{
            // purchase ITEm and pay
            self.RequestforPayment()
        }
    }
    
    override init() {
        localProductID.append("myprodyctID")
    }
    
    
    func PurchaseItem(){
        if SKPaymentQueue.canMakePayments(){
            let productrequest = SKProductsRequest(productIdentifiers: NSSet(array: localProductID) as! Set<String>)
            productrequest.delegate = self
            productrequest.start()
        }else{
            print("cant perform transation")
        }
    }
    
    
    private func RequestforPayment(){
//        guard istransationinProgress else {
//            let alert = UIAlertController(title: "Transaction", message: "Transaction is in progress....", preferredStyle: .alert)
//            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(action)
//            //self.present(alert, animated: true, completion: nil)
//        }
        let payment = SKPayment(product: self.productArray[0])
        SKPaymentQueue.default().add(payment)
        self.istransationinProgress = true
        SKPaymentQueue.default().add(self)
    }
    
}

extension IAPHelper : SKProductsRequestDelegate{
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products{
                self.productArray.append(product)
            }
        }
    }
}

extension IAPHelper : SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            
            switch transaction.transactionState {
            case .purchased,.restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                delegate?.didItemPurchasedSuccessfully()
                self.istransationinProgress = false
                break
            case .failed :
                SKPaymentQueue.default().finishTransaction(transaction)
                self.istransationinProgress = false
                break
            default:
                break
            }
        }
    }
}
