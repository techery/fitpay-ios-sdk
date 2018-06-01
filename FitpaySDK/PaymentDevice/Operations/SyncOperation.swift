import Foundation
import RxSwift

enum SyncOperationError: Error {
    case deviceIdentifierIsNil
    case couldNotConnectToDevice
    case paymentDeviceDisconnected
    case cantFetchCommits
    case alreadySyncing
    case unk
}

class SyncOperation {
    
    init(paymentDevice: PaymentDevice, connector: PaymentDeviceConnectable,
         deviceInfo: DeviceInfo, user: User, syncFactory: SyncFactory,
         syncStorage: SyncStorage = SyncStorage.sharedInstance, request: SyncRequest? = nil) {
        
        self.paymentDevice = paymentDevice
        self.connector     = connector
        self.deviceInfo    = deviceInfo
        self.user          = user
        
        self.syncEventsPublisher   = PublishSubject<SyncEvent>()
        self.commitsApplyer        = CommitsApplyer(paymentDevice: self.paymentDevice,
                                                    deviceInfo: self.deviceInfo,
                                                    eventsPublisher: self.syncEventsPublisher,
                                                    syncFactory: syncFactory,
                                                    syncStorage: syncStorage)
        self.state                 = Variable(.waiting)
        self.connectOperation      = syncFactory.connectDeviceOperationWith(paymentDevice: paymentDevice)
        self.eventsAdapter         = SyncOperationStateToSyncEventAdapter(stateObservable: self.state.asObservable(),
                                                                          publisher: self.syncEventsPublisher)
        
        self.fetchCommitsOperation = syncFactory.commitsFetcherOperationWith(deviceInfo: deviceInfo, connector: connector)
        
        self.syncStorage = syncStorage
        self.syncRequest = request
    }
    
    enum SyncOperationState {
        case waiting
        case started
        case connecting
        case connected
        case commitsReceived(commits: [Commit])
        case completed(Error?)
    }
    
    func start() -> Observable<SyncEvent> {
        self.state.asObservable().subscribe(onNext: { [weak self] (state) in
            switch state {
            case .waiting, .connected, .connecting, .commitsReceived:
                break
            case .started:
                self?.isSyncing = true
                break
            case .completed:
                self?.isSyncing = false
                break
            }
        }).disposed(by: disposeBag)
        
        guard self.isSyncing == false else {
            self.state.value = .completed(SyncOperationError.alreadySyncing)
            return self.eventsAdapter.startAdapting()
        }
        
        // we need to update notification token first, because during sync we can receive push notifications
        self.deviceInfo.updateNotificationTokenIfNeeded { [weak self] (_, error) in
            self?.startSync()
        }
        
        return self.eventsAdapter.startAdapting()
    }
    
    // MARK: internal
    var fetchCommitsOperation: FetchCommitsOperationProtocol // Dependency Injection
    var commitsApplyer: CommitsApplyer
    
    // MARK: private
    private var paymentDevice: PaymentDevice
    private var connector: PaymentDeviceConnectable
    private var deviceInfo: DeviceInfo
    private var user: User
    private var connectOperation: ConnectDeviceOperationProtocol
    private var eventsAdapter: SyncOperationStateToSyncEventAdapter
    private var syncStorage: SyncStorage
    public var syncRequest: SyncRequest?
    
    // rx
    private var syncEventsPublisher: PublishSubject<SyncEvent>
    private var state: Variable<SyncOperationState>
    private var disposeBag = DisposeBag()
    
    private var isSyncing = false
    
    private func startSync() {
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
                break
            }
            }.disposed(by: self.disposeBag)
    }
    
    private func sync() {
        self.fetchCommitsOperation.startWith(limit: 20, andOffset: 0).subscribe() { [weak self] (e) in
            switch e {
            case .error(let error):
                log.error("Can't fetch commits. Error: \(error)")
                self?.sendCommitsMetric()
                self?.state.value = .completed(SyncManager.ErrorCode.cantFetchCommits)
                break
            case .next(let commits):
                self?.state.value = .commitsReceived(commits: commits)
                
                let applayerStarted = self?.commitsApplyer.apply(commits) { (error) in
                    
                    if let error = error {
                        log.error("SYNC_DATA: Commit applier returned a failure: \(error)")
                        self?.state.value = .completed(error)
                        return
                    }
                    
                    log.verbose("SYNC_DATA: Commit applier returned without errors.")
                    
                    self?.sendCommitsMetric()
                    self?.state.value = .completed(nil)
                }
                
                if applayerStarted ?? false == false {
                    self?.state.value = .completed(NSError.error(code: SyncManager.ErrorCode.commitsApplyerIsBusy, domain: SyncOperation.self))
                }
                break
            case .completed:
                self?.sendCommitsMetric()
                break
            }
            }.disposed(by: disposeBag)
        
    }
    
    private func sendCommitsMetric() {
        guard (self.syncRequest?.notificationAsc) != nil else { return }
        
        let currentTimestamp = Date().timeIntervalSince1970
        
        let metric = CommitMetrics()
        metric.commitStatistics = self.commitsApplyer.commitStatistics
        metric.deviceId = deviceInfo.deviceIdentifier
        metric.userId = user.id
        metric.initiator = self.syncRequest?.syncInitiator
        metric.notificationAsc = self.syncRequest?.notificationAsc
        metric.totalProcessingTimeMs = Int((currentTimestamp - (self.syncRequest?.syncStartTime?.timeIntervalSince1970)!)*1000)
        
        metric.sendCompleteSync()
    }
}
