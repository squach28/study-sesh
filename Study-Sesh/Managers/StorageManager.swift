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
    @Published var songs: [Song] = [Song]()
    @Published var images: [String] = [String]()
    @Published var videos: [String] = [String]()
    
    init() {
        fetchImages()
        fetchSongs()
        fetchVideos()
    }
    
    // Fetches the songs from the database
    // Stores the download URLs into songs variable
    // TODO: make custom class that stores download URLs and metadata for song name and artist 
    func fetchSongs() {
        let storageRef = storage.reference()
        let songsRef = storageRef.child("songs")
        songsRef.listAll(completion: { result, error in
            if let error = error {
                print("Error getting all items: \(error)")
            }
            
            for reference in result.items {
                var url = ""
                var song = ""
                var artist = ""
                reference.downloadURL(completion: { downloadURL, error in
                    if let error = error {
                        print("Error getting download URLs: \(error)")
                        return
                    }
                    
                    guard let urlAsString = downloadURL?.absoluteString else {
                        return
                    }
                    url = urlAsString
                    
                    reference.getMetadata(completion: { metadata, error in
                        if let error = error {
                            print("Error getting metadata: \(error)")
                        }
                        
                        guard let songMetadata = metadata?.customMetadata else {
                            return
                        }
                        print("song metadata: \(songMetadata)")
                        print("song: \(songMetadata["song"] ?? "empty")")
                        song = songMetadata["song"] ?? ""
                        artist = songMetadata["artist"] ?? ""
                        let songInfo = Song(song: song, artist: artist, downloadURL: url)
                        self.songs.append(songInfo)
                    })

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
                        print("Error getting download URLs: \(error)")
                    }
                    guard let urlAsString = downloadURL?.absoluteString else { return }
                    self.videos.append(urlAsString)
                })
            }
            
        })
    }
    
    
}
