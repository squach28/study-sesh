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
    @Published var songs: [String] = [String]()
    @Published var images: [String] = [String]()
    @Published var videos: [String] = [String]()
    
    init() {
        fetchImages()
        fetchSongs()
        fetchVideos()
    }
    
    // Fetches the songs from the database
    // Stores the download URLs into songs variable
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
                    print("song url: \(urlAsString)")
                    self.songs.append(urlAsString)
                })
            }
        }
        )
    }
    
    // Fetches the images from the database
    // Stores the download URLS into images variable
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
                        print("Error getting download URLs: \(error)")
                    }
                    print("getting download url")
                    guard let urlAsString = downloadURL?.absoluteString else { return }
                    print("url:", urlAsString)
                    self.images.append(urlAsString)
                })
            }
            
            
        })
    }
    
    func fetchVideos() {
        let storageRef = storage.reference()
        let videosRef = storageRef.child("videos")
        videosRef.listAll(completion: { result, error in
            if let error = error {
                print("Error getting video: \(error)")
                return
            }
            
            for video in result.items {
                video.downloadURL(completion: { downloadURL, error in
                    if let error = error {
                        print("Error getting donwload URLs: \(error)")
                    }
                    guard let urlAsString = downloadURL?.absoluteString else { return }
                    self.videos.append(urlAsString)
                })
            }
            
        })
    }
    
    
}
