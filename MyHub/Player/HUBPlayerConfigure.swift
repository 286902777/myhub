//
//  HUBPlayerConfigure.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import AVFoundation
import UIKit

public struct HUBPlayerConfigure {
    public struct HUBPlayerColor {
        /// 顶部工具条背景颜色
        public var topToobar: UIColor
        /// 底部工具条背景颜色
        public var bottomToolbar: UIColor
        /// 进度条背景颜色
        public var progress: UIColor
        /// 缓冲条缓冲进度颜色
        public var progressBuffer: UIColor
        /// 进度条播放完成颜色
        public var progressFinished: UIColor
        /// 转子背景颜色
        public var loading: UIColor

        public init(topToobar: UIColor = .clear,
                    bottomToolbar: UIColor = .clear,
                    progress: UIColor = UIColor.white.withAlphaComponent(0.35),
                    progressBuffer: UIColor = UIColor.white.withAlphaComponent(0.5),
                    progressFinished: UIColor = UIColor.white,
                    loading: UIColor = UIColor.white)
        {
            self.topToobar = topToobar
            self.bottomToolbar = bottomToolbar
            self.progress = progress
            self.progressBuffer = progressBuffer
            self.progressFinished = progressFinished
            self.loading = loading
        }
    }

    public struct HUBPlayerImage {
        /// 返回按钮图片
        public var back: UIImage?
        /// vip
        public var vip: UIImage?
        /// 更多按钮图片
        public var more: UIImage?
        /// 播放按钮图片
        public var play: UIImage?
        /// 暂停按钮图片
        public var pause: UIImage?
        /// 进度滑块图片
        public var thumb: UIImage?
        /// 下一步按钮图片
        public var next: UIImage?
        /// 下一步按钮图片
        public var unNext: UIImage?
        
        public var full: UIImage?
        
        public var down: UIImage?
        
        public var downing: UIImage?

        public var downDone: UIImage?

        public var qian: UIImage?

        public var hou: UIImage?

        public var light: UIImage?

        public var sound: UIImage?
        
        public init(back: UIImage? = UIImage(named: "play_back"),
                    vip: UIImage? = UIImage(named: "pre_nav"),
                    more: UIImage? = UIImage(named: "play_list"),
                    play: UIImage? = UIImage(named: "play_play"),
                    pause: UIImage? = UIImage(named: "play_pause"),
                    next: UIImage? = UIImage(named: "play_next"),
                    unNext: UIImage? = UIImage(named: "play_un_next"),
                    thumb: UIImage? = UIImage(named: "play_slider"),
                    full: UIImage? = UIImage(named: "play_full"),
                    down: UIImage? = UIImage(named: "play_down"),
                    downing: UIImage? = UIImage(named: "alert_down_downing"),
                    downDone: UIImage? = UIImage(named: "play_down_done"),
                    qian: UIImage? = UIImage(named: "play_rewind"),
                    hou: UIImage? = UIImage(named: "play_forward"),
                    light: UIImage? = UIImage(named: "play_light"),
                    sound: UIImage? = UIImage(named: "play_sound"))
        {
            self.back = back
            self.vip = vip
            self.more = more
            self.play = play
            self.next = next
            self.unNext = unNext
            self.pause = pause
            self.thumb = thumb
            self.full = full
            self.down = down
            self.downing = downing
            self.downDone = downDone
            self.qian = qian
            self.hou = hou
            self.light = light
            self.sound = sound
        }
    }
    
    /// 自动旋转类型
    public enum HUBPlayerAutoRotateStyle {
        /// 禁止
        case none
        /// 只支持小屏
        case small
        /// 只支持全屏
        case fullScreen
        /// 全部
        case all
    }

    /// 手势控制类型
    public enum HUBPlayerGestureInteraction {
        /// 禁止
        case none
        /// 只支持小屏
        case small
        /// 只支持全屏
        case fullScreen
        /// 全部
        case all
    }

