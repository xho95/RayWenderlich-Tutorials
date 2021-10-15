/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import AVFoundation

// swiftlint:disable:next type_body_length
class PlayerViewModel: NSObject, ObservableObject {
  // MARK: Public properties

  var isPlaying = false {
    willSet {
      withAnimation {
        objectWillChange.send()
      }
    }
  }
  var isPlayerReady = false {
    willSet {
      objectWillChange.send()
    }
  }
  var playbackRateIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForRateSelection()
    }
  }
  var playbackPitchIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForPitchSelection()
    }
  }
  var playerProgress: Double = 0 {
    willSet {
      objectWillChange.send()
    }
  }
  var playerTime: PlayerTime = .zero {
    willSet {
      objectWillChange.send()
    }
  }
  var meterLevel: Float = 0 {
    willSet {
      objectWillChange.send()
    }
  }

  let allPlaybackRates: [PlaybackValue] = [
    .init(value: 0.5, label: "0.5x"),
    .init(value: 1, label: "1x"),
    .init(value: 1.25, label: "1.25x"),
    .init(value: 2, label: "2x")
  ]

  let allPlaybackPitches: [PlaybackValue] = [
    .init(value: -0.5, label: "-½"),
    .init(value: 0, label: "0"),
    .init(value: 0.5, label: "+½")
  ]

  // MARK: Private properties

  private let engine = AVAudioEngine()
  private let player = AVAudioPlayerNode()
  private let timeEffect = AVAudioUnitTimePitch()

  private var displayLink: CADisplayLink?

  private var needsFileScheduled = true

  private var audioFile: AVAudioFile?
  private var audioSampleRate: Double = 0
  private var audioLengthSeconds: Double = 0

  private var seekFrame: AVAudioFramePosition = 0
  private var currentPosition: AVAudioFramePosition = 0
  private var audioLengthSamples: AVAudioFramePosition = 0

  private var currentFrame: AVAudioFramePosition {
    guard
      let lastRenderTime = player.lastRenderTime,
      let playerTime = player.playerTime(forNodeTime: lastRenderTime)
    else {
      return 0
    }

    return playerTime.sampleTime
  }

  // MARK: - Public

  override init() {
    super.init()

    setupAudio()
    setupDisplayLink()
  }

  func playOrPause() {
    isPlaying.toggle()

    if player.isPlaying {
      displayLink?.isPaused = true
      disconnectVolumeTap()

      player.pause()
    } else {
      displayLink?.isPaused = false
      connectVolumeTap()

      if needsFileScheduled {
        scheduleAudioFile()
      }
      player.play()
    }
  }

  func skip(forwards: Bool) {
    let timeToSeek: Double

    if forwards {
      timeToSeek = 10
    } else {
      timeToSeek = -10
    }

    seek(to: timeToSeek)
  }

  // MARK: - Private

  private func setupAudio() {
    guard let fileURL = Bundle.main.url(forResource: "Intro", withExtension: "mp3") else {
      return
    }

    do {
      let file = try AVAudioFile(forReading: fileURL)
      let format = file.processingFormat

      audioLengthSamples = file.length
      audioSampleRate = format.sampleRate
      audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate

      audioFile = file

      configureEngine(with: format)
    } catch {
      print("Error reading the audio file: \(error.localizedDescription)")
    }
  }

  private func configureEngine(with format: AVAudioFormat) {
    engine.attach(player)
    engine.attach(timeEffect)

    engine.connect(
      player,
      to: timeEffect,
      format: format)
    engine.connect(
      timeEffect,
      to: engine.mainMixerNode,
      format: format)

    engine.prepare()

    do {
      try engine.start()

      scheduleAudioFile()
      isPlayerReady = true
    } catch {
      print("Error starting the player: \(error.localizedDescription)")
    }
  }

  private func scheduleAudioFile() {
    guard
      let file = audioFile,
      needsFileScheduled
    else {
      return
    }

    needsFileScheduled = false
    seekFrame = 0

    player.scheduleFile(file, at: nil) {
      self.needsFileScheduled = true
    }
  }

  // MARK: Audio adjustments

  private func seek(to time: Double) {
    guard let audioFile = audioFile else {
      return
    }

    let offset = AVAudioFramePosition(time * audioSampleRate)
    seekFrame = currentPosition + offset
    seekFrame = max(seekFrame, 0)
    seekFrame = min(seekFrame, audioLengthSamples)
    currentPosition = seekFrame

    let wasPlaying = player.isPlaying
    player.stop()

    if currentPosition < audioLengthSamples {
      updateDisplay()
      needsFileScheduled = false

      let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
      player.scheduleSegment(
        audioFile,
        startingFrame: seekFrame,
        frameCount: frameCount,
        at: nil
      ) {
        self.needsFileScheduled = true
      }

      if wasPlaying {
        player.play()
      }
    }
  }

  private func updateForRateSelection() {
    let selectedRate = allPlaybackRates[playbackRateIndex]
    timeEffect.rate = Float(selectedRate.value)
  }

  private func updateForPitchSelection() {
    let selectedPitch = allPlaybackPitches[playbackPitchIndex]

    // 1 octave = 1200 cents
    timeEffect.pitch = 1200 * Float(selectedPitch.value)
  }

  // MARK: Audio metering

  private func scaledPower(power: Float) -> Float {
    guard power.isFinite else {
      return 0.0
    }

    let minDb: Float = -80

    if power < minDb {
      return 0.0
    } else if power >= 1.0 {
      return 1.0
    } else {
      return (abs(minDb) - abs(power)) / abs(minDb)
    }
  }

  private func connectVolumeTap() {
    let format = engine.mainMixerNode.outputFormat(forBus: 0)

    engine.mainMixerNode.installTap(
      onBus: 0,
      bufferSize: 1024,
      format: format
    ) { buffer, _ in
      guard let channelData = buffer.floatChannelData else {
        return
      }

      let channelDataValue = channelData.pointee
      let channelDataValueArray = stride(
        from: 0,
        to: Int(buffer.frameLength),
        by: buffer.stride)
        .map { channelDataValue[$0] }

      let rms = sqrt(channelDataValueArray.map {
        return $0 * $0
      }
      .reduce(0, +) / Float(buffer.frameLength))

      let avgPower = 20 * log10(rms)
      let meterLevel = self.scaledPower(power: avgPower)

      DispatchQueue.main.async {
        self.meterLevel = self.isPlaying ? meterLevel : 0
      }
    }
  }

  private func disconnectVolumeTap() {
    engine.mainMixerNode.removeTap(onBus: 0)
    meterLevel = 0
  }

  // MARK: Display updates

  private func setupDisplayLink() {
    displayLink = CADisplayLink(
      target: self,
      selector: #selector(updateDisplay))
    displayLink?.add(to: .current, forMode: .default)
    displayLink?.isPaused = true
  }

  @objc private func updateDisplay() {
    currentPosition = currentFrame + seekFrame
    currentPosition = max(currentPosition, 0)
    currentPosition = min(currentPosition, audioLengthSamples)

    if currentPosition >= audioLengthSamples {
      player.stop()

      seekFrame = 0
      currentPosition = 0

      isPlaying = false
      displayLink?.isPaused = true

      disconnectVolumeTap()
    }

    playerProgress = Double(currentPosition) / Double(audioLengthSamples)

    let time = Double(currentPosition) / audioSampleRate
    playerTime = PlayerTime(
      elapsedTime: time,
      remainingTime: audioLengthSeconds - time)
  }
}
