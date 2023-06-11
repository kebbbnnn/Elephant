//
//  Created by Timur Bernikovich on 07/03/2019.
//  Copyright © 2019 Timur Bernikovich. All rights reserved.
//
import WebKit
import UIKit

public protocol WarmUpable {
    func warmUp()
}

public class WarmUper<Object: WarmUpable> {
    
    private let creationClosure: () -> Object
    private var warmedUpObjects: [Object] = []
    
    public var numberOfWamedUpObjects: Int = 30 {
        didSet {
            self.prepare()
        }
    }
    
    public init(creationClosure: @escaping () -> Object) {
        self.creationClosure = creationClosure
        prepare()
    }
    
    public func prepare() {
        while warmedUpObjects.count < self.numberOfWamedUpObjects {
            let object = self.creationClosure()
            object.warmUp()
            self.warmedUpObjects.append(object)
        }
    }
    
    public func enqueue(_ cleanupBlock: () -> Object) {
        let object = cleanupBlock()
        self.warmedUpObjects.append(object)
    }
    
    private func createObjectAndWarmUp() -> Object {
        let object = self.creationClosure()
        object.warmUp()
        return object
    }
    
    public func dequeue() -> Object {
        let warmedUpObject: Object
        if let object = self.warmedUpObjects.first {
            self.warmedUpObjects.removeFirst()
            warmedUpObject = object
        } else {
            warmedUpObject = self.createObjectAndWarmUp()
        }
        self.prepare()
        return warmedUpObject
    }
    
}

fileprivate let htmlString = """
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      background-color: transparent;
    }
  </style>
</head>
<body>
</body>
</html>
"""

extension WKWebView: WarmUpable {
    public func warmUp() {
        loadHTMLString(htmlString, baseURL: nil)
    }
}

public typealias WKWebViewWarmUper = WarmUper<WKWebView>

fileprivate let configuration = WKWebViewConfiguration()

public extension WarmUper where Object == WKWebView {
    static let shared = WKWebViewWarmUper(creationClosure: {
        WKWebView(frame: .zero, configuration: configuration)
    })
}
