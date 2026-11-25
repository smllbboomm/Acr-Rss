import Foundation

/// OPML 导入导出（XMLParser / 手写 XML，无第三方库）
enum OPMLService {
    static func export(feeds: [Feed]) -> String {
        var xml = "<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>\n<opml version=\\"2.0\\"><head><title>ACR</title></head><body>\n"
        for f in feeds {
            xml += "<outline type=\\"rss\\" text=\\"\(escape(f.title))\\" title=\\"\(escape(f.title))\\" xmlUrl=\\"\(escape(f.url))\\" htmlUrl=\\"\(escape(f.siteURL))\\"/>\n"
        }
        return xml + "</body></opml>\n"
    }

    static func `import`(data: Data) -> [(title: String, url: String, siteURL: String)] {
        final class D: NSObject, XMLParserDelegate {
            var out: [(String, String, String)] = []
            func parser(_ p: XMLParser, didStartElement e: String, namespaceURI: String?, qualifiedName q: String?, attributes a: [String: String] = [:]) {
                if e == "outline", let u = a["xmlUrl"], !u.isEmpty {
                    out.append((a["title"] ?? a["text"] ?? u, u, a["htmlUrl"] ?? ""))
                }
            }
        }
        let d = D(); let parser = XMLParser(data: data); parser.delegate = d; parser.parse()
        return d.out
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "\"", with: "&quot;").replacingOccurrences(of: "<", with: "&lt;")
    }
}
