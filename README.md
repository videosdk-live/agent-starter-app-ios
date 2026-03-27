# Agent Starter iOS

A starter project for integrating Conversational AI Agents in iOS using VideoSDK.

## Features

- **Voice & Video Support**: Seamless real-time audio and video communication.
- **AI Agent Integration**: Talk to an AI Agent directly with real-time feedback and dynamic animations.
- **Live Transcription**: View real-time ongoing transcriptions of the conversations within the app.
- **Screen Sharing**: Built-in support for sharing your screen during the session.
- **Device Management**: Switch between different audio and video devices smoothly.

## Prerequisites

1. iOS 18 or later
2. Xcode 16.4 or later

## Create Agent

You can create and configure a powerful AI agent directly from the VideoSDK dashboard — no coding required.

### Step 1: Create Your Agent
   First, follow our detailed guide to **[Build a Custom Voice AI Agent in Minutes](https://app.videosdk.live/agents/agents)**. This will walk you through creating the agent's persona, configuring its pipeline (Realtime or Cascading), and testing it directly from the dashboard.

### Step 2: Get Agent and Version ID
   Once your agent is created, you need to get its `agentId` and `versionId` to connect it to your frontend application.

   1. After creating your agent, go to the agent's page and find the JSON editor on the right side. Copy the `agentId`.
   
   2. To get the `versionId`, click on the 3 dots beside the Deploy button and click on **"Version History"**. Copy the version ID via the copy button of the version you want.

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/videosdk-live/agent-starter-app-ios.git
   cd agent-starter-ios
   ```

2. **Open the project in Xcode:**
   Open the `agent-starter-ios.xcodeproj` file using Xcode.

3. **Set up credentials:**
   Before running the app, you need to configure your authentication details. Open `agent-starter-ios/Constants/MeetingConfig.swift` and supply the required values:
   - `AUTH_TOKEN`: Your authorization token.
   - `AGENT_ID`: The ID of the agent you want to connect to.

   Also, there are two optional values:
   - `MEETING_ID`: If not specified, then it will create new meeting id and proceed.
   - `VERSION_ID`: If not specified, then it will get the latest verison for privided AgentId and proceed witht the latest versionId.

4. **Build and Run:**
   Select your target physical device and click the Run button (or press `Cmd + R`) in Xcode!
