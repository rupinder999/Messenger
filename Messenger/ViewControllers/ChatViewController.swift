//
//  ChatViewController.swift
//  Messenger
//
//  Created by Rupinder Pal Singh on 11/11/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
   public var senderId: String
    
   public var displayName: String
    
   public var photoURL: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()

    public var isNewConevsation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(senderId: email, displayName: "Rupinder Pal Singh", photoURL: "")
    }
    
    
    init(with email: String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
         
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId() else {
            return
        } 
        print("sending \(text)")
        
        //send message
        if isNewConevsation {
            // create new convo
            let message = Message(sender:selfSender , messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message , completion: { success in
                if success {
                    print("successfully send messages")
                }
                else {
                    print("failed to send message")
                }
            })
        }
        else {
            // append to existing data
        }
    }
    
    private func createMessageId() -> String? {
        //date , otheruseremail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate  {
    func currentSender() -> SenderType {
        if let sender = selfSender  {
            return sender
        }
        fatalError("selfSender is nil , email should be cached")
        return Sender(senderId: "12", displayName: "", photoURL: "" )
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
