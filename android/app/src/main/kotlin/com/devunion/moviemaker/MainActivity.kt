package com.devunion.moviemaker

import android.Manifest
import android.annotation.TargetApi
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.media.ThumbnailUtils
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import com.devunion.moviemaker.util.VideoJoiner
import com.devunion.moviemaker.util.showMovie
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    private val batteryLevel: Int
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                return batteryManager!!.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            } else {
                val intent = ContextWrapper(applicationContext).registerReceiver(
                    null,
                    IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                )
                return ((intent!!.getIntExtra(
                    BatteryManager.EXTRA_LEVEL,
                    -1
                ) * 100) / intent!!.getIntExtra(
                    BatteryManager.EXTRA_SCALE, -1
                ))
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        @TargetApi(25)
        if ((Build.VERSION.SDK_INT >= 25 &&
                    checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED &&
                    checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED)) {

            requestPermissions(PERMISSIONS, 1)
        }

        MethodChannel(flutterView, MOVIE_MAKER_CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "Bipin - method: ${call.method}")
            if (call.method == "getBatteryLevel") {
                val batteryLevel = batteryLevel

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "getVideoThumbnail") {
                val videoPath = call.argument<String>("videoPath")
                Log.d("MainActivity", "Bipin - VideoPath: $videoPath")
                val bytes = getVideoThumbnail(videoPath)

                if (bytes != null && bytes.isNotEmpty()) {
                    result.success(bytes)
                } else {
                    result.error("UNAVAILABLE", "Video thumbnail not available.", null)
                }
            } else if (call.method == "createMovie") {
                val videoPaths = call.argument<List<String>>("videoPaths")
                Log.d("MainActivity", "Bipin - VideoPaths: $videoPaths")
                val movieVideoPath = VideoJoiner.createMovie(this, videoPaths)

                if (movieVideoPath != null) {
                    result.success(movieVideoPath)
                } else {
                    result.error("UNAVAILABLE", "Movie creation failed.", null)
                }
            } else if (call.method == "startMovie") {
                val moviePath = call.argument<String>("moviePath")
                Log.d("MainActivity", "Bipin - moviePath: $moviePath")
                try {
                    showMovie(moviePath)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Movie creation failed.", e)
                }
            } else {
                result.notImplemented()
            }
        }

    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getVideoThumbnail(videoPath: String): ByteArray? {
        val bmp = ThumbnailUtils.createVideoThumbnail(
            videoPath, MediaStore.Video.Thumbnails.FULL_SCREEN_KIND
        )
        val stream = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.PNG, 100, stream)
        val byteArray = stream.toByteArray()
        bmp.recycle()
        return byteArray
    }

    companion object {
        val PERMISSIONS = arrayOf(
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE
        )
        private val MOVIE_MAKER_CHANNEL = "moviemaker.devunion.com/movie_maker_channel"

    }
}
