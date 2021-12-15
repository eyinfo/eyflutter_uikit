package com.basic.eyflutter_uikit;

import com.basic.eyflutter_core.channel.ChannelPlugin;
import com.basic.eyflutter_uikit.subscribe.ToasterSubscribe;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * EyflutterUikitPlugin
 */
public class EyflutterUikitPlugin implements FlutterPlugin {

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        ChannelPlugin.getInstance().putSubscribe(UiKitConstants.toastMethodName, new ToasterSubscribe());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        ChannelPlugin.getInstance().removeSubScribe(UiKitConstants.toastMethodName);
    }
}
