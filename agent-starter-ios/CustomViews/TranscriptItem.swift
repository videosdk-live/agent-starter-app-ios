//
//  TranscriptItem.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 13/03/26.
//

import SwiftUI

struct TranscriptItem: View {
    var peerName: String
    var message: String
    var avatarUrl: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: Responsive.width(10)) {
            // Avatar Placeholder / Image
            if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
                Image(avatarUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: Responsive.width(28),
                        height: Responsive.width(28)
                    )
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(AppColors.white.opacity(0.05))
                        .frame(
                            width: Responsive.width(28),
                            height: Responsive.width(28)
                        )

                    Text(String(peerName.prefix(1)).uppercased())
                        .font(Responsive.font(size: 14))
                        .foregroundColor(AppColors.white)
                }
            }

            VStack(alignment: .leading, spacing: Responsive.height(4)) {
                Text(peerName)
                    .font(Responsive.font(size: 14, weight: .regular))
                    .foregroundColor(AppColors.neutral400)

                Text(message)
                    .font(Responsive.font(size: 14, weight: .medium))
                    .foregroundColor(AppColors.white)
            }
            .padding(.top, Responsive.height(4))

            Spacer()
        }
        .padding(.horizontal, Responsive.width(16))
        .padding(.vertical, Responsive.height(6))
    }
}

#Preview {
    ZStack {

        Color.black.edgesIgnoringSafeArea(.all)

        TranscriptItem(
            peerName: "Parth A",
            message: "Hello, How are you?",
            avatarUrl: nil
        )

    }
}
