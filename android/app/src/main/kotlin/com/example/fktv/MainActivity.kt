package com.example.fktv

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.media.MediaPlayer
import android.media.AudioManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "test"
    private val mediaPlayer: MediaPlayer? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "hello") {
                // 处理请求逻辑
                // 返回结果给Flutter
                this.playAudio("")
                result.success("Hello, Flutter!")
            } else if (call.method == "playAudio") {
                // 处理请求逻辑
                // 返回结果给Flutter
                
                result.success("playAudio")
            }else{
                // 处理请求逻辑
                // 返回结果给Flutter
                // result.notImplemented()
                result.success("notImplemented:"+call.method)
            }
        }
    }
    fun playAudio(url: String) {
        val mp3 = "http://m7.music.126.net/20231126173114/e42edbf761983cf4c57929cd31d7b71f/ymusic/57d6/ba78/a6d6/30ae02ed850a7fc4612d4111aada0817.mp3"
        var mediaPlayer:MediaPlayer? = MediaPlayer()
        if(mediaPlayer == null) {
            return
        }
        mediaPlayer.setDataSource(url)
        mediaPlayer.prepare()
        mediaPlayer.start()
    }
}
