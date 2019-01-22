package com.gustinlau.nextday.plugins;

import io.flutter.plugin.common.PluginRegistry;

public class LocalPluginRegistrant {
    public static void registerWith(PluginRegistry registry) {
        if (alreadyRegisteredWith(registry)) {
            return;
        }
        CacheManagerPlugin.registerWith(registry.registrarFor(" com.gustinlau.nextday.plugins.CacheManagerPlugin"));
        SharePlugin.registerWith(registry.registrarFor(" com.gustinlau.nextday.plugins.SharePlugin"));
    }

    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
        final String key = LocalPluginRegistrant.class.getCanonicalName();
        if (registry.hasPlugin(key)) {
            return true;
        }
        registry.registrarFor(key);
        return false;
    }
}
