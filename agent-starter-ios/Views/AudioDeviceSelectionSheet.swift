//
//  AudioDeviceSelectionSheet.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 14/03/26.
//

import SwiftUI

struct AudioDeviceSelectionSheet: ViewModifier {
    @Binding var isShowing: Bool
    var availableMics: [AudioDeviceWrapper]
    var onMicSelected: (String) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isShowing {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
                    .transition(.opacity)

                VStack(spacing: 0) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 0) {

                        HStack {
                            Text("Select Audio Device")
                                .font(Responsive.font(size: 16, weight: .bold))
                                .foregroundColor(AppColors.white)

                            Spacer()

                            Button(action: {
                                withAnimation {
                                    isShowing = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(
                                        Responsive.font(size: 16, weight: .bold)
                                    )
                                    .foregroundColor(AppColors.neutral400)
                            }
                        }
                        .padding(.horizontal, Responsive.width(20))
                        .padding(.vertical, Responsive.height(16))

                        Divider().background(AppColors.neutral800)

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(availableMics) { mic in
                                    Button(action: {
                                        onMicSelected(mic.deviceName)
                                        withAnimation {
                                            isShowing = false
                                        }
                                    }) {
                                        HStack {
                                            Text(mic.deviceName)
                                                .font(
                                                    Responsive.font(
                                                        size: 14,
                                                        weight: .regular
                                                    )
                                                )
                                                .foregroundColor(
                                                    mic.isSelected
                                                        ? AppColors.white
                                                        : AppColors.neutral400
                                                )

                                            Spacer()

                                            if mic.isSelected {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(
                                                        AppColors.primary
                                                    )
                                            }
                                        }
                                        .padding(
                                            .vertical,
                                            Responsive.height(16)
                                        )
                                        .padding(
                                            .horizontal,
                                            Responsive.width(20)
                                        )
                                    }
                                }
                            }
                            .padding(.bottom, Responsive.height(20))
                        }
                        .frame(maxHeight: Responsive.height(300))
                    }
                    .background(AppColors.neutral950)
                    .cornerRadius(
                        Responsive.height(24),
                        corners: [.topLeft, .topRight]
                    )
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: -5
                    )
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

extension View {
    func audioDeviceSelectionSheet(
        isShowing: Binding<Bool>,
        availableMics: [AudioDeviceWrapper],
        onMicSelected: @escaping (String) -> Void
    ) -> some View {
        self.modifier(
            AudioDeviceSelectionSheet(
                isShowing: isShowing,
                availableMics: availableMics,
                onMicSelected: onMicSelected
            )
        )
    }
}
