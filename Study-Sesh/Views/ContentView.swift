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
    
    init() {
        print("current time: \(currentTime.seconds)")
        print("current time duration: \(currentItemDuration.seconds)")
        print(abs(min((325 / currentItemDuration.seconds) * currentTime.seconds, 325)))
    }
    
    @State var observer: NSKeyValueObservation?
    let storage = Storage.storage()
    @State var isPlaying: Bool = false
    @StateObject var storageManager = StorageManager()
    @State var queuePlayer = AVQueuePlayer()
    @State var videoPlayer = AVPlayer()
    @State var currentItemDuration: CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    @State var timeObserverToken: Any?
    @State var currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    @State var previousSong: AVPlayerItem?
    
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 50) {
                    
                    Button(action: {
                        if previousSong == nil {
                            let beginning = CMTime(value: 0, timescale: 1)
                            queuePlayer.currentItem?.seek(to: beginning, completionHandler: nil)
                        } else {
                            queuePlayer.replaceCurrentItem(with: previousSong)
                        }
                    }, label: {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    })
                
                
                    Button(action: {
                        self.isPlaying.toggle()
                        if isPlaying {
                            if queuePlayer.currentItem != nil {
                                queuePlayer.play()
                            } else {
                                storageManager.fetchSong(onComplete: onComplete)
                                print("songs:", storageManager.songs)
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
                    
                    Button(action: {
                        guard let previous = queuePlayer.currentItem?.asset else { return }
                        self.previousSong = AVPlayerItem(asset: previous)
                        skipToNextSong()
                    }, label: {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    })
                    
                }
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 325, height: 20)
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: min((325 / (currentItemDuration.seconds == 0 ? 1 : currentItemDuration.seconds)) * currentTime.seconds, 325), height: 20)
                        .animation(.linear, value: 1.0)
                    
                    
                }
                .cornerRadius(45.0)
                .padding()
                
                HStack(spacing: 20) {
                    Text("\( Int(currentTime.seconds / 60)):\(String(format: "%02d", Int(currentTime.seconds.truncatingRemainder(dividingBy: 60))))")
                    Spacer()
                    Text("\( Int(currentItemDuration.seconds / 60)):\(String(format: "%02d", Int(currentItemDuration.seconds.truncatingRemainder(dividingBy: 60))))")
                }
                .padding()

            }
        }
        
    }
    
    func onComplete(url: String) {

        queuePlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
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
        
        queuePlayer.play()

    }
    
    func addPeriodicTimeObserver(player: AVPlayer) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: . main) { time in
            self.currentTime = time
            print(abs(min((325 / currentItemDuration.seconds) * currentTime.seconds, 325)))
           
        }
    }
    
    func skipToNextSong() {
        queuePlayer.advanceToNextItem()
        self.observer = queuePlayer.currentItem?.observe(\AVPlayerItem.status) { item, _ in
            guard let item = queuePlayer.currentItem else { return }
            if item.status == .readyToPlay {
                currentItemDuration = queuePlayer.currentItem!.duration
            }
        }
    }
    
    func getProgressBarWidth(seconds: Int) -> Int {
        return  325 / seconds
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
