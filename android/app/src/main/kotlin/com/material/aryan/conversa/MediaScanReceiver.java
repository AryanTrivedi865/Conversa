package com.material.aryan.conversa;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;

import java.io.File;

public class MediaScanReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String filePath = intent.getStringExtra("file_path");
        if (filePath != null) {
            File file = new File(filePath);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                MediaScannerConnection.scanFile(context,
                        new String[]{file.getAbsolutePath()}, null,
                        (path, uri) -> {
                        });
            } else {
                Uri contentUri = Uri.fromFile(file);
                context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, contentUri));
            }
        }
    }
}

