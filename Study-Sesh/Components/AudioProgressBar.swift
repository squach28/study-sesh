//
//  AudioProgressBar.swift
//  Study-Sesh
//
//  Created by Sean Quach on 1/28/22.
//

import SwiftUI
import AVFoundation

struct AudioProgressBar: View {
    @Binding var currentItemDuration: CMTime
    @Binding var currentTime: CMTime
    var body: some View {
        // Audio Progress Bar with current time and duration
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color(hue: 0.775, saturation: 0.361, brightness: 0.921))
                .opacity(0.3)
                .frame(width: 325, height: 20)
            Rectangle()
                .foregroundColor(.purple)
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
}
