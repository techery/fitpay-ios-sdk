//
//  SyncOperation.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 10.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import RxSwift

internal enum SyncOperationError: Error {
    case deviceIdentifierIsNil
    case couldNotConnectToDevice
    case paymentDeviceDisconnected
    case cantFetchCommits
    case alreadySyncing
    case unk
}

internal class SyncOperation {
    
    init(paymentDevice:  PaymentDevice,
         connector:      IPaymentDeviceConnector,
         deviceInfo:     DeviceInfo,
         user:           User)
    {
        self.paymentDevice    = paymentDevice
        self.connector        = connector
        self.deviceInfo       = deviceInfo
        self.user             = user
        self.commitsApplyer   = CommitsApplyer(paymentDevice: self.paymentDevice,
                                               eventsPublisher: PublishSubject<SyncEvent>(),
                                               syncStorage: SyncStorage.sharedInstance)
        self.state            = Variable(.waiting)
        self.connectOperation = ConnectDeviceOperation(paymentDevice: paymentDevice)
    }
    
    enum SyncOperationState {
        case waiting
        case started
        case connecting
        case connected
        case commitsReceived
        case completed(Error?)
    }
    
    func start() -> Observable<SyncOperationState> {
        let observable = self.state.asObservable().do(onNext: { [weak self] (state) in
            switch state {
            case .waiting:
                break
            case .started:
                self?.isSyncing = true
                break
            case .connected:
                break
            case .connecting:
                break
            case .completed:
                self?.isSyncing = false
                break
            case .commitsReceived:
                break
            }
        })
        
        guard self.isSyncing == false else {
            self.state.value = .completed(SyncOperationError.alreadySyncing)
            return observable
        }
        
        self.startSync()
        
        return observable
    }
    
    var syncStorage = SyncStorage.sharedInstance

    // private
    fileprivate var paymentDevice: PaymentDevice
    fileprivate var connector: IPaymentDeviceConnector
    fileprivate var deviceInfo: DeviceInfo
    fileprivate var user: User
    fileprivate var commitsApplyer: CommitsApplyer
    fileprivate var connectOperation: ConnectDeviceOperation
    
    // rx
    fileprivate var state: Variable<SyncOperationState>
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var isSyncing = false

    fileprivate func fetchCommits(completion: @escaping ([Commit]?, Error?) -> Void) {
        guard let deviceIdentifier = self.deviceInfo.deviceIdentifier else {
            completion(nil, SyncOperationError.deviceIdentifierIsNil)
            return
        }

        let lastCommitId = syncStorage.getLastCommitId(deviceIdentifier)

        deviceInfo.listCommits(commitsAfter: lastCommitId, limit: 20, offset: 0) { (result, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let result = result else {
                completion(nil, NSError.unhandledError(SyncOperation.self))
                return
            }

            if result.totalResults ?? 0 > result.results?.count ?? 0 {
                result.collectAllAvailable() { (results, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    guard let results = results else {
                        completion(nil, NSError.unhandledError(SyncOperation.self))
                        return
                    }

                    completion(results, nil)
                }
            } else {
                completion(result.results, nil)
            }
        }
    }
    
    fileprivate func startSync() {
        self.connectOperation.start().subscribe() { [weak self] (event) in
            switch event {
            case .error(let error):
                self?.state.value = .completed(error)
                break
            case .next(let state):
                switch state {
                case .connected:
                    self?.state.value = .connected
                    self?.sync()
                    break
                case .connecting:
                    self?.state.value = .connecting
                    break
                case .disconnected:
                    if self?.isSyncing == true {
                        self?.state.value = .completed(SyncOperationError.paymentDeviceDisconnected)
                    }
                    break
                }
                break
            case .completed:
                print("REMOVE ME! completed")
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    fileprivate func sync() {
        self.fetchCommits { [weak self] (commits, error) in
            guard error == nil else {
                log.error("Can't fetch commits. Error: \(error!)")
                self?.state.value = .completed(SyncManager.ErrorCode.cantFetchCommits)
                return
            }
            
            guard commits != nil else {
                log.error("Can't fetch commits. Commits is nil.")
                self?.state.value = .completed(SyncManager.ErrorCode.cantFetchCommits)
                return
            }
            
            self?.state.value = .commitsReceived
            
            let applayerStarted = self?.commitsApplyer.apply(commits!) { (error) in
                
                if let error = error {
                    log.error("SYNC_DATA: Commit applier returned a failure: \(error)")
                    self?.state.value = .completed(error)
                    return
                }
                
                log.verbose("SYNC_DATA: Commit applier returned with out errors.")
                
                self?.state.value = .completed(nil)

                // NEEDS TO BE DONE!
//                self.getAllCardsWithToWAPDUCommands({ [unowned self] (cards, error) in
//                    if let error = error {
//                        log.error("SYNC_DATA: Can't get offline APDU commands. Error: \(error)")
//                        return
//                    }
//                    
//                    if let cards = cards {
//                        self.callCompletionForSyncEvent(SyncEventType.receivedCardsWithTowApduCommands, params: ["cards":cards])
//                    }
//                })
            }
            
            if applayerStarted ?? false == false {
                self?.state.value = .completed(NSError.error(code: SyncManager.ErrorCode.commitsApplyerIsBusy, domain: SyncOperation.self))
            }
        }
    }
}

