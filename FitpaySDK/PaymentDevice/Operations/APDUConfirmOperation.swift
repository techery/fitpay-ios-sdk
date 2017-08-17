//
//  APDUConfirmOperation.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 12.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import RxSwift

protocol APDUConfirmOperationProtocol {
    func confirm(commit: Commit) -> Observable<Void>
}

class APDUConfirmOperation: APDUConfirmOperationProtocol {
    func confirm(commit: Commit) -> Observable<Void> {
        let publisher = PublishSubject<Void>()
        commit.confirmAPDU { (error) in
            guard error == nil else {
                publisher.onError(error!)
                return
            }
            
            publisher.onCompleted()
        }
        return publisher
    }
}
