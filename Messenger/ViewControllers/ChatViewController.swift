//
//  ChatViewController.swift
//  Messenger
//
//  Created by Rupinder Pal Singh on 11/11/21.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    
    var displayName: String
    
    var photoURL: String
}

class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    
    private var selfSender = Sender(senderId: "1", displayName: "Rupinder Pal Singh", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender , messageId: "1", sentDate: Date(), kind: .text("Hello World Message")))
        
        messages.append(Message(sender: selfSender , messageId: "1", sentDate: Date(), kind: .text("Hello World Message Hello World Message Hello World Message")))
        
        view.backgroundColor = .red
         
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }


}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate  {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
