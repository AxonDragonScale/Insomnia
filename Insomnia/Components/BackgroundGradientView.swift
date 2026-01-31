//
//  BackgroundGradientView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct BackgroundGradientView: View {
    var body: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.6),
                    Color.indigo.opacity(0.4),
                    Color.purple.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundGradientView()
}
