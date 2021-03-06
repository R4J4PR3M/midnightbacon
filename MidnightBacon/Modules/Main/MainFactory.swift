//
//  MainFactory.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import FranticApparatus
import FieryCrucible
import WebKit
import Common
import Reddit
import SafariServices

class MainFactory : DependencyFactory {
    func logger() -> Logger {
        return shared(
            "logger",
            factory: Logger(level: .Debug)
        )
    }
    
    func mainFlowController() -> MainFlowController {
        return shared(
            "mainFlowController",
            factory: MainFlowController(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func oauthFlowController() -> OAuthFlowController {
        return scoped(
            "oauthFlowController",
            factory: OAuthFlowController(),
            configure: { instance in
                instance.factory = self
                instance.redditRequest = self.redditRequest()
                instance.gateway = self.gateway()
                instance.secureStore = self.secureStore()
                instance.insecureStore = self.insecureStore()
                instance.logger = self.logger()
            }
        )
    }
    
    func debugFlowController() -> DebugFlowController {
        return scoped(
            "debugFlowController",
            factory: DebugFlowController(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func subredditsFlowController() -> SubredditsFlowController {
        return shared(
            "subredditsFlowController",
            factory: SubredditsFlowController(),
            configure: { instance in
                instance.factory = self
            }
        )
    }
    
    func messagesFlowController() -> MessagesFlowController {
        return shared(
            "messagesFlowController",
            factory: MessagesFlowController(),
            configure: { instance in
            }
        )
    }
    
    func linksViewController(title title: String, path: String) -> LinksViewController {
        return scoped(
            "linksViewController",
            factory: LinksViewController(),
            configure: { instance in
                instance.style = self.style()
                instance.title = title
                instance.dataController = self.linksDataController(path)
                instance.dataController.delegate = instance
            }
        )
    }
    
    func linksDataController(path: String) -> LinksDataController {
        return unshared(
            "linksDataController",
            factory: LinksDataController(),
            configure: { instance in
                instance.redditRequest = self.redditRequest()
                instance.thumbnailService = self.thumbnailService()
                instance.path = path
                instance.gateway = self.gateway()
                instance.oauthService = self.oauthService()
            }
        )
    }
    
    func readLinkViewController(link: Link) -> SFSafariViewController {
        return scoped(
            SFSafariViewController(URL: link.url, entersReaderIfAvailable: false),
            configure: { instance in
            }
        )
    }
    
    func readCommentsViewController(link: Link) -> WebViewController {
        return scoped(
            "readCommentsViewController",
            factory: WebViewController(),
            configure: { instance in
                instance.style = self.style()
                instance.title = "Comments"
                instance.url = NSURL(string: "http://reddit.com/comments/\(link.id)")
                instance.webViewConfiguration = self.webViewConfiguration()
            }
        )
    }
    
    func accountsFlowController() -> AccountsFlowController {
        return shared(
            "accountsFlowController",
            factory: AccountsFlowController(dataController: accountsDataController()),
            configure: { instance in
                instance.factory = self
                instance.oauthService = self.oauthService()
            }
        )
    }

    func accountsDataController() -> AccountsDataController {
        return scoped(
            AccountsDataController(
                insecureStore: insecureStore(),
                secureStore: secureStore()
            ),
            configure: { instance in
                instance.delegate = self.accountsFlowController()
            }
        )
    }
    
    func mainWindow() -> UIWindow {
        return shared(
            "mainWinow",
            factory: UIWindow(frame: UIScreen.mainScreen().bounds)
        )
    }
    
    func style() -> Style {
        return weakShared(
            "style",
            factory: MainStyle()
        )
    }
    
    func sessionConfiguration() -> NSURLSessionConfiguration {
        return unshared(
            "sessionConfiguration",
            factory: NSURLSessionConfiguration.defaultSessionConfiguration().noCookies()
        )
    }
    
    func sessionPromiseDelegate() -> RedditURLSessionDataDelegate {
        return unshared(
            "sessionPromiseDelegate",
            factory: RedditURLSessionDataDelegate()
        )
    }
    
    func sessionPromiseFactory() -> NSURLSession {
        return unshared(
            "sessionPromiseFactory",
            factory: NSURLSession(configuration: sessionConfiguration(), delegate: sessionPromiseDelegate(), delegateQueue: NSOperationQueue())
        )
    }
    
    func mapperFactory() -> RedditFactory {
        return unshared(
            "redditFactory",
            factory: RedditFactory()
        )
    }
    
    func bundleInfo() -> iOSBundleInfo {
        return shared(MainBundleInfo())
    }
    
    func clientID() -> String {
        return shared(bundleInfo().clientID)
    }
    
    func userAgent() -> String {
        return shared(bundleInfo().userAgent)
    }
    
    func redirectURI() -> NSURL {
        return shared(NSURL(string: bundleInfo().redirectURI)!)
    }
    
    func redditRequest() -> RedditRequest {
        return shared(
            "redditRequest",
            factory: RedditRequest(clientID: clientID(), redirectURI: redirectURI()),
            configure: { (instance) in
                instance.tokenPrototype = self.tokenPrototype()
                instance.oauthPrototype = self.oauthPrototype()
            }
        )
    }
    
    func tokenURL() -> NSURL {
        return unshared(
            "tokenURL",
            factory: NSURL(string: "https://www.reddit.com")!
        )
    }
    
    func tokenPrototype() -> NSURLRequest {
        return unshared(
            "tokenPrototype",
            factory: NSMutableURLRequest(URL: tokenURL())
        )
    }

    func oauthURL() -> NSURL {
        return unshared(
            "oauthURL",
            factory: NSURL(string: "https://oauth.reddit.com")!
        )
    }
    
    func oauthPrototype() -> NSURLRequest {
        return unshared(
            "oauthPrototype",
            factory: NSMutableURLRequest(URL: oauthURL())
        )
    }

    func gateway() -> Gateway {
        return shared(
            "gateway",
            factory: Reddit(
                userAgent: userAgent(),
                factory: sessionPromiseFactory(),
                parseQueue: parseQueue()
            ),
            configure: { instance in
                instance.logger = self.logger()
            }
        )
    }
    
    func parseQueue() -> DispatchQueue {
        return weakShared(
            "parseQueue",
            factory: GCDQueue.globalPriorityDefault()
        )
    }
    
    func secureStore() -> SecureStore {
        return shared(
            "secureStore",
            factory: KeychainStore()
        )
    }
    
    func insecureStore() -> InsecureStore {
        return shared(
            "insecureStore",
            factory: UserDefaultsStore()
        )
    }
    
    func presenter() -> Presenter {
        return shared(
            "presenter",
            factory: PresenterService(window: mainWindow())
        )
    }
    
    func oauthService() -> OAuthService {
        return shared(
            "oauthService",
            factory: OAuthService(),
            configure: { instance in
                instance.redditRequest = self.redditRequest()
                instance.insecureStore = self.insecureStore()
                instance.secureStore = self.secureStore()
                instance.gateway = self.gateway()
            }
        )
    }
    
    func thumbnailService() -> ThumbnailService {
        return shared(
            "thumbnailService",
            factory: ThumbnailService(source: gateway(), style: style())
        )
    }
    
    func webViewConfiguration() -> WKWebViewConfiguration {
        return shared(
            "webViewConfiguration",
            factory: WKWebViewConfiguration(),
            configure: { instance in
                instance.processPool = WKProcessPool()
            }
        )
    }

//    func tabBarController() -> TabBarController {
//        return scoped(
//            "tabBarController",
//            factory: TabBarController(),
//            configure: { [unowned self] (instance) in
////                instance.delegate = self.mainFlow()
//                instance.viewControllers = [
//                    self.subredditsFactory().subredditsFlow().navigationController,
//                    self.tabNavigationController(self.messagesViewController()),
//                    self.accountsFactory().accountsFlow().navigationController,
//                    self.tabNavigationController(self.searchViewController()),
//                    self.tabNavigationController(self.configureViewController()),
//                ]
//            }
//        )
//    }
    
    func tabNavigationController(rootViewController: UIViewController) -> UINavigationController {
        return unshared(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: rootViewController)
        )
    }
    
    func messagesViewController() -> UIViewController {
        return scoped(
            "messagesViewController",
            factory: UIViewController(),
            configure: { instance in
                instance.title = "Messages"
                instance.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "envelope"), tag: 0)
            }
        )
    }
    
    func searchViewController() -> UIViewController {
        return scoped(
            "searchViewController",
            factory: UIViewController(),
            configure: { instance in
                instance.title = "Search"
                instance.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
            }
        )
    }
    
    func configureViewController() -> UIViewController {
        return scoped(
            "configureViewController",
            factory: UIViewController(),
            configure: { instance in
                instance.title = "Configure"
                instance.tabBarItem = UITabBarItem(title: "Configure", image: UIImage(named: "gears"), tag: 0)
            }
        )
    }

    func commentsFlowController(link: Link) -> CommentsFlowController {
        return scoped(
            "commentsFlowController",
            factory: CommentsFlowController(),
            configure: { instance in
                instance.link = link
                instance.factory = self
            }
        )
    }
    
    func commentsViewController(link: Link) -> CommentsViewController {
        return scoped(
            "commentsViewController",
            factory: CommentsViewController(),
            configure: { instance in
                instance.style = self.style()
                instance.dataController = self.commentsDataController(link)
                instance.dataController.delegate = instance
            }
        )
    }
    
    func commentsDataController(link: Link) -> CommentsDataController {
        return scoped(
            "commentsDataController",
            factory: CommentsDataController(link: link),
            configure: { instance in
                instance.redditRequest = self.redditRequest()
                instance.gateway = self.gateway()
                instance.oauthService = self.oauthService()
            }
        )
    }
}
