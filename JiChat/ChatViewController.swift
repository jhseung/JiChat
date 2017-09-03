//
//  ChatViewController.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 24/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class ChatViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let chatTextField = UITextField()
    var receivingMessageUser: User!
    var currentUser: User!
    let reuse = "reuse"
    
    var chatLog = [Message]()
    
    var chatCollectionView: UICollectionView!
    
    let dispatchGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        
        chatCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        chatCollectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: reuse)
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatCollectionView.backgroundColor = .white
        chatCollectionView.alwaysBounceVertical = true
        chatCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        
        view.addSubview(chatCollectionView)
        fetchMessagesFromDatabase()
        setupItems()
    }
    
    func setupItems() {
        
        let bottomBarView = UIView()
        let sendButton = UIButton()
        let dividerLine = UIView()
        
        // Set up name & image at the top
        navigationItem.addImageAndName(name: receivingMessageUser.name!, imageURL: receivingMessageUser.imageURL)
        
        // Set up bottom bar that includes textfield & send butotn
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(sendButton)
        bottomBarView.addSubview(chatTextField)
        bottomBarView.addSubview(dividerLine)
        
        bottomBarView.frame = CGRect(x: 0, y: self.view.frame.height - 40, width: self.view.frame.width, height: 40)
        bottomBarView.backgroundColor = UIColor(r: 200, g: 200, b: 200)
        
        bottomBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bottomBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bottomBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bottomBarView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        
        sendButton.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -4).isActive = true
        sendButton.topAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: 4).isActive = true
        sendButton.rightAnchor.constraint(equalTo: bottomBarView.rightAnchor, constant: -4).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        chatTextField.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -4).isActive = true
        chatTextField.topAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: 4).isActive = true
        chatTextField.leftAnchor.constraint(equalTo: bottomBarView.leftAnchor, constant: 30).isActive = true
        chatTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10).isActive = true
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = UIColor(r: 100, g: 100, b: 100)
        
        chatTextField.placeholder = "Enter message..."
        chatTextField.delegate = self
        chatTextField.setLeftPaddingPoints(10)
        chatTextField.layer.borderWidth = 0.3
        chatTextField.layer.borderColor = UIColor(r: 230, g: 230, b: 230).cgColor
        chatTextField.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        chatTextField.font = UIFont.systemFont(ofSize: 15)
        chatTextField.layer.cornerRadius = 5
        
        dividerLine.topAnchor.constraint(equalTo: bottomBarView.topAnchor).isActive = true
        dividerLine.leftAnchor.constraint(equalTo: bottomBarView.leftAnchor).isActive = true
        dividerLine.widthAnchor.constraint(equalTo: bottomBarView.widthAnchor).isActive = true
        
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        chatTextField.translatesAutoresizingMaskIntoConstraints = false
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func fetchMessagesFromDatabase() {
        
        let ref = FIRDatabase.database().reference().child("userMessageReference").child(self.currentUser.uid!)
        let messageRef = FIRDatabase.database().reference().child("chatLog")
        
        // Observe all messages in the database that is under the node of the current user's uid
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            // Enter dispatchgroup for every message that the app observes
            self.dispatchGroup.enter()
            
            // Observe details about the messages
            messageRef.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dic = snapshot.value as? [String: Any] else { return }
                let message = Message()
                message.text = dic["text"] as? String
                message.receiveruid = dic["receivinguid"] as? String
                message.senderuid = dic["sendinguid"] as? String
                message.time = dic["time"] as? NSNumber
                
                if (message.receiveruid == self.currentUser.uid && message.senderuid == self.receivingMessageUser.uid!) || (message.receiveruid == self.receivingMessageUser.uid! && message.senderuid == self.currentUser.uid) {
                    self.chatLog.append(message)
                }
                
                // Exit dispatch group for every message, and once dispatchGroup is completed, reload data
                self.dispatchGroup.leave()
                self.dispatchGroup.notify(queue: .main, execute: {
                    self.chatCollectionView.reloadData()
                    if self.chatLog.count != 0 {
                        self.scrollToBottom()
                    }
                })
            })
        }, withCancel: nil)
    }
    
    func sendButtonPressed() {
        
        if self.chatTextField.text == nil {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("chatLog")
        let childRef = ref.childByAutoId()
        let currentTime = NSNumber(integerLiteral: Int(NSDate().timeIntervalSince1970))
        
        let userMessageReference = FIRDatabase.database().reference().child("userMessageReference")
        
        let values: [String: Any] = ["text": self.chatTextField.text!, "receivinguid": self.receivingMessageUser.uid!, "sendinguid": self.currentUser.uid!, "time": currentTime]
        
        childRef.updateChildValues(values) { (error, reference) in
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                userMessageReference.child(self.currentUser.uid!).updateChildValues([snapshot.key: 1])
                userMessageReference.child(self.receivingMessageUser.uid!).updateChildValues([snapshot.key: 1])
            })
        }
        
        chatTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatLog.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as? ChatCollectionViewCell {
            
            // Set up cell depending on whether message is sent by user or not
            let time = chatLog[indexPath.row].time
            let timeString = setupTime(time: time!)
            let imageURL = receivingMessageUser.imageURL!
            
            if self.chatLog[indexPath.row].senderuid != self.currentUser.uid {

                cell.chatViewLeftAnchor.isActive = true
                cell.timeLabelLeftAnchor.isActive = true
                cell.chatTextViewLeftAnchor.isActive = true
                cell.timeLabelRightAnchor.isActive = false
                cell.chatViewRightAnchor.isActive = false
                cell.chatTextView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
                cell.chatTextView.textColor = .black
            } else {
                
                cell.profileImageView.isHidden = true
                cell.chatViewRightAnchor.isActive = true
                cell.timeLabelRightAnchor.isActive = true
                cell.chatTextViewRightAnchor.isActive = true
                cell.timeLabelLeftAnchor.isActive = false
                cell.chatViewLeftAnchor.isActive = false
                cell.chatTextViewLeftAnchor.isActive = false
                cell.chatTextView.backgroundColor = UIColor(r: 50, g: 50, b: 50)
                cell.chatTextView.textColor = .white
            }
            
            let text = self.chatLog[indexPath.row].text
            cell.chatTextView.text = text
            cell.timeLabel.text = timeString
            cell.profileImageView.af_setImage(withURL: URL(string: imageURL)!)
            cell.chatViewWidthAnchor.constant = (text?.widthHeight(font: UIFont.systemFont(ofSize: 16)).width)! + 32
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let text = self.chatLog[indexPath.row].text {
            let box = text.widthHeight(font: UIFont.systemFont(ofSize: 16))
            return CGSize(width: view.frame.width, height: box.height + 15)
        }
        return CGSize(width: self.view.frame.width, height: 60)
    }
    
    func scrollToBottom() {
        let section = 0
        let lastIndex = self.chatCollectionView.numberOfItems(inSection: section) - 1
        let indexPath = IndexPath(item: lastIndex, section: section)
        self.chatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    func setupTime(time: NSNumber) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}
