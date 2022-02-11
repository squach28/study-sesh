//
//  ContentView.swift
//  Study-Sesh
//
//  Created by Sean Quach on 1/26/22.
//

import SwiftUI
import FirebaseStorage
import AVFoundation
import AVKit


struct ContentView: View {
    
    @State var observer: NSKeyValueObservation? // observes when a song is ready to play and allows the duration to be read
    @State var isPlaying: Bool = false // boolean to check if music is playing
    @StateObject var storageManager = StorageManager()
    @State var queuePlayer = AVQueuePlayer() // takes the AVPlayer and allows it to create a queue
    @State var videoPlayer = AVPlayer() // AVPlayer that plays videos
    @State var currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // the time of the current song playing
    @State var currentItemDuration: CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // represents the duration of the current song
    @State var timeObserverToken: Any? // keeps track of the time when a song is playing
    @State var imageIndex: Int = 0 // stores index of the image in StorageManager
    @State var songIndex: Int = 0 // stores index of the song in StorageManager
    
    init() {
        // allows audio to be played in the background if app is closed
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "info.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                        })
                        Spacer()
                        NavigationLink(destination: SongQueueView(storageManager: storageManager, queuePlayer: $queuePlayer, songIndex: $songIndex)) {
                            
                            Image(systemName: "music.note.list")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                            
                        }
                    }
                    .padding()
                    
                    AsyncImage(url: URL(string: storageManager.images.isEmpty ? "" : storageManager.images[imageIndex])
                               , content: { image in image.resizable() }, placeholder: {
                        ProgressView()
                    })
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: 400, maxHeight: 400)
                        .cornerRadius(30)
                        .padding()
                        .transition(.move(edge: .leading))
                    VStack {
                        
                        
                            SongDetails(name: !storageManager.songs.isEmpty  ? storageManager.songs[songIndex].song : "" , artist: !storageManager.songs.isEmpty ? storageManager.songs[songIndex].artist : "" )
     
                        
                        AudioProgressBar(currentItemDuration: $currentItemDuration, currentTime: $currentTime)
                        
                        
                        // Audio player controls
                        HStack(spacing: 50) {
                            Button(action: {
                                if songIndex - 1 < 0 {
                                    let beginning = CMTime(value: 0, timescale: 1)
                                    queuePlayer.currentItem?.seek(to: beginning, completionHandler: nil)
                                } else {
                                    skipToPreviousSong()
                                    if imageIndex - 1 >= 0 {
                                        imageIndex -= 1
                                    }
                                    
                                }
                            }, label: {
                                Image(systemName: "backward.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            })
                                .foregroundColor(songIndex > 0 ? Color(hue: 0.775, saturation: 0.361, brightness: 0.921) : .gray)
                                .disabled(songIndex == 0)
                            
                            
                            Button(action: {
                                self.isPlaying.toggle()
                                if isPlaying {
                                    if queuePlayer.currentItem != nil {
                                        queuePlayer.play()
                                    } else {
                                        play()
                                    }
                                    
                                    
                                } else {
                                    queuePlayer.pause()
                                }
                            }, label: {
                                if isPlaying {
                                    Image(systemName: "pause.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                    
                                } else {
                                    Image(systemName: "play.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                            })
                                .foregroundColor(storageManager.songs.count > 0 ? .purple : .gray)
                                .disabled(storageManager.songs.count == 0)
                            
                            Button(action: {
                                if songIndex + 1 >= storageManager.songs.count {
                                    return
                                } else {
                                    print("skipping")
                                    skipToNextSong()
                                    if imageIndex + 1 < storageManager.images.count {
                                        imageIndex += 1
                                    }
                                    
                                }
                            }, label: {
                                Image(systemName: "forward.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            })
                                .foregroundColor(songIndex + 1 >= storageManager.songs.count ? .gray : Color(hue: 0.775, saturation: 0.361, brightness: 0.921))
                                .disabled(songIndex + 1 >= storageManager.songs.count)
                            
                        }
                        .padding(.bottom)
                        // End of Audio Player controls
                        
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
        }
        
        
        
    }
    
    // Adds an observer to the timer
    // Stores the time in currentTime
    func addPeriodicTimeObserver(player: AVPlayer) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale) // check every second for changes
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: . main) { time in
            self.currentTime = time
            
        }
    }
    
    // Skip to the previous song if it isn't the first song
    func skipToPreviousSong() {
        if songIndex - 1 >= 0 {
            songIndex -= 1
            let songURL = storageManager.songs[songIndex].downloadURL
            let previousSong = AVPlayerItem(url: URL(string: songURL)!)
            queuePlayer.replaceCurrentItem(with : previousSong)
            self.observer = queuePlayer.currentItem?.observe(\AVPlayerItem.status) { item, _ in
                guard let item = queuePlayer.currentItem else { return }
                if item.status == .readyToPlay {
                    currentItemDuration = queuePlayer.currentItem!.duration
                }
            }
        }
    }
    
    // Plays the current song
    func play() {
        addPeriodicTimeObserver(player: queuePlayer)
        let currentSong = AVPlayerItem(url: URL(string: storageManager.songs[songIndex].downloadURL)!)
        queuePlayer.replaceCurrentItem(with: currentSong)
        self.observer = queuePlayer.currentItem?.observe(\AVPlayerItem.status) { item, _ in
            guard let item = queuePlayer.currentItem else { return }
            if item.status == .readyToPlay {
                currentItemDuration = queuePlayer.currentItem!.duration
            }
        }
        queuePlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        queuePlayer.play()
        
    }
    
    // Skips to the next song if it isn't the last song
    func skipToNextSong() {
        if songIndex + 1 < storageManager.songs.count {
            songIndex += 1
            let songURL = storageManager.songs[songIndex]
            let nextSong = AVPlayerItem(url: URL(string: songURL.downloadURL)!)
            queuePlayer.replaceCurrentItem(with : nextSong)
            self.observer = queuePlayer.currentItem?.observe(\AVPlayerItem.status) { item, _ in
                guard let item = queuePlayer.currentItem else { return }
                if item.status == .readyToPlay {
                    currentItemDuration = queuePlayer.currentItem!.duration
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
