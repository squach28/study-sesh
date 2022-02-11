//
//  SongListItem.swift
//  Study-Sesh
//
//  Created by Sean Quach on 2/11/22.
//

import SwiftUI

struct SongListItem: View {
    var name: String
    var artist: String
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color("Gray"))
                .shadow(radius: 1.0)
                .frame(maxWidth:.infinity, maxHeight: 100)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title)
                    .bold()
                Text(artist)
                    .font(.body)
            }
            .padding()
        }
            


    }
}

struct SongListItem_Previews: PreviewProvider {
    static var previews: some View {
        SongListItem(name: "Nobody", artist: "Blue.D")
    }
}
