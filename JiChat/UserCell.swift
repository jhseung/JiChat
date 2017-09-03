//
//  UserCell.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 22/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var profileImageView = UIImageView()
    var timeLabel = UILabel()
    var nameLabel = UILabel()
    var chatPreviewLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        profileImageView.layer.cornerRadius = 23
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.clipsToBounds = true
        
        textLabel?.font = UIFont(name: textLabel!.font.fontName, size: 17)
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 10)
        timeLabel.textColor = .darkGray
        timeLabel.numberOfLines = 0
        timeLabel.textAlignment = .right
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        chatPreviewLabel.font = UIFont.systemFont(ofSize: 12)
        chatPreviewLabel.textColor = UIColor(r: 150, g: 150, b: 150)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(nameLabel)
        addSubview(chatPreviewLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 46).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 13).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        chatPreviewLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: 0).isActive = true
        chatPreviewLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        chatPreviewLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        chatPreviewLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        chatPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        
//        textLabel?.frame.origin.x = 80
//        textLabel?.frame = CGRect(x: 80, y: 10, width: self.frame.width - 150, height: self.frame.height / 2)
//        textLabel?.frame.origin.y = (textLabel?.frame.origin.y)! - 3
//        detailTextLabel?.frame.origin.y = (detailTextLabel?.frame.origin.y)! + 2
//        detailTextLabel?.frame.origin.x = (textLabel?.frame.origin.x)!
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        timeLabel.text = nil
        chatPreviewLabel.text = nil
        nameLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
