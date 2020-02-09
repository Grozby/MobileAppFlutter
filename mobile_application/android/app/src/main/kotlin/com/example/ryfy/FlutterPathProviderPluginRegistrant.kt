package com.example.ryfy


import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.pathprovider.PathProviderPlugin


class FlutterPathProviderPluginRegistrant {

    companion object {
        fun registerWith(registry: PluginRegistry) {
            if (alreadyRegisteredWith(registry)) {
                return
            }
            PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"))
        }

        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key = FlutterPathProviderPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}