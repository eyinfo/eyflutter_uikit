package com.basic.eyflutter_uikit;

import com.basic.eyflutter_core.channel.ChannelPlugin;
import com.basic.eyflutter_uikit.subscribe.Mp4ImageSubscribe;
import com.basic.eyflutter_uikit.subscribe.ToasterSubscribe;

import java.util.LinkedList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * EyflutterUikitPlugin
 */
public class EyflutterUikitPlugin implements FlutterPlugin {

    private List<String> verifyList = new LinkedList<>();

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        ChannelPlugin.getInstance().putSubscribe(UiKitConstants.toastMethodName, new ToasterSubscribe());
        ChannelPlugin.getInstance().putSubscribe(UiKitConstants.mp4ImageProviderMethodName, new Mp4ImageSubscribe(verifyList));
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        ChannelPlugin.getInstance().removeSubScribe(UiKitConstants.toastMethodName);
        ChannelPlugin.getInstance().removeSubScribe(UiKitConstants.mp4ImageProviderMethodName);
    }
}
