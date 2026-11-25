import Foundation

struct ParsedArticle: Identifiable {
    let id = UUID()
    var title = "", link = "", summary = "", content = "", author = ""
    var publishedAt = Date()
}

/// RSS 2.0 / Atom 解析（Foundation XMLParser，无第三方库）
final class RSSParser: NSObject, XMLParserDelegate {
    private var items: [ParsedArticle] = []
    private var current: ParsedArticle?
    private var currentElement = ""
    private var buffer = ""
    private var inItem = false
    private var feedTitle = ""

    func parse(data: Data) -> (title: String, articles: [ParsedArticle]) {
        items = []; feedTitle = ""
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return (feedTitle, items)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        buffer = ""
        if elementName == "item" || elementName == "entry" {
            inItem = true; current = ParsedArticle()
        }
        if elementName == "link", inItem, let href = attributeDict["href"], current?.link.isEmpty == true {
            current?.link = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) { buffer += string }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let text = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        if inItem, var c = current {
            switch elementName {
            case "title": c.title = text
            case "link": if c.link.isEmpty { c.link = text }
            case "description", "summary": c.summary = text
            case "content", "content:encoded": c.content = text
            case "author", "dc:creator": c.author = text
            case "pubDate", "published", "updated":
                c.publishedAt = RSSParser.parseDate(text) ?? Date()
            case "item", "entry":
                if !c.title.isEmpty { items.append(c) }
                inItem = false; current = nil
            default: break
            }
            current = c
        } else if elementName == "title", feedTitle.isEmpty {
            feedTitle = text
        }
        buffer = ""
    }

    static func parseDate(_ s: String) -> Date? {
        let formats = ["EEE, dd MMM yyyy HH:mm:ss zzz", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd HH:mm:ss"]
        for f in formats {
            let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
}
