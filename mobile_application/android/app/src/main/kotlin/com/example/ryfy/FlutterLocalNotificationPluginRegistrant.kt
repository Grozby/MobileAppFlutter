package com.example.ryfy

import io.flutter.plugin.common.PluginRegistry
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin


class FlutterLocalNotificationPluginRegistrant {

    companion object {
        fun registerWith(registry: PluginRegistry) {
            if (alreadyRegisteredWith(registry)) {
                return
            }
            FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
        }

        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key = FlutterLocalNotificationPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}