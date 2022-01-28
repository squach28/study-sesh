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
    @State var videoPlayer = AVPlayer() // AVPlayer that plays the audio files
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
        ZStack {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: storageManager.images.isEmpty ? "" : storageManager.images[imageIndex])
                           , content: { image in image.resizable() }, placeholder: {
                    ProgressView()
                })
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: 400, maxHeight: 400)
                    .cornerRadius(30)
                    .padding()
                    .animation(.easeIn, value: 1.0)
                VStack(spacing: -10) {
                    // Audio Progress Bar with current time and duration
                    // TODO: make Audio Progress Bar and current time/duration into a component that takes in a parameter: AVQueuePlayer
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(Color(hue: 0.397, saturation: 0.609, brightness: 0.888))
                            .opacity(0.3)
                            .frame(width: 325, height: 20)
                        Rectangle()
                            .foregroundColor(Color(hue: 0.381, saturation: 0.844, brightness: 0.721))
                            .frame(width: min((325 / (currentItemDuration.seconds == 0 ? 1 : currentItemDuration.seconds)) * currentTime.seconds, 325), height: 20)
                            .animation(.linear, value: 1.0)
                        
                        
                    }
                    .cornerRadius(45.0)
                    .padding()
                    // End of Audio Progress Bar
                    
                    // Current time and duration
                    HStack {
                        Text(currentItemDuration.seconds != 0 ? "\( Int(currentTime.seconds / 60)):\(String(format: "%02d", Int(currentTime.seconds.truncatingRemainder(dividingBy: 60))))" : "-:--")
                        Spacer()
                        Text(currentItemDuration.seconds != 0 ? "\( Int(currentItemDuration.seconds / 60)):\(String(format: "%02d", Int(currentItemDuration.seconds.truncatingRemainder(dividingBy: 60))))" : "-:--")
                    }
                    .padding()
                    
                    // End of current time and duration
                }
                
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
                        .foregroundColor(Color(hue: 0.397, saturation: 0.728, brightness: 0.809))
                    
                    
                    Button(action: {
                        self.isPlaying.toggle()
                        if isPlaying {
                            if queuePlayer.currentItem != nil {
                                queuePlayer.play()
                            } else {
                                onComplete()
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
                        .foregroundColor(Color(hue: 0.381, saturation: 0.844, brightness: 0.721))
                    
                    Button(action: {
                        if queuePlayer.items().count == 1 {
                            return
                        } else {
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
                        .foregroundColor(Color(hue: 0.397, saturation: 0.728, brightness: 0.809))
                    
                }
                .padding(.bottom)
                // End of Audio Player controls
                
                
            }
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
            let songURL = storageManager.songs[songIndex]
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
    // TODO: change method function from onComplete() to play()
    // TODO: remove adding songs to queue; handled by tracking songIndex
    func onComplete() {
        addPeriodicTimeObserver(player: queuePlayer)
        
        for song in storageManager.songs {
            let songURL = URL(string: song)!
            let item = AVPlayerItem(url: songURL)
            self.queuePlayer.insert(item, after: nil)
            
        }
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
            let nextSong = AVPlayerItem(url: URL(string: songURL)!)
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
