import ObjectMapper

open class CommitStatistic : Mappable
{
    open var commitId:String?
    open var processingTimeMs:Int?
    open var averageTimePerCommand:Int?
    open var errorReason:String?
    
    public required init?(map: Map) {
        
    }
    
    public init(commitId:String?, total:Int?, average:Int?, errorDesc:String?) {
        self.commitId = commitId
        self.processingTimeMs = total
        self.averageTimePerCommand = average
        self.errorReason = errorDesc
    }
    
    open func mapping(map: Map) {
        commitId <- map["commitId"]
        processingTimeMs <- map["processingTimeMs"]
        averageTimePerCommand <- map["averageTimePerCommand"]
        errorReason <- map["errorReason"]
    }
}
