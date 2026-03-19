//
//  AppDialog.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 13/03/26.
//

import SwiftUI

struct AppDialog: View {
    var title: String
    var message: String
    var positiveButtonText: String
    var negativeButtonText: String
    var isCancelVisible: Bool
    var onPositiveButtonTap: () -> Void
    var onNegativeButtonTap: () -> Void
    var onCloseTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Responsive.height(16)) {

            HStack(alignment: .top) {
                Text(title)
                    .font(Responsive.font(size: 18, weight: .bold))
                    .foregroundColor(AppColors.white)

                Spacer()

                Button(action: onCloseTap) {
                    Image(systemName: "xmark")
                        .font(Responsive.font(size: 16, weight: .bold))
                        .foregroundColor(AppColors.neutral400)
                }
            }

            Text(message)
                .font(Responsive.font(size: 14, weight: .regular))
                .foregroundColor(AppColors.neutral400)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Responsive.width(10)) {
                Spacer()

                if isCancelVisible {
                    Button(action: onNegativeButtonTap) {
                        Text(negativeButtonText)
                            .font(Responsive.font(size: 14, weight: .semibold))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, Responsive.width(16))
                            .padding(.vertical, Responsive.height(8))
                            .background(AppColors.neutral800)
                            .cornerRadius(Responsive.height(8))
                    }
                }

                Button(action: onPositiveButtonTap) {
                    Text(positiveButtonText)
                        .font(Responsive.font(size: 14, weight: .semibold))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, Responsive.width(16))
                        .padding(.vertical, Responsive.height(8))
                        .background(AppColors.primary)
                        .cornerRadius(Responsive.height(8))
                }
            }
            .padding(.top, Responsive.height(4))
        }
        .padding(Responsive.width(20))
        .background(AppColors.neutral950)
        .cornerRadius(Responsive.height(16))
        .overlay(
            RoundedRectangle(cornerRadius: Responsive.height(16))
                .stroke(AppColors.neutral800, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.white.opacity(0.4)
            .edgesIgnoringSafeArea(.all)

        AppDialog(
            title: "Unable to Join Meeting",
            message:
                "We couldn't connect you to the meeting. Please check your internet connection and try again.",
            positiveButtonText: "Try Again",
            negativeButtonText: "Cancel",
            isCancelVisible: true,
            onPositiveButtonTap: { },
            onNegativeButtonTap: { },
            onCloseTap: { }
        )
    }
}
