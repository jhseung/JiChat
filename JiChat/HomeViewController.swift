//
//  HomeViewController.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 21/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON

class HomeViewController: UITableViewController {

    var logoutButton: UIButton!
    var newButton: UIButton!
    var currentUser: User!
    let reuse = "reuse"
    
    var messages = [Message]()
    var latestMessages = [String: Message]()
    var users = [String: User]()
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuse)
        tableView.rowHeight = 80
        
        logoutButton = UIButton(frame: CGRect(x: 9, y: 9, width: 60, height: 25))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.titleLabel?.textAlignment = .left
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        
        newButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        newButton.setImage(#imageLiteral(resourceName: "001-new-file"), for: .normal)
        newButton.addTarget(self, action: #selector(newButtonPressed), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newButton)

    }

    override func viewDidAppear(_ animated: Bool) {
        checkLoginStatus()
    }
    
    func newButtonPressed() {
        
        let contactsViewController = ContactsViewController()
        contactsViewController.homeViewController = self
        present(UINavigationController(rootViewController: contactsViewController), animated: true, completion: nil)
        
    }
    
    func checkLoginStatus() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(logoutButtonPressed), with: nil, afterDelay: 0)
        } else {
            
            // Get information about current user
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dic = snapshot.value as? [String: Any] {
                        self.navigationItem.title = dic["name"] as? String
                        self.currentUser = User(email: dic["email"] as! String?, name: dic["name"] as! String?, imageURL: dic["imageURL"] as! String?, uid: snapshot.key)
                    }
                    
                }, withCancel: nil)
                
                
                // Get chat logs that involve current user
                
                FIRDatabase.database().reference().child("userMessageReference").child(uid).observe(.childAdded, with: { (snapshot) in
                    self.dispatchGroup.enter()
                    let messageReferenceNumber = snapshot.key
                    
                        FIRDatabase.database().reference().child("chatLog").child(messageReferenceNumber).observe(.value, with: { (snapshot) in
                    
                            if let dic = snapshot.value as? [String: Any] {
                                let message = Message()
                                message.text = dic["text"] as? String
                                message.receiveruid = dic["receivinguid"] as? String
                                message.senderuid = dic["sendinguid"] as? String
                                message.time = dic["time"] as? NSNumber
                                
                                let uid = self.getMessageReceipientUseruid(message: message)
                                self.latestMessages[uid] = message
                                self.messages = Array(self.latestMessages.values)
                                self.messages.sort(by: { (msg1, msg2) -> Bool in
                                    return msg1.time.intValue > msg2.time.intValue
                                })
                            }
                            
                            self.dispatchGroup.leave()
                            
                            self.dispatchGroup.notify(queue: .main, execute: { 
                                self.tableView.reloadData()

                            })
                        })
                    }
                )
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages.count != 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath) as? UserCell {
                
                let correctUseruid = getMessageReceipientUseruid(message: messages[indexPath.row])
                
                FIRDatabase.database().reference().child("users").child(correctUseruid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dic = snapshot.value as? [String: Any] {
                        cell.chatPreviewLabel.text = self.messages[indexPath.row].text
                        cell.timeLabel.text = self.setupTime(time: self.messages[indexPath.row].time)
                        
                        cell.profileImageView.af_setImage(withURL: URL(string: dic["imageURL"] as! String)!)
                        cell.nameLabel.text = dic["name"] as? String
                        
                        let user = User(email: dic["email"] as! String?, name: dic["name"] as! String?, imageURL: dic["imageURL"] as! String?, uid: snapshot.key)
                        self.users.updateValue(user, forKey: snapshot.key)
                    }
                }, withCancel: nil)
            
            return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
    func logoutButtonPressed() {
        messages.removeAll()
        latestMessages.removeAll()
        tableView.reloadData()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        present(LoginViewController(), animated: true, completion: nil)
        navigationItem.title = nil
    }
        
    func setupTime(time: NSNumber) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        let calendar = NSCalendar.current
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
            let dateString = dateFormatter.string(from: date)
            return dateString
        } else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            if day < 7 {
                dateFormatter.dateFormat = "EEE"
                let dateString = dateFormatter.string(from: date)
                return dateString
            } else {
                dateFormatter.dateFormat = "MM/dd"
                let dateString = dateFormatter.string(from: date)
                return dateString
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let receivingMessageuid = getMessageReceipientUseruid(message: messages[indexPath.row])
        messages.removeAll()
        latestMessages.removeAll()
        tableView.reloadData()
        openChatController(uid: receivingMessageuid, user: nil)
        
    }
    
    func openChatController(uid: String?, user: User?) {
        
        let chatViewController = ChatViewController()
        if let unwrappeduid = uid {
            chatViewController.receivingMessageUser = self.users[unwrappeduid]
        } else {
            chatViewController.receivingMessageUser = user!
        }
        chatViewController.currentUser = self.currentUser
        navigationController?.pushViewController(chatViewController, animated: true)
        
    }
    
    func getMessageReceipientUseruid(message: Message) -> String {
        
        if message.receiveruid == self.currentUser.uid! {
            return message.senderuid
        } else {
            return message.receiveruid
        }
        
    }
    
}

