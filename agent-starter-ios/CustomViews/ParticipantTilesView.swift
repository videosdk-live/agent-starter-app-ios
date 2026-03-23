import SwiftUI
import VideoSDKRTC

struct ParticipantTilesView: View {
    @ObservedObject var controller: SplashController

    var body: some View {
        GeometryReader { geometry in
            if controller.screenShareVideoTrack != nil
                && controller.meeting != nil
            {
                let showLocalInSmallTile = controller.agentVideoTrack == nil
                ZStack(
                    alignment: showLocalInSmallTile ? .topTrailing : .topLeading
                ) {

                    // Large Tile
                    VStack {
                        Text("You’re sharing your screen with everyone")
                            .font(Responsive.font(size: 14, weight: .regular))
                            .foregroundStyle(AppColors.neutral300)

                        Button {
                            controller.stopScreenShare()
                            controller.isScreenShared = false
                        } label: {
                            HStack {
                                Image("stop_screenshare")
                                    .font(
                                        Responsive.font(size: 14, weight: .bold)
                                    )

                                Text("Stop Sharing")
                                    .font(
                                        Responsive.font(
                                            size: 14,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundStyle(AppColors.white)
                            }
                        }
                        .padding(.vertical, Responsive.height(4))
                        .padding(.horizontal, Responsive.width(10))
                        .background(AppColors.state800)
                        .cornerRadius(Responsive.width(6), corners: .allCorners)
                        .padding(.top, Responsive.height(8))

                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height - Responsive.height(80),
                        alignment: .center
                    )
                    .background(AppColors.neutral900)
                    .cornerRadius(Responsive.height(24))

                    // Small Tile
                    TileView(
                        controller: controller,
                        isLocal: showLocalInSmallTile,
                        width: geometry.size.width * 0.27,
                        height: geometry.size.height * 0.26,
                        onSwitchCamera: {
                            controller.meeting?.switchWebcam()
                        }
                    )
                    .padding(
                        showLocalInSmallTile ? .trailing : .leading,
                        Responsive.width(16)
                    )
                    .padding(.top, Responsive.height(16))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            } else if (controller.meeting?.participants.count ?? 0) > 0
                && controller.agentVideoTrack != nil
                && controller.localParticipant != nil
                && controller.meeting != nil
            {
                ZStack(
                    alignment: controller.isLocalSmall
                        ? .topTrailing : .topLeading
                ) {

                    // Large Tile
                    TileView(
                        controller: controller,
                        isLocal: !controller.isLocalSmall,
                        width: geometry.size.width,
                        height: geometry.size.height - Responsive.height(80),
                        onSwitchCamera: {
                            controller.meeting?.switchWebcam()
                        }
                    )
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(
                                    color: AppColors.neutral700,
                                    location: 0.0
                                ),
                                .init(
                                    color: AppColors.neutral700,
                                    location: 0.8
                                ),
                                .init(color: Color.red, location: 1.0),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            controller.isLocalSmall.toggle()
                        }
                    }

                    // Small Tile
                    TileView(
                        controller: controller,
                        isLocal: controller.isLocalSmall,
                        width: geometry.size.width * 0.27,
                        height: geometry.size.height * 0.26,
                        onSwitchCamera: {
                            controller.meeting?.switchWebcam()
                        }
                    )
                    .padding(
                        controller.isLocalSmall ? .trailing : .leading,
                        Responsive.width(16)
                    )
                    .padding(.top, Responsive.height(16))
                    .onTapGesture {
                        withAnimation(.spring()) {
                            controller.isLocalSmall.toggle()
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .topTrailing) {
                        GifImageView(gifName: "sample_gif")
                            .frame(
                                width: Responsive.width(190),
                                height: Responsive.width(190),
                                alignment: .center
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height,
                                alignment: .center
                            )

                        if controller.localParticipant != nil {
                            // Empty property check to force SwiftUI dependency observation
                            let _ = controller.localVideoTrack

                            // Small Tile
                            TileView(
                                controller: controller,
                                isLocal: true,
                                width: geometry.size.width * 0.27,
                                height: geometry.size.height * 0.26,
                                onSwitchCamera: {
                                    controller.meeting?.switchWebcam()
                                }
                            )
                            .padding(.trailing, Responsive.width(6))
                            .padding(.top, Responsive.height(16))
                        }
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                }
            }
        }
    }
}

#Preview {
    //    ParticipantTilesView(controller: SplashController())
    let controller = SplashController()
    GeometryReader { geometry in

        ZStack(alignment: .top) {

            ParticipantTilesView(controller: controller)
                .padding(.horizontal, Responsive.width(12))
                .padding(.bottom, Responsive.height(5))

            //            if controller.transcriptionList.count > 0 {
            TranscriptListView(
                listOfTranscriptions: .constant([
                    TranscriptItem(
                        peerName: "Lila Chen",
                        message:
                            "Hello There, How are you doing? Am I disturbing you ?"
                    ),
                    TranscriptItem(
                        peerName: "Arjun Kava",
                        message: "Hii There, How are you?"
                    ),
                    TranscriptItem(
                        peerName: "Arjun Kava",
                        message: "Hii There, How are you?"
                    ),
                ]),
                maxHeight: .constant(
                    controller.transcriptionList.count > 2
                        ? Responsive.height(170) : Responsive.height(170)
                )
            )
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .bottom
            )
            //            }
        }
        .background(AppColors.neutral950)
    }
}
