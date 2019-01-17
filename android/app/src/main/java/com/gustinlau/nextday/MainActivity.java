package com.gustinlau.nextday;

import android.os.Bundle;

import com.gustinlau.nextday.plugins.LocalPluginRegistrant;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        LocalPluginRegistrant.registerWith(this);
    }
}
