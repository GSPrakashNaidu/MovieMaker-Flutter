package com.devunion.moviemaker.util

import android.annotation.TargetApi
import android.content.Context
import android.os.Environment
import android.util.Log
import android.widget.Toast
import com.coremedia.iso.IsoFile
import com.coremedia.iso.boxes.MetaBox
import com.googlecode.mp4parser.FileDataSourceImpl
import com.googlecode.mp4parser.authoring.Movie
import com.googlecode.mp4parser.authoring.Track
import com.googlecode.mp4parser.authoring.builder.DefaultMp4Builder
import com.googlecode.mp4parser.authoring.container.mp4.MovieCreator
import com.googlecode.mp4parser.authoring.tracks.AppendTrack
import java.io.File
import java.io.RandomAccessFile
import java.util.Date

object VideoJoiner {

    private fun getMetaBoxVideos(paths: List<String>): List<String> {
        val metaboxEnabledMedia = mutableListOf<String>()
        paths.forEach { path ->
            val isoFile = IsoFile(path)
            val movieBox = isoFile.movieBox
            if (movieBox.getBoxes(MetaBox::class.java).isNotEmpty()) {
                metaboxEnabledMedia.add(path)
            }
            isoFile.close()

        }
        return metaboxEnabledMedia.toList()

    }


    @TargetApi(21)
    public fun createMovie(context: Context, paths: List<String>): String? {
        Toast.makeText(context, "Creating Movie. Please wait!", Toast.LENGTH_LONG).show()
        val metaboxEnabledMediaPaths = getMetaBoxVideos(paths)
        val videoTracks = mutableListOf<Track>()
        val audioTracks = mutableListOf<Track>()
        metaboxEnabledMediaPaths.forEach { path ->
            Log.d("VideoJoiner", "Bipin - path: $path")
            val fileDataSourceImpl = FileDataSourceImpl(path)
            val movie = MovieCreator.build(fileDataSourceImpl)
            movie.tracks.forEach {
                if (it.handler == "vide") {
                    videoTracks.add(it)
                } else if (it.handler == "soun") {
                    audioTracks.add(it)
                }
            }
        }
        val finalMovie = Movie()

        if (audioTracks.isNotEmpty()) finalMovie.addTrack(AppendTrack(*audioTracks.toTypedArray()))
        if (videoTracks.isNotEmpty()) finalMovie.addTrack(AppendTrack(*videoTracks.toTypedArray()))

        val container = DefaultMp4Builder().build(finalMovie)
        val file = File(
            Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_MOVIES
            ).absolutePath, "MM-${Date().time}.mp4"
        )
        val fileChannel = RandomAccessFile(file, "rw").channel
        container.writeContainer(fileChannel)
        fileChannel.close()
        return file.absolutePath
    }
}