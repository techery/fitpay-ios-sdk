//
//  NonAPDUConfirmOperation.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 16.08.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import RxSwift

protocol NonAPDUConfirmOperationProtocol {
    func startWith(commit: Commit, result: NonAPDUCommitState) -> Observable<Void>
}

class NonAPDUConfirmOperation: NonAPDUConfirmOperationProtocol {
    
    func startWith(commit: Commit, result: NonAPDUCommitState) -> Observable<Void> {
        let publisher = PublishSubject<Void>()
        commit.confirmNonAPDUCommitWith(result: result) { (error) in
            guard error == nil else {
                publisher.onError(error!)
                return
            }
            
            publisher.onCompleted()
        }
        return publisher
    }
    
}
