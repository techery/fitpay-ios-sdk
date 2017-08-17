//
//  FetchCommitsOperation.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 12.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import RxSwift

public protocol FetchCommitsOperationProtocol {
    var deviceInfo: DeviceInfo! { get set }
    
    func startWith(limit: Int, andOffset offset: Int) -> Observable<[Commit]>
}

open class FetchCommitsOperation: FetchCommitsOperationProtocol {
    
    public init(deviceInfo: DeviceInfo, shouldStartFromSyncedCommit: Bool = false, syncStorage: SyncStorage = SyncStorage.sharedInstance) {
        self.deviceInfo = deviceInfo
        self.startFromSyncedCommit = shouldStartFromSyncedCommit
        self.syncStorage = syncStorage
    }
    
    public enum ErrorCode: Error {
        case parsingError
    }
    
    public func startWith(limit: Int, andOffset offset: Int) -> Observable<[Commit]> {
        let commitId = generateCommitIdFromWhichWeShouldStart()
        
        deviceInfo.listCommits(commitsAfter: commitId, limit: limit, offset: offset) { [weak self] (result, error) in
            guard error == nil else {
                self?.publisher.onError(error!)
                return
            }
            
            guard let result = result, let commits = result.results else {
                self?.publisher.onError(ErrorCode.parsingError)
                return
            }
            
            if result.totalResults ?? 0 > result.results?.count ?? 0 {
                result.collectAllAvailable() { (results, error) in
                    guard error == nil else {
                        self?.publisher.onError(error!)
                        return
                    }
                    
                    guard let results = results else {
                        self?.publisher.onError(ErrorCode.parsingError)
                        return
                    }
                    
                    self?.publisher.onNext(results)
                }
            } else {
                self?.publisher.onNext(commits)
            }
        }
        
        return publisher
    }
    
    open func generateCommitIdFromWhichWeShouldStart() -> String {
        var commitId = ""
        if self.startFromSyncedCommit {
            commitId = self.syncStorage.getLastCommitId(self.deviceInfo.deviceIdentifier!)
        }
        
        if commitId.isEmpty {
            commitId = deviceInfo.lastAckCommit ?? ""
        }

        return commitId
    }
    
    
    public var deviceInfo: DeviceInfo!
    
    // private
    private let syncStorage: SyncStorage
    private let startFromSyncedCommit: Bool

    //rx
    private let publisher = PublishSubject<[Commit]>()
}
