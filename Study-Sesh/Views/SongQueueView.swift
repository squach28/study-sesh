//
//  SongQueueView.swift
//  Study-Sesh
//
//  Created by Sean Quach on 2/1/22.
//

import SwiftUI
import AVFoundation

struct SongQueueView: View {
    
    @StateObject var storageManager: StorageManager
    @Binding var queuePlayer: AVQueuePlayer
    @Binding var songIndex: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Now Playing")
                    .font(.title)
                    .bold()
                    .padding()
                SongListItem(name: storageManager.songs[songIndex].song, artist: storageManager.songs[songIndex].artist)
                
                Text("Next in queue")
                        .font(.title)
                        .bold()
                        .padding()
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(storageManager.songs[songIndex + 1..<storageManager.songs.count], id: \.self) { song in
                        SongListItem(name: song.song, artist: song.artist)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
  
        
        
    }
}




