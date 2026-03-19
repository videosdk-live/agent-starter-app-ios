//
//  SplashController.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 11/03/26.
//

import AVFoundation
import Combine
import Foundation
internal import Mediasoup
import SwiftUI
import WebRTC
import VideoSDKRTC

struct AudioDeviceWrapper: Identifiable {
    let id = UUID()
    let deviceName: String
    let isSelected: Bool
}

class SplashController: ObservableObject {

    @Published var isDispatchingAgent: Bool = false
    @Published var isSuccessfullyDispatched: Bool = false
    @Published var isWaving = true
    @Published var chatText: String = ""
    @Published var isMicMuted: Bool = false
    @Published var isCameraOn: Bool = false
    @Published var isScreenShared: Bool = false
    @Published var isChatOn: Bool = false
    @Published var hasMicPermission: Bool = false
    @Published var hasCameraPermission: Bool = false
    @Published var totalMeetingSeconds: Int = 0

    @Published var isErrorWhileJoiningMeetingErrorShowing: Bool = false
    @Published var isMaxParticipantsCapacityErrorShowing: Bool = false
    @Published var isCameraPermissionDeniedErrorShowing: Bool = false
    @Published var isMicPermissionDeniedErrorShowing: Bool = false
    @Published var isAudioDeviceSelectionShowing: Bool = false
    @Published var isErrorAlertShowing: Bool = false
    @Published var errorMessage: String = ""
    @Published var activeSpeakerId: String? = nil

    @Published var isLocalSmall: Bool = true
    @Published var meeting: Meeting? = nil
    @Published var participants: [String: Participant] = [:]
    @Published var localParticipant: Participant? = nil
    @Published var transcriptionList: [TranscriptItem] = []
    @Published var statusMessage: String = "Connecting..."
    @Published var statusMessageColor: Color = AppColors.yellow200
    @Published var statusColor: Color = AppColors.yellow800

    private var timerCancellable: AnyCancellable?
    @Published var availableMics: [AudioDeviceWrapper] = []

    @Published var localVideoTrack: RTCVideoTrack? = nil
    @Published var agentVideoTrack: RTCVideoTrack? = nil
    @Published var screenShareVideoTrack: RTCVideoTrack? = nil

    func dispatchAgent() {
        isDispatchingAgent = true
        var meetingToJoin = MeetingConfig.MEETING_ID
        DispatchQueue.main.async {
            if meetingToJoin.isEmpty {
                APIService.createMeeting(
                    token: MeetingConfig.AUTH_TOKEN,
                    completion: { result in
                        if case .success(let meetingId) = result {
                            meetingToJoin = meetingId
                            APIService.dispatchAgent(
                                meetingId: meetingToJoin,
                                agentId: MeetingConfig.AGENT_ID
                            ) { result in
                                if case .success(_) = result {
                                    DispatchQueue.main.async {
                                        self.isSuccessfullyDispatched = true
                                        self.initializeMeeting(meetingId: meetingToJoin)
                                        self.joinMeeting()
                                    }
                                } else if case .failure(let error) = result {
                                    self.isSuccessfullyDispatched = false
                                    self.isDispatchingAgent = false
                                    self.showAlert(
                                        message: error.localizedDescription
                                    )
                                } else {
                                    self.isSuccessfullyDispatched = false
                                    self.isDispatchingAgent = false
                                    self.showAlert(
                                        message:
                                            "An unknown error occurred."
                                    )
                                }
                            }
                        } else if case .failure(let error) = result {
                            self.isSuccessfullyDispatched = false
                            self.isDispatchingAgent = false
                            self.showAlert(
                                message: error.localizedDescription
                            )
                        }
                    }
                )
            } else {
                APIService.dispatchAgent(
                    meetingId: meetingToJoin,
                    agentId: MeetingConfig.AGENT_ID
                ) { result in
                    if case .success(_) = result {
                        DispatchQueue.main.async {
                            self.isSuccessfullyDispatched = true
                            self.initializeMeeting(meetingId: meetingToJoin)
                            self.joinMeeting()
                            self.isErrorWhileJoiningMeetingErrorShowing =
                                false
                        }
                    } else if case .failure(let error) = result {
                        DispatchQueue.main.async {
                            self.isSuccessfullyDispatched = false
                            self.isDispatchingAgent = false
                            self.showAlert(
                                message: error.localizedDescription
                            )
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isSuccessfullyDispatched = false
                            self.isDispatchingAgent = false
                            self.showAlert(
                                message: "An unknown error occurred."
                            )
                        }
                    }
                }
            }
        }
    }

