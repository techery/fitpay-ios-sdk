
import Foundation

internal class ResourceLink: CustomStringConvertible {
    var target: String?
    var href: String?

    var description: String {
        return "\(ResourceLink.self)(\(target ?? "target nil"):\(href ?? "href nil"))"
    }
}

internal class ResourceLinkTypeTransform: CodingContainerTransformer {
    typealias Output = [ResourceLink]
    typealias Input = [String: [String: String]]

    func transform(_ decoded: Input?) -> Output? {
        if let links = decoded {
            var list = [ResourceLink]()

            for (target, map) in links {
                let link = ResourceLink()
                link.target = target
                link.href = map["href"]
                list.append(link)
            }

            return list
        }

        return nil
    }

    func transform(_ encoded: Output?) -> Input? {
        if let links = encoded {
            var map = [String: [String: String]]()

            for link in links {
                if let target = link.target, let href = link.href {
                    map[target] = ["href": href]
                }
            }

            return map
        }

        return nil
    }
}

