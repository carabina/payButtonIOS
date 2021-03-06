//
//  PaymentViewController.swift
//  tokenization
//
//  Created by AMR on 7/8/18.
//  Copyright © 2018 Paysky. All rights reserved.
//

import Foundation
import UIKit
public class PaymentViewController  {
    public  var amount = 0
    public  var tId = ""
    public   var mId = ""
    public   var Key = ""
    public   var Currency = ""

    

    
    
    public  var delegate: PaymentDelegate?
    
    public init(){
        
    }
    
    
    public func pushViewController()  {
        
        
        let paymentData = PaymentData()
        paymentData.amount = amount
        paymentData.merchantId = mId
        paymentData.terminalId = tId
        paymentData.KEY = Key
        paymentData.currencyCode = Int (Currency)!

        if delegate == nil {
            
            print("Please implement Delaget ");
            return
        }
        
        
     
        if  (paymentData.amount != 0
            &&
            !paymentData.merchantId.isEmpty &&
            
               !paymentData.KEY.isEmpty &&
                    paymentData.currencyCode != 0 &&
            !paymentData.terminalId.isEmpty)
        {
            RegiserOrGetOldToken(paymentData: paymentData)
       
            
        }else{
            print("Please enter all  data ");
            return
        }
        
        
        
        
    }
    
    
 
    
    
    private func RegiserOrGetOldToken(paymentData : PaymentData)  {
        MainScanViewController.paymentData = paymentData
        MainScanViewController.paymentData.amount = ( MainScanViewController.paymentData.amount  * 100)
        
        ApiManger.CheckPaymentMethod { (paymentresponse) in
            
            
            if paymentresponse.Success {
                MainScanViewController.paymentData.merchant_name = paymentresponse.MerchantName
                MainScanViewController.paymentData.currencyCode = Int ( self.Currency )!
                    MainScanViewController.paymentData.PaymentMethod = paymentresponse.PaymentMethod
                MainScanViewController.paymentData.Is3DS = paymentresponse.Is3DS


                self.getSatatiQr()
                
                
               
                
            }else {
                UIApplication.topViewController()?.view.makeToast(  paymentresponse.Message)
            }
            
        }
        
        
        
        
        
        
     
        
    }
    

    
    
    func getSatatiQr(){
        
         if  MainScanViewController.paymentData.PaymentMethod == 1 ||
            MainScanViewController.paymentData.PaymentMethod == 2 {
                
                
       
        ApiManger.generateQrCode { (qrResponse) in
            MainScanViewController.paymentData.staticQR = qrResponse.ISOQR
            MainScanViewController.paymentData.orderId = qrResponse.TxnId
            
      
            
        }
        
         }
        
        
        
     
        
        let psb = UIStoryboard.init(name: "PayButtonBoard", bundle: nil)
        let vc :MainScanViewController = psb.instantiateViewController(withIdentifier: "MainScanViewController") as! MainScanViewController
        vc.delegate = self.delegate
        if UIApplication.topViewController()?.navigationController != nil {
            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            vc.fromNav = true
        }else{
            let nv = UINavigationController(rootViewController: vc)
            UIApplication.topViewController()?.present(nv, animated: true, completion: nil)
            vc.fromNav = false
            
        }
        
        
        
    }

    
}
public protocol PaymentDelegate: class {
    func finishSdkPayment(_ transactionStatusResponse: TransactionStatusResponse )
}
