//
//  SongDetails.swift
//  Study-Sesh
//
//  Created by Sean Quach on 2/3/22.
//

import SwiftUI

struct SongDetails: View {
    var name: String
    var artist: String

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(name)
                .font(.title)
                .bold()
            
            Text(artist)
                .font(.title2)
        }
    }
}

struct SongDetails_Previews: PreviewProvider {
    static var previews: some View {
        SongDetails(name: "Nobody", artist: "Blue.D")
    }
}
