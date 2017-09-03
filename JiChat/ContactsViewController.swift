//
//  ContactsViewController.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 21/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire
import AlamofireImage

class ContactsViewController: UITableViewController {

    let reuse = "reuse"
    var users = [User]()
    var homeViewController = HomeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuse)
        tableView.rowHeight = 60
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        
        navigationItem.addImageAndName(name: homeViewController.currentUser.name!, imageURL: homeViewController.currentUser.imageURL!)
        
        getUser()
    }
    
    func getUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dic = snapshot.value as? [String: Any] {
                if snapshot.key != self.homeViewController.currentUser.uid! {
                    let user = User(email: dic["email"] as! String?, name: dic["name"] as! String?, imageURL: dic["imageURL"] as! String?, uid: snapshot.key)
                    
                    self.users.append(user)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func backButtonPressed() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        
        if let url = user.imageURL {
            cell.profileImageView.af_setImage(withURL: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profileicon"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: { (response) in
                if response.error != nil {
                    print(response.error!)
                }
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.dismiss(animated: true) {
            self.homeViewController.openChatController(uid: nil, user: user)
        }
    }
    
}
