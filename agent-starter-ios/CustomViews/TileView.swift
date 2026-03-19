//
//  TileView.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 12/03/26.
//

internal import Mediasoup
import SwiftUI
import VideoSDKRTC
import WebRTC

struct TileView: View {
    @ObservedObject var controller: SplashController
    var isLocal: Bool
    var width: CGFloat
    var height: CGFloat
    var onSwitchCamera: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            ZStack {
                Rectangle()
                    .fill(
                        isLocal
                            ? AppColors.neutral800
                            : AppColors.white.opacity(0.05)
                    )

                if isLocal && controller.localVideoTrack != nil {
                    ParticipantView(
                        track: controller.localVideoTrack,
                        height: height,
                        width: width
                    )
                    .id(
                        controller.localVideoTrack?.trackId ?? UUID().uuidString
                    )
                } else if !isLocal && controller.agentVideoTrack != nil {
                    ParticipantView(
                        track: controller.agentVideoTrack,
                        height: height,
                        width: width
                    )
                    .id(
                        controller.agentVideoTrack?.trackId ?? UUID().uuidString
                    )
                } else {
                    ZStack {
                        Circle()
                            .fill(AppColors.neutral900)
                            .frame(
                                width: width * 0.4,
                                height: width * 0.4,
                            )

                        Text(
                            String(
                                (isLocal
                                    ? controller.localParticipant?.displayName
                                        ?? "N/A"
                                    : (controller.meeting?.participants.values
                                        .first?.displayName ?? "N/A")).prefix(1)
                            ).uppercased()
                        )
                        .font(Responsive.font(size: width * 0.2))
                        .foregroundColor(AppColors.white)
                    }
                }
            }
            .frame(width: width, height: height)
            .cornerRadius(Responsive.height(24))

            // Switch Camera button
            if isLocal {
                Button(action: onSwitchCamera) {
                    Image(systemName: "camera.rotate")
                        .font(
                            Responsive.font(
                                size: Responsive.height(18),
                                weight: .bold
                            )
                        )
                        .foregroundColor(.white)
                        .padding(Responsive.height(10))
                        .frame(
                            width: Responsive.width(30),
                            height: Responsive.height(30)
                        )
                        .background(AppColors.neutral900)
                        .cornerRadius(
                            Responsive.height(4),
                            corners: .allCorners
                        )
                }
                .padding(.vertical, Responsive.width(20))
                .padding(.horizontal, Responsive.width(10))
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        TileView(
            controller: SplashController(),
            isLocal: true,
            width: geometry.size.width,
            height: geometry.size.height,
            onSwitchCamera: { }
        )
    }
}

/// VideoView for participant's video
class VideoView: UIView {
    var videoView: RTCMTLVideoView = {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFill
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    init(
        track: RTCVideoTrack?,
        width: Double = UIApplication.safeScreenSize.width,
        height: Double = Responsive.height(250)
    ) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))

        self.videoView.frame = self.bounds
        self.addSubview(self.videoView)
        self.bringSubviewToFront(self.videoView)

        if let track = track {
            track.add(self.videoView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoView.frame = self.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Component to show the video stream
struct ParticipantView: UIViewRepresentable, Equatable {
    static func == (lhs: ParticipantView, rhs: ParticipantView) -> Bool {
        return lhs.track == rhs.track && lhs.height == rhs.height
            && lhs.width == rhs.width
    }

    var track: RTCVideoTrack?
    var height: Double
    var width: Double

    func makeUIView(context: Context) -> VideoView {
        let view = VideoView(track: track, width: width, height: height)
        return view
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
        uiView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        uiView.videoView.frame = uiView.bounds

        if context.coordinator.currentTrack == track { return }

        if let oldTrack = context.coordinator.currentTrack {
            oldTrack.remove(uiView.videoView)
            context.coordinator.currentTrack = nil
        }

        if let newTrack = track {
            DispatchQueue.main.async {
                newTrack.add(uiView.videoView)
                context.coordinator.currentTrack = newTrack
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ParticipantView
        var currentTrack: RTCVideoTrack?

        init(_ parent: ParticipantView) {
            self.parent = parent
            self.currentTrack = parent.track
        }
    }
}
