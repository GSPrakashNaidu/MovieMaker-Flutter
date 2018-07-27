package com.devunion.moviemaker.util

import android.app.Activity
import android.content.Intent
import android.net.Uri

fun Activity.showMovie(moviePath: String) {
    val intent = Intent(Intent.ACTION_VIEW)
    intent.setDataAndType(
        Uri.parse(moviePath),
        "video/*"
    )
    startActivity(intent)
}