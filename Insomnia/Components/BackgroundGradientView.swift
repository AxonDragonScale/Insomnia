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
            AppColors.backgroundGradient
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundGradientView()
}
