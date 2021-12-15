package com.basic.eyflutter_uikit;

import android.text.TextUtils;

import com.basic.eyflutter_core.channel.ChannelPlugin;
import com.basic.eyflutter_core.channel.OnMethodResultCall;

public class Loadings {

    /// 显示loading
    public static void show(String text) {
        if (TextUtils.isEmpty(text)) {
            return;
        }
        ChannelPlugin.getInstance().invokeMethod(UiKitConstants.showLoadingsMethodName, text, new OnMethodResultCall<Object>() {
            @Override
            public void onMethodSuccess(Object arguments, Object decoder) {
                //收到消息发送成功
            }
        });
    }

    public static void dismiss(String overlayKey) {
        ChannelPlugin.getInstance().invokeMethod(UiKitConstants.dismissLoadingsMethodName, overlayKey, new OnMethodResultCall<Object>() {
            @Override
            public void onMethodSuccess(Object arguments, Object decoder) {
                //收到消息发送成功
            }
        });
    }

    public static void dismiss() {
        Loadings.dismiss("");
    }
}
