//
//  SongQueueView.swift
//  Study-Sesh
//
//  Created by Sean Quach on 2/1/22.
//

import SwiftUI

struct SongQueueView: View {
    
    @StateObject var storageManager: StorageManager

    
    var body: some View {
        List(storageManager.songs, id: \.self) { song in
            Text(song)
        }
    }
}

struct SongQueueView_Previews: PreviewProvider {
    static var previews: some View {
        let storageManager = StorageManager()
        SongQueueView(storageManager: storageManager)
    }
}
