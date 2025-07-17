//
//  HeaderView.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//

import SwiftUI

struct Header: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "toilet")
        .font(.system(size: 40, weight: .regular))
        .foregroundStyle(.tint)
      Text("Welcome to Biometry!")
        .bold().font(.title)
    }
  }
}
