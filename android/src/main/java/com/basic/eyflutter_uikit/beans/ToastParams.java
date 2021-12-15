package com.basic.eyflutter_uikit.beans;

public class ToastParams {
    private String msg;
    private String gravity;
    private String duration;

    public String getMsg() {
        return msg == null ? "" : msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getGravity() {
        return gravity == null ? "" : gravity;
    }

    public void setGravity(String gravity) {
        this.gravity = gravity;
    }

    public String getDuration() {
        return duration == null ? "" : duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }
}
