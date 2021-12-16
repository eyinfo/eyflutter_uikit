package com.basic.eyflutter_uikit.events;

import com.basic.eyflutter_uikit.enums.FinishStatus;

//下载视频监听
public interface OnFFMPegPerformListener {
    void onStart();

    void onProgress(int progress, long progressTime);

    void onFinish(FinishStatus status);
}
