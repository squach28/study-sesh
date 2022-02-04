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
        // TODO: replace list with song title and artist from metadata in storage
        Text("Song Queue")
    }
}

struct SongQueueView_Previews: PreviewProvider {
    static var previews: some View {
        let storageManager = StorageManager()
        SongQueueView(storageManager: storageManager)
    }
}
