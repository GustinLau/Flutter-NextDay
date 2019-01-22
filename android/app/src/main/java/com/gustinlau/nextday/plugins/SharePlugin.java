package com.gustinlau.nextday.plugins;

import android.Manifest;
import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;

import com.tbruyelle.rxpermissions2.RxPermissions;

import java.io.File;
import java.io.FileOutputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.reactivex.functions.Consumer;

public class SharePlugin implements MethodChannel.MethodCallHandler {

    private static final String ID = "com.gustinlau.nextday/share";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), ID);
        channel.setMethodCallHandler(new SharePlugin(registrar, channel));
    }

    private PluginRegistry.Registrar registrar;
    private RxPermissions rxPermissions;

    private SharePlugin(PluginRegistry.Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;
        this.rxPermissions = new RxPermissions(registrar.activity());
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        if (call.method.equals("share")) {
            final byte[] images = (byte[]) call.arguments;
            rxPermissions
                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(new Consumer<Boolean>() {
                        @Override
                        public void accept(Boolean granted) throws Exception {
                            if (granted) {
                                result.success(share(BitmapFactory.decodeByteArray(images, 0, images.length)));
                            } else {
                                result.success(0);
                            }
                        }
                    });
        } else {
            result.notImplemented();
        }
    }

    private int share(Bitmap bitmap) {
        String path = saveImage(bitmap);
        if (path != null) {
            Activity activity = registrar.activity();
            Intent shareIntent = new Intent();
            shareIntent.setAction(Intent.ACTION_SEND);//设置分享行为
            shareIntent.putExtra(Intent.EXTRA_STREAM, switchToUri(path));
            // 指定发送内容的类型 (MIME type)
            shareIntent.setType("image/png");
//        shareIntent.putExtra(Intent.EXTRA_SUBJECT, "添加分享内容标题");//添加分享内容标题
//        shareIntent.putExtra(Intent.EXTRA_TEXT, "添加分享内容");//添加分享内容
            //创建分享的Dialog
            activity.startActivity(Intent.createChooser(shareIntent, "分享"));
            return 1;
        } else {
            return 0;
        }
    }


    private String saveImage(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
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
            boolean success = bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
            fos.close();
            if (success) {
                Uri uri = Uri.fromFile(file);
                registrar.activeContext().getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
                return file.getAbsolutePath();
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    private Uri switchToUri(String path) {
        Context context = registrar.context();
        Cursor cursor = context.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{MediaStore.Images.Media._ID}, MediaStore.Images.Media.DATA + "=? ",
                new String[]{path}, null);
        Uri uri = null;

        if (cursor != null) {
            if (cursor.moveToFirst()) {
                int id = cursor.getInt(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
                Uri baseUri = Uri.parse("content://media/external/images/media");
                uri = Uri.withAppendedPath(baseUri, "" + id);
            }

            cursor.close();
        }

        if (uri == null) {
            ContentValues values = new ContentValues();
            values.put(MediaStore.Images.Media.DATA, path);
            uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
        }

        return uri;
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
            appName = "NextDay";
        }
        return appName;
    }

}
