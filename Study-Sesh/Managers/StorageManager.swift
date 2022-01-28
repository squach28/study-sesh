//
//  StorageManager.swift
//  Study-Sesh
//
//  Created by Sean Quach on 1/26/22.
//

import Foundation
import FirebaseStorage

class StorageManager: ObservableObject {
    let storage = Storage.storage()
    @Published var url: String? = ""
    @Published var songs: [String] = [String]()
    @Published var images: [String] = [String]()
    
    init() {
        fetchImages()
        fetchSongs()
    }
    
    func fetchSongs() {
        let storageRef = storage.reference()
        let songsRef = storageRef.child("songs")
        songsRef.listAll(completion: { result, error in
            if let error = error {
                print("Error getting all items: \(error)")
            }
            
            for reference in result.items {
                reference.downloadURL(completion: { downloadURL, error in
                    if let error = error {
                        print("Error getting download URLs \(error)")
                        return
                    }
                    
                    guard let urlAsString = downloadURL?.absoluteString else {
                        return
                    }
                    self.songs.append(urlAsString)
                })
            }
        }
        )
    }
    
    func fetchImages() {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images")
        imagesRef.listAll(completion: { result, error in
            if let error = error {
                print("Error getting images: \(error)")
                return
            }
            
            for reference in result.items {
                reference.downloadURL(completion: { downloadURL, error in
                    if let error = error {
                        print("Error getting download URLs \(error)")
                    }
                    print("getting download url")
                    guard let urlAsString = downloadURL?.absoluteString else { return }
                    print("url:", urlAsString)
                    self.images.append(urlAsString)
                })
            }
            
            
        })
    }
    
    
}
