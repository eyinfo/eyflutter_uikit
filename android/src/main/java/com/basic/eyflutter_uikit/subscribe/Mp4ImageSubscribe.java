package com.basic.eyflutter_uikit.subscribe;

import android.graphics.Bitmap;

import com.basic.eyflutter_core.channel.OnDistributionSubscribe;
import com.basic.eyflutter_uikit.FFMPegCropOnlineFrameImage;
import com.basic.eyflutter_uikit.events.OnImageCropCall;
import com.cloud.eyutils.utils.ConvertUtils;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;

public class Mp4ImageSubscribe extends OnDistributionSubscribe {

    private List<String> verifyList = null;

    public Mp4ImageSubscribe(List<String> verifyList) {
        this.verifyList = verifyList;
    }

    @Override
    public void onSubscribe(MethodChannel.Result result, HashMap<String, Object> arguments) {
        String videoUrl = ConvertUtils.toString(arguments.get("imageName"));
        FFMPegCropOnlineFrameImage frameImage = new FFMPegCropOnlineFrameImage();
        frameImage.setOnImageCropCall(new Mp4ImageCropSubscriber(result));
        frameImage.start(3, videoUrl, verifyList);
    }

    private class Mp4ImageCropSubscriber implements OnImageCropCall {

        private MethodChannel.Result result;

        public Mp4ImageCropSubscriber(MethodChannel.Result result) {
            this.result = result;
        }

        @Override
        public void onVideoFrameImage(File imageFile) {
            Bitmap bitmap = ConvertUtils.toBitmap(imageFile.getAbsolutePath());
            try {
                result.success(ConvertUtils.toByteArray(bitmap));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
