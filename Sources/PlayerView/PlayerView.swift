//
//  PlayerView.swift
//
//
//  Created by 韦烽传 on 2021/11/20.
//

import Foundation
import UIKit
import AVFoundation

/**
 播放器视图
 */
open class PlayerView: UIView {
    
    // MARK: - Parameter
    
    /// 图层类型
    open override class var layerClass: AnyClass { return AVPlayerLayer.self }
    /// 播放器图层
    open var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    /// 播放器
    open var player: AVPlayer? {
        
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    /// 是否自动播放
    open var isAutoPlay = true
    /// 是否自动重新播放
    open var isAutoReplay = true
    
    /// 视频显示方式
    open var videoGravity: AVLayerVideoGravity {
        
        get { playerLayer.videoGravity }
        set { playerLayer.videoGravity = newValue }
    }
    
    /// 状态观察
    open var statusKVO: NSKeyValueObservation?
    /// 时长观察
    open var durationKVO: NSKeyValueObservation?
    /// 缓冲观察
    open var loadedTimeRangesKVO: NSKeyValueObservation?
    /// 时间观察
    open var timeObserver: Any?
    
    /// 协议
    open weak var delegate: PlayerViewProtocol?
    
    // MARK: - Event
    
    /**
     播放地址
     */
    open func play(_ urlString: String) {
        
        guard let url = URL(string: urlString) else {
            
            removePlayEndObserver()
            return
        }
        
        play(url)
    }
    
    /**
     播放地址
     */
    open func play(_ url: URL) {
        
        play(AVPlayerItem(url: url))
    }
    
    /**
     播放资源
     */
    open func play(_ item: AVPlayerItem) {
        
        removePlayEndObserver()
        
        if player == nil {
            
            player = AVPlayer()
        }
        
        observe(item)
        playEndObserver(item)
        
        player?.replaceCurrentItem(with: item)
    }
    
    /**
     观察
     
     播放状态、时长、缓冲
     
     - parameter    item:   播放资源
     */
    open func observe(_ item: AVPlayerItem) {
        
        statusKVO = item.observe(\.status) { [weak self] object, change in
            
            guard let self = self else { return }
            
            self.delegate?.playerView(self, item: object, status: object.status)
            
            if self.isAutoPlay {
                
                self.play()
            }
        }
        
        durationKVO = item.observe(\.duration) { [weak self] object, change in
            
            guard let self = self else { return }
            
            self.delegate?.playerView(self, item: object, duration: object.duration.seconds)
        }
        
        loadedTimeRangesKVO = item.observe(\.loadedTimeRanges) { [weak self] object, change in
            
            guard let self = self else { return }
            guard let first = object.loadedTimeRanges.first else { return }
            
            self.delegate?.playerView(self, item: object, timeRange: first.timeRangeValue)
        }
    }
    
    /**
     时间观察
     
     退出时需调用`removeTimeObserver()`删除观察
     目前发现在`iOS15`持有`timeObserver`还是会调用`deinit`，所以无需外部删除观察
     
     - parameter    interval:   时间间隔（毫秒）
     - parameter    queue:      队列
     - parameter    using:      回调结果
     */
    open func timeObserver(_ interval: CMTimeValue = 1000, queue: DispatchQueue? = nil, using: @escaping (Double)->Void) {
        
        removeTimeObserver()
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: interval, timescale: 1000), queue: queue) { time in
            
            using(time.seconds)
        }
    }
    
    /**
     删除时间观察
     */
    open func removeTimeObserver() {
        
        if let observer = timeObserver {
            
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    /**
     播放结束观察
     
     - parameter    item:   播放资源
     */
    open func playEndObserver(_ item: AVPlayerItem) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    /**
     删除播放结束观察
     */
    open func removePlayEndObserver() {
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    /**
     播放
     */
    open func play() {
        
        player?.play()
    }
    
    /**
     暂停
     */
    open func pause() {
        
        player?.pause()
    }
    
    /**
     重新播放
     */
    open func replay() {
        
        /// 回到最开始位置
        player?.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if player?.status == .readyToPlay {
            
            play()
        }
    }
    
    // MARK: - Notification
    
    /**
     播放结束
     */
    @objc open func playToEndTime(notification: Notification) {
        
        if let item = notification.object as? AVPlayerItem {
            
            delegate?.playerViewPlayEnd(self, item: item)
        }
        
        if isAutoReplay {
            
            replay()
        }
    }
    
    // MARK: - deinit
    
    deinit {
        
        removeTimeObserver()
        removePlayEndObserver()
        print(#function, Self.self)
    }
}
