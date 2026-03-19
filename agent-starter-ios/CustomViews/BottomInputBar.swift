//
//  BottomInputBar.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 12/03/26.
//

import SwiftUI
import VideoSDKRTC

// MARK: - Bottom Input Bar Component
struct BottomInputBar: View {
    @Binding var chatText: String
    @Binding var isMicMuted: Bool
    @Binding var isCameraOn: Bool
    @Binding var hasMicPermission: Bool
    @Binding var hasCameraPermission: Bool
    @Binding var meetingSeconds: Int
    @Binding var isScreenShared: Bool
    @Binding var isChatOn: Bool
    var isActiveSpeaker: Bool
    var onSendMessage: (String) -> Void
    var onMicClicked: () -> Void
    var onMicWarningButtonClicked: () -> Void
    var onCameraClicked: () -> Void
    var onCameraWarningButtonClicked: () -> Void
    var onScreenShareClicked: () -> Void
    var onChatToggleClicked: () -> Void
    var onEndCall: () -> Void

    var body: some View {
        VStack(spacing: Responsive.height(12)) {
            // Chat Input Row

            if isChatOn {
                HStack {
                    TextField("Type something...", text: $chatText)
                        .font(Responsive.font(size: 15))
                        .foregroundColor(AppColors.white)
                        .padding(.vertical, Responsive.height(12))

                    Button(action: {
                        onSendMessage(chatText)
                    }) {
                        Image("send")
                            .renderingMode(.template)
                            .font(Responsive.font(size: 16))
                            .foregroundColor(
                                chatText.isEmpty
                                    ? AppColors.neutral700 : AppColors.white
                            )
                            .frame(
                                width: Responsive.height(32),
                                height: Responsive.height(32)
                            )
                            .background(AppColors.neutral800)
                            .cornerRadius(Responsive.height(6))
                    }
                    .disabled(chatText.isEmpty)

                }
                .background(Color.black)
                .padding(.horizontal, Responsive.width(16))
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if isChatOn {
                Divider()
                    .background(AppColors.neutral800)
                    .padding(.horizontal, Responsive.width(16))
            }

            // Controls Row
            HStack(spacing: Responsive.width(6)) {

                Text(timeString(from: meetingSeconds))
                    .font(Responsive.font(size: 14))
                    .foregroundColor(AppColors.neutral400)
                    .frame(width: Responsive.width(45))
                    .padding(.leading, Responsive.width(4))

                // Mic Control
                ZStack(alignment: .topTrailing) {
                    HStack(spacing: Responsive.width(6)) {
                        Button(action: { onMicClicked() }) {
                            Image(systemName: isMicMuted ? "mic.slash" : "mic")
                                .font(Responsive.font(size: 16, weight: .bold))
                                .foregroundColor(
                                    isMicMuted
                                        ? AppColors.red400 : AppColors.white
                                )
                        }

                        if isActiveSpeaker {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(Responsive.font(size: 12))
                                .foregroundColor(AppColors.white)
                                .symbolEffect(
                                    .variableColor.cumulative.dimInactiveLayers
                                        .nonReversing,
                                    options: .repeating,
                                    isActive: true
                                )
                        } else {
                            Image(systemName: "ellipsis")
                                .font(Responsive.font(size: 12))
                                .foregroundColor(AppColors.white)
                        }
                    }
                    .padding(.horizontal, Responsive.width(8))
                    .padding(.vertical, Responsive.height(10))
                    .frame(height: Responsive.height(34))
                    .background(AppColors.neutral900)
                    .cornerRadius(Responsive.height(8), corners: .allCorners)
                    .overlay(
                        RoundedRectangle(cornerRadius: Responsive.height(8))
                            .stroke(
                                AppColors.neutral800,
                                lineWidth: Responsive.height(1)
                            )
                    )

                    if !hasMicPermission {
                        Image("warning")
                            .font(Responsive.font(size: 10))
                            .foregroundColor(AppColors.yellow800)
                            .background(
                                Circle().fill(AppColors.white).scaleEffect(0.6)
                            )
                            .offset(x: 4, y: -2)
                            .onTapGesture {
                                onMicWarningButtonClicked()
                            }
                    }
                }

                // Camera Control
                ZStack(alignment: .topTrailing) {
                    HStack(spacing: Responsive.width(6)) {
                        Button(action: { onCameraClicked() }) {
                            Image(
                                systemName: !isCameraOn
                                    ? "video.slash" : "video"
                            )
                            .font(Responsive.font(size: 16, weight: .bold))
                            .foregroundColor(
                                !isCameraOn
                                    ? AppColors.red400 : AppColors.white
                            )
                        }
                    }
                    .padding(.horizontal, Responsive.width(8))
                    .padding(.vertical, Responsive.height(10))
                    .frame(height: Responsive.height(34))
                    .background(AppColors.neutral900)
                    .cornerRadius(Responsive.height(8), corners: .allCorners)
                    .overlay(
                        RoundedRectangle(cornerRadius: Responsive.height(8))
                            .stroke(
                                AppColors.neutral800,
                                lineWidth: Responsive.height(1)
                            )
                    )

                    if !hasCameraPermission {
                        Image("warning")
                            .font(Responsive.font(size: 10))
                            .foregroundColor(AppColors.yellow800)
                            .background(
                                Circle().fill(AppColors.white).scaleEffect(0.6)
                            )
                            .offset(x: 4, y: -2)
                            .onTapGesture {
                                onCameraWarningButtonClicked()
                            }
                    }
                }

                Button(action: { onScreenShareClicked() }) {
                    Image("share")
                        .renderingMode(.template)
                        .font(Responsive.font(size: 16, weight: .bold))
                        .foregroundColor(AppColors.white)
                }
                .padding(.horizontal, Responsive.width(9))
                .padding(.vertical, Responsive.height(10))
                .frame(height: Responsive.height(34))
                .background(
                    self.isScreenShared
                        ? AppColors.primary750 : AppColors.neutral900
                )
                .cornerRadius(Responsive.height(8), corners: .allCorners)
                .overlay(
                    RoundedRectangle(cornerRadius: Responsive.height(8))
                        .stroke(
                            self.isScreenShared
                                ? AppColors.primary : AppColors.neutral800,
                            lineWidth: Responsive.height(1)
                        )
                )

                Button(action: { onChatToggleClicked() }) {
                    Image(
                        self.isChatOn
                            ? "stop_transcript" : "transcript"
                    )
                    .renderingMode(.template)
                    .font(Responsive.font(size: 16, weight: .bold))
                    .foregroundColor(AppColors.white)
                }
                .padding(.horizontal, Responsive.width(9))
                .padding(.vertical, Responsive.height(10))
                .frame(height: Responsive.height(34))
                .background(
                    self.isChatOn
                        ? AppColors.primary750 : AppColors.neutral900
                )
                .cornerRadius(Responsive.height(8), corners: .allCorners)
                .overlay(
                    RoundedRectangle(cornerRadius: Responsive.height(8))
                        .stroke(
                            self.isChatOn
                                ? AppColors.primary : AppColors.neutral800,
                            lineWidth: Responsive.height(1)
                        )
                )

                Spacer()

                // End Call Button
                Button(action: {
                    onEndCall()
                }) {
                    Text("End Call")
                        .font(Responsive.font(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .padding(.horizontal, Responsive.width(10))
                        .padding(.vertical, Responsive.height(10))
                        .background(AppColors.red800)
                        .frame(height: Responsive.height(34))
                        .cornerRadius(Responsive.height(8))

                }
                .frame(
                    width: Responsive.width(90),
                    height: Responsive.height(34)
                )
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, Responsive.width(12))
        }
        .padding(.top, Responsive.height(12))
        .padding(.bottom, Responsive.height(12))
        .background(Color.black.edgesIgnoringSafeArea(.bottom))
        .cornerRadius(Responsive.height(24), corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: Responsive.height(24))
                .stroke(AppColors.neutral800, lineWidth: Responsive.height(1))
        )
        .padding(.horizontal, Responsive.height(12))
        .animation(.easeInOut, value: isChatOn)
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    BottomInputBar(
        chatText: .constant("Testing Message"),
        isMicMuted: .constant(false),
        isCameraOn: .constant(false),
        hasMicPermission: .constant(false),
        hasCameraPermission: .constant(false),
        meetingSeconds: .constant(0),
        isScreenShared: .constant(false),
        isChatOn: .constant(false),
        isActiveSpeaker: false,
        onSendMessage: { message in },
        onMicClicked: { },
        onMicWarningButtonClicked: {},
        onCameraClicked: { },
        onCameraWarningButtonClicked: { },
        onScreenShareClicked: { },
        onChatToggleClicked: { },
        onEndCall: { }
    )
}
