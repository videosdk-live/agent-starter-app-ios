import SwiftUI
import UIKit
import VideoSDKRTC
import WebKit

struct SplashScreen: View {
    @StateObject private var controller = SplashController()

    var body: some View {
        ZStack {
            AppColors.neutral950
                .ignoresSafeArea()

            if controller.isSuccessfullyDispatched {
                VStack {

                    ZStack(alignment: .topTrailing) {

                        VStack {

                            Text("Powered by VideoSDK")
                                .font(
                                    Responsive.font(size: 13, weight: .regular)
                                )
                                .foregroundColor(AppColors.neutral700)

                            if controller.isDispatchingAgent {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(controller.statusColor)
                                        .frame(width: 6, height: 6)

                                    Text(controller.statusMessage)
                                        .font(
                                            Responsive.font(
                                                size: 12,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundColor(
                                            controller.statusMessageColor
                                        )
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .strokeBorder(
                                            controller.statusColor.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .padding(.vertical, Responsive.height(8))
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .frame(
                            width: UIApplication.safeScreenSize.width,
                            alignment: .center
                        )

                        Button(action: {
                            controller.isAudioDeviceSelectionShowing = true
                        }) {
                            Image(systemName: "speaker.wave.2")
                                .renderingMode(.template)
                                .font(Responsive.font(size: 16, weight: .bold))
                                .foregroundColor(AppColors.white)
                        }
                        .padding(.vertical, Responsive.height(10))
                        .frame(
                            width: Responsive.height(32),
                            height: Responsive.height(32)
                        )
                        .background(AppColors.neutral900)
                        .cornerRadius(
                            Responsive.height(8),
                            corners: .allCorners
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Responsive.height(8))
                                .stroke(
                                    AppColors.neutral800,
                                    lineWidth: Responsive.height(1)
                                )
                        )
                        .padding(.trailing, Responsive.width(17))
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .top) {
                            ParticipantTilesView(controller: controller)
                                .padding(.horizontal, Responsive.width(12))
                                .padding(.bottom, Responsive.height(5))

                            if controller.transcriptionList.count > 0 {
                                TranscriptListView(
                                    listOfTranscriptions: $controller
                                        .transcriptionList,
                                    maxHeight: .constant(
                                        controller.transcriptionList.count > 2
                                            ? Responsive.height(170)
                                            : Responsive.height(120)
                                    )
                                )
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height,
                                    alignment: .bottom
                                )
                            }
                        }
                        .background(Color.clear)
                    }

                    BottomInputBar(
                        chatText: $controller.chatText,
                        isMicMuted: $controller.isMicMuted,
                        isCameraOn: $controller.isCameraOn,
                        hasMicPermission: $controller.hasMicPermission,
                        hasCameraPermission: $controller.hasCameraPermission,
                        meetingSeconds: $controller.totalMeetingSeconds,
                        isScreenShared: $controller.isScreenShared,
                        isChatOn: $controller.isChatOn,
                        isActiveSpeaker: controller.activeSpeakerId != nil
                            && controller.activeSpeakerId
                                == controller.localParticipant?.id,
                        onSendMessage: { message in
                            controller.chatText = ""
                        },
                        onMicClicked: {
                            if controller.isMicMuted {
                                controller.meeting?.unmuteMic()
                            } else {
                                controller.meeting?.muteMic()
                            }
                            controller.isMicMuted.toggle()
                        },
                        onMicWarningButtonClicked: {
                            let audioPermissionStatus =
                                VideoSDK.getAudioPermissionStatus()
                            if audioPermissionStatus == .denied
                                || audioPermissionStatus == .restricted
                            {
                                self.controller
                                    .isMicPermissionDeniedErrorShowing.toggle()
                            } else if audioPermissionStatus == .notDetermined {
                                VideoSDK.getAudioPermission()
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 2
                                ) {
                                    self.controller.hasMicPermission =
                                        VideoSDK.getAudioPermissionStatus()
                                        == .authorized
                                }
                            }
                        },
                        onCameraClicked: {
                            if controller.isCameraOn {
                                controller.meeting?.disableWebcam()
                            } else {
                                controller.meeting?.enableWebcam()
                            }
                            controller.isCameraOn.toggle()
                        },
                        onCameraWarningButtonClicked: {
                            let videoPermissionStatus =
                                VideoSDK.getVideoPermissionStatus()
                            if videoPermissionStatus == .denied
                                || videoPermissionStatus == .restricted
                            {
                                self.controller
                                    .isCameraPermissionDeniedErrorShowing
                                    .toggle()
                            } else if videoPermissionStatus == .notDetermined {
                                VideoSDK.getVideoPermission()
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 2
                                ) {
                                    self.controller.hasCameraPermission =
                                        VideoSDK.getVideoPermissionStatus()
                                        == .authorized
                                }
                            }
                        },
                        onScreenShareClicked: {
                            if controller.isScreenShared {
                                controller.stopScreenShare()
                            } else {
                                controller.startScreenShare()
                            }
                            controller.isScreenShared.toggle()
                        },
                        onChatToggleClicked: {
                            withAnimation {
                                controller.isChatOn.toggle()
                            }
                        },
                        onEndCall: {
                            withAnimation(.spring()) {
                                controller.endMeeting()
                            }
                        }
                    )
                    .padding(.bottom, Responsive.height(20))
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                VStack {
                    Text("Powered by VideoSDK")
                        .font(Responsive.font(size: 13, weight: .regular))
                        .foregroundColor(AppColors.neutral700)

                    if controller.isDispatchingAgent {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(controller.statusColor)
                                .frame(width: 6, height: 6)

                            Text(controller.statusMessage)
                                .font(
                                    Responsive.font(size: 12, weight: .medium)
                                )
                                .foregroundColor(controller.statusMessageColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .strokeBorder(
                                    controller.statusColor.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                        .padding(.top, Responsive.height(8))
                        .transition(.opacity.combined(with: .scale))
                    }

                    Spacer()

                    ZStack {
                        GifImageView(gifName: "sample_gif")
                            .frame(
                                width: Responsive.width(250),
                                height: Responsive.width(250),
                                alignment: .top
                            )
                            .opacity(controller.isDispatchingAgent ? 0.5 : 1.0)
                            .shadow(
                                color: AppColors.white,
                                radius: Responsive.width(70)
                            )
                            .blur(radius: controller.isDispatchingAgent ? 4 : 0)

                        if controller.isDispatchingAgent {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                                .scaleEffect(1.5)
                        }
                    }.frame(alignment: .center)

                    Spacer()

                    if !controller.isDispatchingAgent {
                        Button(action: {
                            withAnimation(.spring()) {
                                controller.dispatchAgent()
                            }
                        }) {
                            HStack(spacing: Responsive.width(8)) {
                                Image(systemName: "waveform")
                                    .font(
                                        Responsive.font(size: 18, weight: .bold)
                                    )
                                    .symbolEffect(
                                        .variableColor.cumulative
                                            .dimInactiveLayers.nonReversing,
                                        options: .repeating,
                                        isActive: controller.isWaving
                                    )
                                Text("Talk to agent")
                                    .font(
                                        Responsive.font(
                                            size: 18,
                                            weight: .semibold
                                        )
                                    )
                            }
                            .foregroundColor(AppColors.primary800)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: Responsive.height(40)
                            )
                            .background(AppColors.white)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, Responsive.width(24))
                        .padding(.bottom, Responsive.height(10))
                    } else {
                        Spacer()
                            .frame(
                                height: Responsive.height(40)
                                    + Responsive.height(10)
                            )
                    }
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .customDialog(
            isShowing: $controller.isErrorWhileJoiningMeetingErrorShowing,
            onOutsideTap: {
                controller.isErrorWhileJoiningMeetingErrorShowing = false
                controller.cleanResources()
            }
        ) {
            AppDialog(
                title: "Unable to Join Meeting",
                message:
                    "We couldn’t connect you to the meeting. Please check your internet connection and try again.",
                positiveButtonText: "Try Again",
                negativeButtonText: "",
                isCancelVisible: false,
                onPositiveButtonTap: {
                    controller.isErrorWhileJoiningMeetingErrorShowing.toggle()
                    controller.cleanResources()
                },
                onNegativeButtonTap: {},
                onCloseTap: {
                    controller.isErrorWhileJoiningMeetingErrorShowing.toggle()
                    controller.cleanResources()
                }
            )
        }
        .customDialog(
            isShowing: $controller.isMaxParticipantsCapacityErrorShowing,
            onOutsideTap: {
                controller.isMaxParticipantsCapacityErrorShowing = false
                controller.cleanResources()
            }
        ) {
            AppDialog(
                title: "Meeting Capacity Reached",
                message:
                    "This meeting has reached its maximum limit of 2 participants. Please try joining again later.",
                positiveButtonText: "Go Back",
                negativeButtonText: "",
                isCancelVisible: false,
                onPositiveButtonTap: {
                    controller.isMaxParticipantsCapacityErrorShowing.toggle()
                    controller.cleanResources()
                },
                onNegativeButtonTap: {},
                onCloseTap: {
                    controller.isMaxParticipantsCapacityErrorShowing.toggle()
                    controller.cleanResources()
                }
            )
        }
        .customDialog(
            isShowing: $controller.isMicPermissionDeniedErrorShowing,
            onOutsideTap: {
                controller.isMicPermissionDeniedErrorShowing = false
            }
        ) {
            AppDialog(
                title: "Microphone Permission Denied",
                message:
                    "Microphone access is required to make audio calls. Please enable it in your settings.",
                positiveButtonText: "Open Settings",
                negativeButtonText: "Cancel",
                isCancelVisible: true,
                onPositiveButtonTap: {
                    controller.isMicPermissionDeniedErrorShowing.toggle()
                    controller.openAppSettings()
                },
                onNegativeButtonTap: {
                    controller.isMicPermissionDeniedErrorShowing.toggle()
                },
                onCloseTap: {
                    controller.isMicPermissionDeniedErrorShowing.toggle()
                }
            )
        }
        .customDialog(
            isShowing: $controller.isCameraPermissionDeniedErrorShowing,
            onOutsideTap: {
                controller.isCameraPermissionDeniedErrorShowing = false
            }
        ) {
            AppDialog(
                title: "Camera Permission Denied",
                message:
                    "Camera access is required to use video. Please enable it in your settings.",
                positiveButtonText: "Open Settings",
                negativeButtonText: "Not Now",
                isCancelVisible: true,
                onPositiveButtonTap: {
                    controller.isCameraPermissionDeniedErrorShowing.toggle()
                    controller.openAppSettings()
                },
                onNegativeButtonTap: {
                    controller.isCameraPermissionDeniedErrorShowing.toggle()
                },
                onCloseTap: {
                    controller.isCameraPermissionDeniedErrorShowing.toggle()
                }
            )
        }
        .audioDeviceSelectionSheet(
            isShowing: $controller.isAudioDeviceSelectionShowing,
            availableMics: controller.availableMics,
            onMicSelected: { deviceName in
                controller.changeMic(to: deviceName)
            }
        )
        .customDialog(
            isShowing: $controller.isErrorAlertShowing,
            onOutsideTap: {
                controller.isErrorAlertShowing.toggle()
            }
        ) {
            AppDialog(
                title: "Error",
                message: controller.errorMessage,
                positiveButtonText: "OK",
                negativeButtonText: "",
                isCancelVisible: false,
                onPositiveButtonTap: {
                    controller.isErrorAlertShowing.toggle()
                    self.controller.endMeeting()
                },
                onNegativeButtonTap: {},
                onCloseTap: {
                    controller.isErrorAlertShowing.toggle()
                }
            )
        }
        .onChange(
            of: controller.isAudioDeviceSelectionShowing,
            { oldValue, newValue in
                controller.availableMics = controller.getAvailableMics()
            }
        )
        .onAppear {
            controller.isWaving = true
            controller.hasMicPermission =
                VideoSDK.getAudioPermissionStatus() == .authorized
            controller.hasCameraPermission =
                VideoSDK.getVideoPermissionStatus() == .authorized
            print(
                "Audio: \(controller.hasMicPermission) || Video: \(controller.hasCameraPermission)"
            )
        }
    }
}

#Preview {
    SplashScreen()
}
