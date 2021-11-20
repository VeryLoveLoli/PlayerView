//
//  PlayerViewProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/11/20.
//

import Foundation
import UIKit
import AVFoundation

/**
 播放器视图协议
 */
public protocol PlayerViewProtocol: AnyObject {
    
    /**
     播放状态
     
     - parameter    playerView:     播放视图
     - parameter    item:           资源
     - parameter    status:         资源状态
     */
    func playerView(_ playerView: PlayerView, item: AVPlayerItem, status: AVPlayerItem.Status)
    
    /**
     资源时长
     
     - parameter    playerView:     播放视图
     - parameter    item:           资源
     - parameter    duration:       资源时长
     */
    func playerView(_ playerView: PlayerView, item: AVPlayerItem, duration: Double)
    
    /**
     缓冲区间
     
     - parameter    playerView:     播放视图
     - parameter    item:           资源
     - parameter    timeRange:      缓冲区间
     */
    func playerView(_ playerView: PlayerView, item: AVPlayerItem, timeRange: CMTimeRange)
    
    /**
     播放结束
     
     - parameter    playerView:     播放视图
     - parameter    item:           资源
     */
    func playerViewPlayEnd(_ playerView: PlayerView, item: AVPlayerItem)
}
