package com.basic.eyflutter_uikit;

import android.text.TextUtils;

import com.basic.eyflutter_core.enums.DirectoryNames;
import com.basic.eyflutter_uikit.enums.FinishStatus;
import com.basic.eyflutter_uikit.events.OnFFMPegPerformListener;
import com.basic.eyflutter_uikit.events.OnImageCropCall;
import com.basic.eyflutter_uikit.subscribe.FFMPegPerformSubscriber;
import com.cloud.eyutils.HandlerManager;
import com.cloud.eyutils.encryption.Md5Utils;
import com.cloud.eyutils.events.RunnableParamsN;
import com.cloud.eyutils.observable.ObservableComponent;
import com.cloud.eyutils.storage.files.StorageUtils;

import java.io.File;
import java.util.List;

import io.microshow.rxffmpeg.RxFFmpegCommandList;
import io.microshow.rxffmpeg.RxFFmpegInvoke;

//截取FFMPeg视频帧图片
public class FFMPegCropOnlineFrameImage {

    private FFMPegPerformSubscriber videoSubscriber;
    private FFMPegPerformSubscriber imageSubscriber;
    private OnImageCropCall onImageCropCall;
    private int endTime;
    private String url;
    private File localFile;
    private File imageFile;
    private List<String> verifyList;
    private String sign;

    public void setOnImageCropCall(OnImageCropCall call) {
        this.onImageCropCall = call;
    }

    /**
     * 开始截取
     *
     * @param endTime    截止时间(单位秒)
     * @param url        视频地址(支持http/https/rtmp/hls/m3u8...)
     * @param verifyList 签名校验集合
     */
    public void start(int endTime, String url, List<String> verifyList) {
        this.endTime = endTime;
        this.url = url;
        this.verifyList = verifyList;
        if (endTime <= 0 || TextUtils.isEmpty(url)) {
            return;
        }
        sign = Md5Utils.encrypt(url);
        File dir = StorageUtils.getDir(DirectoryNames.images.name());
        imageFile = new File(dir, String.format("%s.png", sign));
        if (imageFile.exists() && onImageCropCall != null) {
            onImageCropCall.onVideoFrameImage(imageFile);
            return;
        }
        if (verifyList.contains(sign)) {
            //表示仍在截取视频或图片中
            return;
        }
        verifyList.add(sign);
        dir = StorageUtils.getDir(DirectoryNames.videos.name());
        localFile = new File(dir, String.format("%s.mp4", sign));
        videoSubscriber = new FFMPegPerformSubscriber(videoCaptureCall);
    }

    private String[] getVideoCommands() {
        RxFFmpegCommandList commandList = new RxFFmpegCommandList();
        commandList.append("-i");
        commandList.append(url);
        commandList.append("-t");
        commandList.append(String.valueOf(endTime));
        commandList.append("-preset");
        commandList.append("superfast");
        commandList.append(localFile.getAbsolutePath());
        return commandList.build();
    }

    private OnFFMPegPerformListener videoCaptureCall = new OnFFMPegPerformListener() {
        @Override
        public void onStart() {
            videoCaptureTask.build();
        }

        @Override
        public void onProgress(int progress, long progressTime) {

        }

        @Override
        public void onFinish(FinishStatus status) {
            if (videoSubscriber != null && !videoSubscriber.isDisposed()) {
                videoSubscriber.dispose();
            }
            if (status == FinishStatus.success) {
                imageCaptureTask.build();
            } else {
                verifyList.remove(sign);
            }
        }
    };

    private ObservableComponent<Object, Object> videoCaptureTask = new ObservableComponent<Object, Object>() {
        @Override
        protected Object subscribeWith(Object[] objects) throws Exception {
            String[] videoCommands = getVideoCommands();
            RxFFmpegInvoke.getInstance().runCommandRxJava(videoCommands).subscribe(videoSubscriber);
            return super.subscribeWith(objects);
        }
    };

    private String getCommandTimeFormat() {
        StringBuilder timerBuilder = new StringBuilder();
        int hours = (endTime - 1) / 3600;
        if (hours > 60) {
            hours = 60;
        }
        if (hours < 10) {
            timerBuilder.append(String.format("0%s", hours));
        } else {
            timerBuilder.append(hours);
        }
        timerBuilder.append(":");
        int diff = ((endTime - 1) - hours * 3600);
        int minutes = diff / 60;
        if (minutes > 60) {
            minutes = 60;
        }
        if (minutes < 10) {
            timerBuilder.append(String.format("0%s", minutes));
        } else {
            timerBuilder.append(minutes);
        }
        timerBuilder.append(":");
        int seconds = (diff - minutes * 60);
        if (seconds < 10) {
            timerBuilder.append(String.format("0%s", seconds));
        } else {
            timerBuilder.append(seconds);
        }
        return timerBuilder.toString();
    }

    private String[] getImageCommands() {
        RxFFmpegCommandList commandList = new RxFFmpegCommandList();
        commandList.append("-i");
        commandList.append(localFile.getAbsolutePath());
        commandList.append("-f");
        commandList.append("image2");
        commandList.append("-ss");
        commandList.append(getCommandTimeFormat());
        commandList.append("-vframes");
        commandList.append("1");
        commandList.append("-preset");
        commandList.append("superfast");
        commandList.append(imageFile.getAbsolutePath());
        return commandList.build();
    }

    private ObservableComponent<Object, Object> imageCaptureTask = new ObservableComponent<Object, Object>() {
        @Override
        protected Object subscribeWith(Object[] objects) throws Exception {
            imageSubscriber = new FFMPegPerformSubscriber(imageCaptureCall);
            String[] imageCommands = getImageCommands();
            RxFFmpegInvoke.getInstance().runCommandRxJava(imageCommands).subscribe(imageSubscriber);
            return super.subscribeWith(objects);
        }
    };

    private OnFFMPegPerformListener imageCaptureCall = new OnFFMPegPerformListener() {
        @Override
        public void onStart() {

        }

        @Override
        public void onProgress(int progress, long progressTime) {

        }

        @Override
        public void onFinish(FinishStatus status) {
            if (imageSubscriber != null && !imageSubscriber.isDisposed()) {
                imageSubscriber.dispose();
            }
            if (localFile.exists()) {
                StorageUtils.forceDelete(localFile);
            }
            if (status == FinishStatus.success && onImageCropCall != null) {
                HandlerManager.getInstance().post(new RunnableParamsN<Object>() {
                    @Override
                    public void run(Object... objects) {
                        onImageCropCall.onVideoFrameImage(imageFile);
                    }
                });
            } else {
                if (imageFile.exists()) {
                    StorageUtils.forceDelete(imageFile);
                }
                verifyList.remove(sign);
            }
        }
    };
}
