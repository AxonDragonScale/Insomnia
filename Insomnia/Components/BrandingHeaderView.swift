//
//  BrandingHeaderView.swift
//  Insomnia
//
//  Created by Ronak Harkhani on 31/01/26.
//

import SwiftUI

struct BrandingHeaderView: View {
    let isActive: Bool

    var body: some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.white)
            
            Text("Insomnia")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()

            // Small status dot
            Circle()
                .fill(isActive ? Color.green : Color.white.opacity(0.3))
                .frame(width: 12, height: 12)
                .shadow(radius: isActive ? 2 : 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
}

#Preview {
    ZStack {
        Color.indigo
        VStack {
            BrandingHeaderView(isActive: true)
            BrandingHeaderView(isActive: false)
        }
    }
}
