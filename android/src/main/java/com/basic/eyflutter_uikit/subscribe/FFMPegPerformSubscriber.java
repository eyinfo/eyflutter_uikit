package com.basic.eyflutter_uikit.subscribe;

import com.basic.eyflutter_uikit.enums.FinishStatus;
import com.basic.eyflutter_uikit.events.OnFFMPegPerformListener;

import io.microshow.rxffmpeg.RxFFmpegSubscriber;

public class FFMPegPerformSubscriber extends RxFFmpegSubscriber {

    private OnFFMPegPerformListener onFFMPegPerformListener = null;

    public FFMPegPerformSubscriber(OnFFMPegPerformListener listener) {
        this.onFFMPegPerformListener = listener;
        if (listener != null) {
            listener.onStart();
        }
    }

    @Override
    public void onFinish() {
        if (onFFMPegPerformListener != null) {
            onFFMPegPerformListener.onFinish(FinishStatus.success);
        }
    }

    @Override
    public void onProgress(int progress, long progressTime) {
        if (onFFMPegPerformListener != null) {
            onFFMPegPerformListener.onProgress(progress, progressTime);
        }
    }

    @Override
    public void onCancel() {
        if (onFFMPegPerformListener != null) {
            onFFMPegPerformListener.onFinish(FinishStatus.cancel);
        }
    }

    @Override
    public void onError(String message) {
        if (onFFMPegPerformListener != null) {
            onFFMPegPerformListener.onFinish(FinishStatus.error);
        }
    }
}
