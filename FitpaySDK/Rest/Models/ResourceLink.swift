
import Foundation

internal class ResourceLink: CustomStringConvertible
{
    var target: String?
    var href: String?

    var description: String {
        return "\(ResourceLink.self)(\(target ?? "target nil"):\(href ?? "href nil"))"
    }
}

import ObjectMapper

internal class ResourceLinkTransformType: TransformType
{

    typealias Object = [ResourceLink]
    typealias JSON = [String: [String: String]]

    func transformFromJSON(_ value: Any?) -> Array<ResourceLink>? {
        if let links = value as? [String: [String: String]] {
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

    func transformToJSON(_ value: [ResourceLink]?) -> [String: [String: String]]? {
        if let links = value {
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