    func showAlert(message: String) {
        self.errorMessage = message
        self.isErrorAlertShowing = true
    }

    private func startTimer() {
        timerCancellable?.cancel()
        totalMeetingSeconds = 0
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.totalMeetingSeconds += 1
            }
    }

    func cleanResources() {
        isDispatchingAgent = false
        isSuccessfullyDispatched = false
        meeting = nil
        participants.removeAll()
        errorMessage = ""
        timerCancellable?.cancel()
        transcriptionList.removeAll()
        timerCancellable = nil
        totalMeetingSeconds = 0
        isScreenShared = false
        isMicMuted = false
        isCameraOn = false
        isChatOn = false
        statusMessage = "Connecting..."
        statusMessageColor = AppColors.yellow200
        statusColor = AppColors.yellow800
        agentVideoTrack = nil
        screenShareVideoTrack = nil
        localVideoTrack = nil
        isErrorWhileJoiningMeetingErrorShowing = false
        isMaxParticipantsCapacityErrorShowing = false
        isCameraPermissionDeniedErrorShowing = false
        isMicPermissionDeniedErrorShowing = false
        isAudioDeviceSelectionShowing = false
        isErrorAlertShowing = false
        errorMessage = ""
        activeSpeakerId = nil
    }

    func initializeMeeting(meetingId: String) {
        DispatchQueue.main.async {
            VideoSDK.setLogLevel(level: .all)
            VideoSDK.config(token: MeetingConfig.AUTH_TOKEN)

            VideoSDK.getAudioPermission()
            VideoSDK.getVideoPermission()

            defer {
                self.hasMicPermission =
                    VideoSDK.getAudioPermissionStatus() == .authorized
                self.hasCameraPermission =
                    VideoSDK.getVideoPermissionStatus() == .authorized
            }

            self.meeting = VideoSDK.initMeeting(
                meetingId: meetingId,
                participantName: "User",
                micEnabled: true,
                webcamEnabled: false,
                customCameraVideoStream: nil,
                customAudioTrack: nil,
                multiStream: false,
                mode: .SEND_AND_RECV
            )

            self.isMicMuted = false
            self.isCameraOn = false
        }
    }

    func joinMeeting() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.meeting?.addEventListener(self)
            if self.meeting?.id.isEmpty == false {
                self.meeting?.join()
            }
        }
    }

    func endMeeting() {
        meeting?.end()
        cleanResources()
    }

    func startScreenShare() {
        Task {
            await meeting?.enableScreenShare()
        }
    }

    func stopScreenShare() {
        Task {
            await meeting?.disableScreenShare()
        }
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(
                    url,
                    options: [:],
                    completionHandler: nil
                )
            }
        }
    }

    func getAvailableMics() -> [AudioDeviceWrapper] {
        let mics = self.meeting?.getMics() ?? []
        return mics.map { mic in
            let isSelected = AVAudioSession.sharedInstance().currentRoute
                .outputs.contains(where: {
                    $0.portType.rawValue == mic.deviceType
                })
            return AudioDeviceWrapper(
                deviceName: mic.deviceName,
                isSelected: isSelected
            )
        }
    }

    func changeMic(to deviceName: String) {
        self.meeting?.changeMic(selectedDevice: deviceName)
    }
}

