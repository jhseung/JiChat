//
//  ChatCollectionViewCell.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 26/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import Foundation
import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    
    var chatView: UIView!
    var chatTextView: UITextView!
    var timeLabel: UILabel!
    var profileImageView: UIImageView!
    
    var chatViewWidthAnchor: NSLayoutConstraint!
    var chatViewLeftAnchor: NSLayoutConstraint!
    var chatViewRightAnchor: NSLayoutConstraint!
    var chatTextViewLeftAnchor: NSLayoutConstraint!
    var chatTextViewRightAnchor: NSLayoutConstraint!
    var timeLabelLeftAnchor: NSLayoutConstraint!
    var timeLabelRightAnchor: NSLayoutConstraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chatView = UIView()
        chatTextView = UITextView()
        timeLabel = UILabel()
        profileImageView = UIImageView()
        
        addSubview(chatTextView)
        addSubview(chatView)
        addSubview(timeLabel)
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        chatView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        chatViewWidthAnchor = chatView.widthAnchor.constraint(equalToConstant: 200)
        chatViewWidthAnchor.isActive = true
        chatViewLeftAnchor = chatView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10)
        chatViewRightAnchor = chatView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        
        chatTextViewLeftAnchor = chatTextView.leftAnchor.constraint(equalTo: chatView.leftAnchor, constant: 0)
        chatTextViewRightAnchor = chatTextView.rightAnchor.constraint(equalTo: chatView.rightAnchor, constant: 0)
        chatTextView.widthAnchor.constraint(equalTo: chatView.widthAnchor, constant: -10).isActive = true
        chatTextView.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 5).isActive = true
        
        timeLabelLeftAnchor = timeLabel.leftAnchor.constraint(equalTo: chatView.rightAnchor, constant: -2)
        timeLabelRightAnchor = timeLabel.rightAnchor.constraint(equalTo: chatView.leftAnchor, constant: -2)
        timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        timeLabel.font = UIFont.systemFont(ofSize: 8)
        timeLabel.textColor = UIColor(r: 100, g: 100, b: 100)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        chatTextView.layer.cornerRadius = 10
        chatTextView.clipsToBounds = true
        chatTextView.font = UIFont.systemFont(ofSize: 16)
        chatTextView.isScrollEnabled = false
        chatTextView.contentInset = UIEdgeInsetsMake(0, 2, 0, 0)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        chatTextView = nil
//        chatView = nil
//        
//        chatView = UIView()
//        chatTextView = UITextView()
//    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
