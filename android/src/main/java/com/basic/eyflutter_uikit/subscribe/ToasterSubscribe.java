package com.basic.eyflutter_uikit.subscribe;

import android.text.TextUtils;
import android.view.Gravity;

import com.basic.eyflutter_core.channel.OnDistributionSubscribe;
import com.cloud.eyutils.toasty.ToastUtils;
import com.cloud.eyutils.utils.ConvertUtils;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

public class ToasterSubscribe extends OnDistributionSubscribe {
    @Override
    public void onSubscribe(MethodChannel.Result result, HashMap<String, Object> arguments) {
        String gravity = ConvertUtils.toString(arguments.get("gravity"));
        String msg = ConvertUtils.toString(arguments.get("msg"));
        if (TextUtils.equals(gravity, "TOP")) {
            ToastUtils.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.TOP, 0, 160);
        } else if (TextUtils.equals(gravity, "CENTER")) {
            ToastUtils.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.CENTER, 0, 0);
        } else {
            ToastUtils.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM, 0, 160);
        }
        ToastUtils.show(msg);
    }
}
