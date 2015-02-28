//
//  SubredditsFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/4/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import FieryCrucible

class SubredditsFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func subredditsFlow() -> SubredditsFlow {
        return shared(
            "subredditsFlow",
            factory: SubredditsFlow(),
            configure: { [unowned self] (instance) in
                instance.subredditsFactory = self
                instance.navigationController = self.tabNavigationController()
            }
        )
    }
    
    func tabNavigationController() -> UINavigationController {
        return scoped(
            "tabNavigationController",
            factory: UINavigationController(rootViewController: subredditsMenuViewController()),
            configure: { [unowned self] (instance) in
                instance.delegate = self.subredditsFlow()
            }
        )
    }
    
    func subredditsMenuViewController() -> MenuViewController {
        return scoped(
            "subredditsMenuViewController",
            factory: MenuViewController(style: .Grouped),
            configure: { [unowned self] (instance) in
                instance.menu = self.subredditsMenuBuilder().build()
                instance.style = self.sharedFactory.style()
                instance.title = "Subreddits"
                instance.tabBarItem = UITabBarItem(title: "Subreddits", image: UIImage(named: "list"), tag: 0)
                instance.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .Compose,
                    target: self.subredditsFlow(),
                    action: Selector("composeUnknownSubreddit")
                )
            }
        )
    }

    func subredditsMenuBuilder() -> SubredditsMenuBuilder {
        return unshared(
            "subredditsMenuBuilder",
            factory: SubredditsMenuBuilder(),
            configure: { [unowned self] (instance) in
                instance.actionController = self.subredditsFlow()
            }
        )
    }
    
    func linksViewController(# title: String, path: String) -> LinksViewController {
        return scoped(
            "linksViewController",
            factory: LinksViewController(),
            configure: { [unowned self] (instance) in
                instance.title = title
                instance.path = path
                instance.style = self.sharedFactory.style()
                instance.interactor = self.linksInteractor()
                instance.actionController = self.subredditsFlow()
            }
        )
    }
    
    func linksInteractor() -> LinksInteractor {
        return unshared(
            "linksInteractor",
            factory: LinksInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.sessionService = self.sharedFactory.sessionService()
                instance.thumbnailService = self.sharedFactory.thumbnailService()
            }
        )
    }
    
    func readLinkViewController(link: Link) -> WebViewController {
        return scoped(
            "readLinkViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.title = "Link"
                instance.url = link.url
            }
        )
    }
    
    func readCommentsViewController(link: Link) -> WebViewController {
        return scoped(
            "readCommentsViewController",
            factory: WebViewController(),
            configure: { [unowned self] (instance) in
                instance.style = self.sharedFactory.style()
                instance.title = "Comments"
                instance.url = NSURL(string: "http://reddit.com/comments/\(link.id)")
            }
        )
    }
}
