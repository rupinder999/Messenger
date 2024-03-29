//
//  StorageManager.swift
//  Messenger
//
//  Created by Rupinder Pal Singh on 11/11/21.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
}

extension StorageManager {
    /*
    /images/rupi-gmail-com_profile_picture.png       // format of url string that will be returned.
    */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads Picture to firebase storage and returns completion with url string to download.
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil,completion:  { metadata , error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let reference  = self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned  \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadUrl(for path: String, completion : @escaping (Result<URL,Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion:{ url , error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
}