extension SplashController: MeetingEventListener {
    func onMeetingJoined() {
        DispatchQueue.main.async {
            self.localParticipant = self.meeting?.localParticipant

            self.statusColor = AppColors.green800
            self.statusMessage = "Connected"
            self.statusMessageColor = AppColors.green200

            self.startTimer()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if (self.meeting?.participants.count ?? 0) > 1 {
                    self.meeting?.leave()
                    self.isMaxParticipantsCapacityErrorShowing.toggle()
                } else {
                    self.localParticipant?.addEventListener(self)
                }
            }
        }
    }

    func onParticipantJoined(_ participant: Participant) {
        DispatchQueue.main.async {
            let isExist = self.participants.keys.contains(participant.id)
            if !isExist {
                self.participants[participant.id] = participant
                if participant.isAgent {
                    participant.addEventListener(self)
                }
            }
        }
    }

    func onParticipantLeft(_ participant: Participant, reason: LeaveReason) {
        DispatchQueue.main.async {
            participant.removeEventListener(self)
            if participant.isAgent {
                self.showAlert(
                    message:
                        "Agent has been left the meeting. Leaving the meeting now."
                )
                self.agentVideoTrack = nil
            }
        }
    }

    func onMeetingLeft(reason: LeaveReason) {
        DispatchQueue.main.async {
            if reason == .meetingEndApi {
                self.localParticipant?.removeEventListener(self)
                self.meeting?.removeEventListener(self)
                self.cleanResources()
            } else {
                self.isMaxParticipantsCapacityErrorShowing = true
            }
        }
    }

    func onSpeakerChanged(participantId: String?) {
        self.activeSpeakerId = participantId
    }

    func onError(error: VideoSDKError) {
        showAlert(message: error.message)
    }

    func onSocketError(message: String) {
        showAlert(message: message)
    }

    func onQualityLimitation(
        type: VideoSDKRTC.QualityLimitationType,
        state: VideoSDKRTC.QualityLimitationState,
        timestamp: Int
    ) {}
}

extension SplashController: ParticipantEventListener {
    func onStreamEnabled(
        _ stream: MediaStream,
        forParticipant participant: Participant
    ) {
        print(
            "OnStream Enabled: \(stream.kind) of participant: \(participant.displayName)"
        )
        if stream.kind == .state(value: .video) {
            if participant.isLocal {
                localVideoTrack = stream.track as? RTCVideoTrack
            } else if participant.isAgent && !participant.isLocal {
                agentVideoTrack = stream.track as? RTCVideoTrack
            }
        } else if stream.kind == .share {
            if participant.isLocal {
                screenShareVideoTrack = stream.track as? RTCVideoTrack
            }
        }
    }

    func onStreamDisabled(
        _ stream: MediaStream,
        forParticipant participant: Participant
    ) {
        print(
            "OnStream Disabled: \(stream.kind) of participant: \(participant.displayName)"
        )
        if stream.kind == .state(value: .video) {
            if participant.isLocal {
                localVideoTrack = nil
            } else if participant.isAgent && !participant.isLocal {
                agentVideoTrack = nil
            }
        } else if stream.kind == .share {
            if participant.isLocal {
                screenShareVideoTrack = nil
            }
        }
    }

    func onAgentTranscriptionReceived(
        _ segment: TranscriptionSegment,
        forParticipant participant: Participant?
    ) {
        self.transcriptionList.append(
            TranscriptItem(
                peerName: participant?.displayName ?? "N/A",
                message: segment.text
            )
        )
    }

    func onAgentStateChanged(
        _ state: AgentState,
        forParticipant participant: Participant
    ) {
        statusMessage = state.rawValue.capitalized

        if state == .IDLE {
            statusColor = AppColors.state100
            statusMessageColor = AppColors.state200
        } else if state == .LISTENING {
            statusColor = AppColors.neutral800
            statusMessageColor = AppColors.neutral200
        } else if state == .SPEAKING {
            statusColor = AppColors.info800
            statusMessageColor = AppColors.info200
        } else {
            statusColor = AppColors.primary750
            statusMessageColor = AppColors.primary
        }
    }
}
