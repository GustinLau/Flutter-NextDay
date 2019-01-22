package com.gustinlau.nextday.plugins;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Environment;

import com.tbruyelle.rxpermissions2.RxPermissions;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.reactivex.functions.Consumer;

public class CacheManagerPlugin implements MethodChannel.MethodCallHandler {

    private static final String ID = "com.gustinlau.nextday/cache_manager";

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), ID);
        channel.setMethodCallHandler(new CacheManagerPlugin(registrar, channel));
    }

    private PluginRegistry.Registrar registrar;
    private RxPermissions rxPermissions;

    private CacheManagerPlugin(PluginRegistry.Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;
        this.rxPermissions = new RxPermissions(registrar.activity());
        channel.setMethodCallHandler(this);
    }


    @SuppressLint("CheckResult")
    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        switch (call.method) {
            case "cleanCache": {
                rxPermissions
                        .request(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE)
                        .subscribe(new Consumer<Boolean>() {
                            @Override
                            public void accept(Boolean granted)throws Exception{
                                if (granted) {
                                    clearAllCache();
                                    result.success(1);
                                } else {
                                    result.success(0);
                                }
                            }
                        });
                break;
            }
            case "cacheSize": {
                try {
                    result.success(getTotalCacheSize());
                } catch (Exception e) {
                    result.success(0);
                }
                break;
            }
            default:
                result.notImplemented();
        }
    }

    private long getTotalCacheSize() {
        Context context = registrar.activeContext().getApplicationContext();
        long cacheSize = getFolderSize(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            cacheSize += getFolderSize(context.getExternalCacheDir());
        }
        return cacheSize;
    }

    private void clearAllCache() {
        Context context = registrar.activeContext().getApplicationContext();
        deleteDir(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            deleteDir(context.getExternalCacheDir());
        }
    }

    private boolean deleteDir(File dir) {
        if (dir != null && dir.isDirectory()) {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++) {
                boolean success = deleteDir(new File(dir, children[i]));
                if (!success) {
                    return false;
                }
            }
        }
        return dir.delete();
    }

    private long getFolderSize(File file){
        long size = 0;
        try {
            File[] fileList = file.listFiles();
            for (int i = 0; i < fileList.length; i++) {
                // 如果下面还有文件
                if (fileList[i].isDirectory()) {
                    size = size + getFolderSize(fileList[i]);
                } else {
                    size = size + fileList[i].length();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }

}
