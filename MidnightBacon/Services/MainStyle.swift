//
//  MainStyle.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

struct MainStyle : Style {
    let lightColor = UIColor(white: 0.96, alpha: 1.0)
    let darkColor = UIColor(white: 0.04, alpha: 1.0)
    let mediumColor = UIColor(white: 0.5, alpha: 1.0)
    let translucentDarkColor = UIColor(white: 0.04, alpha: 0.2)
    let redditOrangeColor = UIColor(0xff5700)
    let redditOrangeRedColor = UIColor(0xff4500)
    let redditUpvoteColor = UIColor(0xff8b60)
    let redditNeutralColor = UIColor(0xc6c6c6)
    let redditDownvoteColor = UIColor(0x9494ff)
    let redditLightBackgroundColor = UIColor(0xeff7ff)
    let redditHeaderColor = UIColor(0xcee3f8)
    let redditUITextColor = UIColor(0x336699)
    let scale = UIScreen.mainScreen().scale
    
    init() {
        self.dynamicType.configureGlobalAppearance(self)
    }
    
    static func configureGlobalAppearance(style: Style) {
        UIWindow.appearance().tintColor = style.redditUITextColor
        UITabBar.appearance().tintColor = style.redditUITextColor
        UINavigationBar.appearance().tintColor = style.redditUITextColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: style.redditUITextColor]
        UITextField.appearance().textColor = style.redditUITextColor
        UITableViewCell.appearance().separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        UITableViewCell.appearance().layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        UITableViewCell.appearance().preservesSuperviewLayoutMargins = false
    }
    
    func applyTo(viewController: TableViewController) {
        viewController.tableView.backgroundColor = lightColor
        viewController.tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        viewController.tableView.separatorColor = mediumColor
        viewController.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
    }
    
    func applyToTextOnlyLinkCell(cell: TextOnlyLinkCell) {
        applyToLinkCell(cell)
    }
    
    func applyToThumbnailLinkCell(cell: ThumbnailLinkCell) {
        cell.thumbnailImageView.layer.masksToBounds = true
        cell.thumbnailImageView.contentMode = .ScaleAspectFit
        cell.thumbnailImageView.layer.cornerRadius = 4.0
        cell.thumbnailImageView.layer.borderWidth = 1.0 / scale
        cell.thumbnailImageView.layer.borderColor = darkColor.colorWithAlphaComponent(0.2).CGColor
        
        applyToLinkCell(cell)
    }
    
    func applyToLinkCell(cell: LinkCell) {
        cell.styled = true
        
        cell.backgroundColor = lightColor
        cell.contentView.backgroundColor = lightColor
        cell.selectionStyle = .None
        cell.layoutMargins = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        cell.upvoteButton.setBackgroundImage(UIImage(named: "vote_up")?.tinted(mediumColor), forState: .Normal)
        
        cell.downvoteButton.setBackgroundImage(UIImage(named: "vote_down")?.tinted(mediumColor), forState: .Normal)
        
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = .ByTruncatingTail
        cell.titleLabel.textColor = darkColor
        cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        cell.commentsButton.setTitleColor(redditUITextColor, forState: .Normal)
        cell.commentsButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        cell.commentsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        cell.authorLabel.textColor = mediumColor
        cell.authorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        cell.authorLabel.lineBreakMode = .ByTruncatingTail
    }
}
