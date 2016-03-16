//: Playground - noun: a place where people can play

import Foundation

let str = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("in", ofType: "txt")!, encoding: NSUTF8StringEncoding)

let scanner = NSScanner(string: str as String)

let end = NSMutableString()
end.appendString("[")

var s:NSString?
while scanner.scanUpToString("let ", intoString: nil) {
    scanner.scanUpToString(":", intoString: &s)
    s = s?.substringFromIndex("let ".characters.count)
    end.appendString(s as! String)
    end.appendString(", ")
}

print(end)