    /// 是否隐藏更多面板
    public var isHiddenMorePanel = false
    /// 初始界面是否显示工具条
    public var isHiddenToolbarWhenStart = true
    /// 手势控制
    public var gestureInteraction = HUBPlayerGestureInteraction.fullScreen
    /// 自动旋转类型
    public var rotateStyle = HUBPlayerAutoRotateStyle.all
    /// 顶部工具条隐藏风格
//    public var topBarHiddenStyle = HUBPlayerTopBarHiddenStyle.onlySmall
    /// 工具条自动消失时间
    public var autoFadeOut = 8.0
    /// 默认拉伸方式
    public var videoGravity = AVLayerVideoGravity.resizeAspect
    /// 颜色
    public var color = HUBPlayerColor()
    /// 图片
    public var image = HUBPlayerImage()
    /// 滑块水平偏移量
    public var thumbImageOffset = 0.0
    /// 滑块点击范围偏移
    public var thumbClickableOffset = CGPoint(x: 10, y: 10)
}

public protocol HUBPlayerDelegate: AnyObject {
    /// 播放器播放进度变化
    func player(_ player: HUBPlayer, didUpdateProgress progress: CGFloat)
    /// 播放器播放失败
    func player(_ player: HUBPlayer, didFailWithError error: Error?)
    /// 点击顶部工具条返回按钮
    func playerDidClickBackButton(_ player: HUBPlayer)
    func playerSuccessPlaying(_ player: HUBPlayer)
    /// 视频播放结束
    func playerDidFinishPlaying(_ player: HUBPlayer)
    /// 下载
    func playerDidClickDownButton(_ player: HUBPlayer)
    /// next
    func playerDidClickNextButton(_ player: HUBPlayer)
    /// vip
    func player(_ player: HUBPlayer, didClickVip auto: Bool)
    /// more
    func player(_ player: HUBPlayer, didClickMore full: Bool)
    /// rate
    func player(_ player: HUBPlayer, changeRate  rate: Float)
 
    func playerLoadPop(_ player: HUBPlayer)
}

public extension HUBPlayerDelegate {
    func player(_ player: HUBPlayer, didUpdateProgress progress: CGFloat) {}
    func player(_ player: HUBPlayer, didFailWithError error: Error?) {}
    func playerDidClickBackButton(_ player: HUBPlayer) {}
    func playerDidClickDownButton(_ player: HUBPlayer) {}
    func playerDidClickNextButton(_ player: HUBPlayer) {}
    func playerSuccessPlaying(_ player: HUBPlayer) {}
    func playerDidFinishPlaying(_ player: HUBPlayer) {}
    func player(_ player: HUBPlayer, didClickVip auto: Bool) {}
    func player(_ player: HUBPlayer, didClickMore full: Bool) {}
    func player(_ player: HUBPlayer, changeRate  rate: Float) {}
    func playerLoadPop(_ player: HUBPlayer) {}
}

protocol HUBPlayerContentViewDelegate: AnyObject {
    func didClickFailButton(in contentView: HUBPlayerContentView)

    func didClickBackButton(in contentView: HUBPlayerContentView)
    
    func didClickDownButton(in contentView: HUBPlayerContentView)

    func didClickNextButton(in contentView: HUBPlayerContentView)

    func contentView(_ contentView: HUBPlayerContentView, forWardOrBack forward: Bool)

    func contentView(_ contentView: HUBPlayerContentView, sliderTouchBegan slider: PlayerSlider)

    func contentView(_ contentView: HUBPlayerContentView, sliderValueChanged slider: PlayerSlider)

    func contentView(_ contentView: HUBPlayerContentView, sliderTouchEnded slider: PlayerSlider)
    
    func contentView(_ contentView: HUBPlayerContentView, didChangeRate rate: Float)

    func contentView(_ contentView: HUBPlayerContentView, didClickPlayButton isPlay: Bool)

    func contentView(_ contentView: HUBPlayerContentView, didClickFullButton isFull: Bool)

    func contentView(_ contentView: HUBPlayerContentView, didClickVipButton auto: Bool)

    func contentView(_ contentView: HUBPlayerContentView, didClickMoreButton isFull: Bool)

    func contentView(_ contentView: HUBPlayerContentView, didChangeVideoGravity videoGravity: AVLayerVideoGravity)

}
