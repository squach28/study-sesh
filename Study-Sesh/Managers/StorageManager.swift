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
    
    init() {
        fetchSongs()
    }
    
    func fetchSong(onComplete: @escaping (String) -> ()) {
        let pathReference = storage.reference(forURL: "gs://study-sesh-15612.appspot.com/songs/유키카 YUKIKA - 03. 「서울여자 SOUL LADY」 (Official Audio).mp3")
        
        pathReference.downloadURL(completion: { downloadURL, error in
            if let error = error {
                print("Error getting download URL \(error)")
            } else {
                guard let url = downloadURL?.absoluteString else { return }
                onComplete(url)
                
            }
        })
        
        print(self.songs)
        
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
    
    
}
