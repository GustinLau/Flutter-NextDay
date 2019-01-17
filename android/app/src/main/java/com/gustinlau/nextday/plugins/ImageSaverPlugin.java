package com.gustinlau.nextday.plugins;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;

import com.tbruyelle.rxpermissions2.Permission;
import com.tbruyelle.rxpermissions2.RxPermissions;

import java.io.File;
import java.io.FileOutputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.reactivex.functions.Consumer;

public class ImageSaverPlugin implements MethodChannel.MethodCallHandler {
    private static final String ID = "com.gustinlau.nextday/image_saver";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), ID);
        channel.setMethodCallHandler(new ImageSaverPlugin(registrar, channel));
    }

    private PluginRegistry.Registrar registrar;
    private RxPermissions rxPermissions; // where this is an Activity or Fragment instance

    private ImageSaverPlugin(PluginRegistry.Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;
        this.rxPermissions = new RxPermissions(registrar.activity());
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        if (call.method.equals("saveImageToAlbum")) {
            final byte[] images = (byte[]) call.arguments;
            rxPermissions
                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(new Consumer<Boolean>() {
                        @Override
                        public void accept(Boolean granted) throws Exception {
                            if (granted) { // Always true pre-M
                                // I can control the camera now
                                result.success(saveImage(BitmapFactory.decodeByteArray(images, 0, images.length)));
                            } else {
                                // Oups permission denied
                                result.error("no permission", null, null);
                            }
                        }
                    });
        } else {
            result.notImplemented();
        }
    }

    private int saveImage(Bitmap bmp) {
        if (bmp == null) {
            return 0;
        }
        try {
            String storePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + getApplicationName();
            File appDir = new File(storePath);
            if (!appDir.exists()) {
                appDir.mkdirs();
            }
            String fileName = System.currentTimeMillis() + ".png";
            File file = new File(appDir, fileName);
            FileOutputStream fos = new FileOutputStream(file);
            boolean isSuccess = bmp.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
            fos.close();
            Uri uri = Uri.fromFile(file);
            registrar.activeContext().getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            return isSuccess ? 1 : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }


    private String getApplicationName() {
        Context context = registrar.activeContext().getApplicationContext();
        ApplicationInfo ai = null;
        try {
            ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        String appName;
        if (ai != null) {
            CharSequence charSequence = context.getPackageManager().getApplicationLabel(ai);
            appName = new StringBuilder(charSequence.length()).append(charSequence).toString();
        } else {
            appName = "image_gallery_saver";
        }
        return appName;
    }
}
