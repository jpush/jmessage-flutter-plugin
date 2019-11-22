package com.jiguang.jmessageflutter;

import android.graphics.Bitmap;
import android.os.Environment;

//import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

import cn.jpush.im.android.api.JMessageClient;
import cn.jpush.im.android.api.callback.GetUserInfoCallback;
import cn.jpush.im.android.api.content.MessageContent;
import cn.jpush.im.android.api.model.Conversation;
import cn.jpush.im.android.api.model.Message;
import cn.jpush.im.android.api.options.MessageSendingOptions;
import cn.jpush.im.api.BasicCallback;

import static com.jiguang.jmessageflutter.JsonUtils.JsonToMessage;
import io.flutter.plugin.common.MethodChannel.Result;

class JMessageUtils {

    private static JSONObject getErrorObject(int code, String description) throws JSONException {
        JSONObject error = new JSONObject();
        error.put("code", code);
        error.put("description", description);
        return error;
    }

    static void handleResult(int status, String desc, Result callback) {
        if (status == 0) {
            callback.success(null);
        } else {
            callback.error(Integer.toString(status), desc, "");
        }
    }

    static void handleResult(HashMap returnObject, int status, String desc, Result callback) {
        if (status == 0) {
            callback.success(returnObject);
        } else {
            callback.error(Integer.toString(status), desc, "");
        }
    }

    static void handleResult(List returnObject, int status, String desc, Result callback) {
        if (status == 0) {
            callback.success(returnObject);
        } else {
            callback.error(Integer.toString(status), desc, "");
        }
    }

    static MessageSendingOptions toMessageSendingOptions(JSONObject json) throws JSONException {
        MessageSendingOptions messageSendingOptions = new MessageSendingOptions();

        if (json.has("isShowNotification") && !json.isNull("isShowNotification")) {
            messageSendingOptions.setShowNotification(json.getBoolean("isShowNotification"));
        }

        if (json.has("isRetainOffline") && !json.isNull("isRetainOffline")) {
            messageSendingOptions.setRetainOffline(json.getBoolean("isRetainOffline"));
        }

        if (json.has("isCustomNotificationEnabled") && !json.isNull("isCustomNotificationEnabled")) {
            messageSendingOptions.setCustomNotificationEnabled(json.getBoolean("isCustomNotificationEnabled"));
        }

        if (json.has("notificationTitle") && !json.isNull("notificationTitle")) {
            messageSendingOptions.setNotificationTitle(json.getString("notificationTitle"));
        }

        if (json.has("notificationText") && !json.isNull("notificationText")) {
            messageSendingOptions.setNotificationText(json.getString("notificationText"));
        }
        if (json.has("needReadReceipt") && !json.isNull("needReadReceipt")) {
            messageSendingOptions.setNeedReadReceipt(json.getBoolean("needReadReceipt"));
        }

        return messageSendingOptions;
    }

    static void getUserInfo(JSONObject params, GetUserInfoCallback callback) throws JSONException {
        String username, appKey;

        username = params.getString("username");
        appKey = params.has("appKey") ? params.getString("appKey") : "";

        JMessageClient.getUserInfo(username, appKey, callback);
    }

    /**
     * 创建会话对象，如果本地以及存在，则直接返回而不会重新创建。
     */
    static Conversation createConversation(JSONObject params) throws JSONException {
        String type = params.getString("type");
        Conversation conversation = null;

        if (type.equals("single")) {
            String username = params.getString("username");
            String appKey = params.has("appKey") ? params.getString("appKey") : "";
            conversation = Conversation.createSingleConversation(username, appKey);

        } else if (type.equals("group")) {
            String groupId = params.getString("groupId");
            conversation = Conversation.createGroupConversation(Long.parseLong(groupId));

        } else if (type.equals("chatRoom")) {
            long roomId = Long.parseLong(params.getString("roomId"));
            conversation = Conversation.createChatRoomConversation(roomId);
        }

        return conversation;
    }

    static Conversation getConversation(JSONObject params) throws JSONException {
        String type = params.getString("type");
        Conversation conversation = null;

        if (type.equals("single")) {
            String username = params.getString("username");
            String appKey = params.has("appKey") ? params.getString("appKey") : "";
            conversation = JMessageClient.getSingleConversation(username, appKey);

        } else if (type.equals("group")) {
            String groupId = params.getString("groupId");
            conversation = JMessageClient.getGroupConversation(Long.parseLong(groupId));

        } else if (type.equals("chatRoom")) {
            long roomId = Long.parseLong(params.getString("roomId"));
            conversation = JMessageClient.getChatRoomConversation(roomId);
        }

        return conversation;
    }

    static Message getMessage(JSONObject params) throws JSONException {
        if (params.has("messageId")) { // 代表 JS 层为显式传入所需的参数。
            Conversation conversation = getConversation(params);
            if (conversation == null) {
                return null;
            }

            Message msg;
            String messageId = params.getString("messageId");

            Long b = Long.parseLong(messageId);
            if (b > Integer.MAX_VALUE) {
                msg = conversation.getMessage(Long.parseLong(messageId));
            }else {
                msg = conversation.getMessage(Integer.parseInt(messageId));
            }

            return msg;
        } else if (params.has("id")) { // 代表 JS 层传入的是 Message 对象。
            return JsonToMessage(params);
        }

        return null;
    }

    static void sendMessage(Conversation conversation, MessageContent content, MessageSendingOptions options,
            final Result callback) {
        final Message msg = conversation.createSendMessage(content);
        msg.setOnSendCompleteCallback(new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                if (status == 0) {
                    HashMap json = JsonUtils.toJson(msg);
                    handleResult(json, status, desc, callback);
                } else {
                    handleResult(status, desc, callback);
                }
            }
        });

        if (options == null) {
            JMessageClient.sendMessage(msg);
        } else {
            JMessageClient.sendMessage(msg, options);
        }
    }

    static String storeImage(Bitmap bitmap, String filename, String pkgName) {
        File avatarFile = new File(getAvatarPath(pkgName));
        if (!avatarFile.exists()) {
            avatarFile.mkdirs();
        }

        String filePath = getAvatarPath(pkgName) + filename + ".png";
        try {
            FileOutputStream fos = new FileOutputStream(filePath);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos);
            bos.flush();
            bos.close();
            return filePath;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return "";
        } catch (IOException e) {
            e.printStackTrace();
            return "";
        }
    }

    static String getFilePath(String pkgName) {
        return Environment.getExternalStorageDirectory() + "/" + pkgName;
    }

    static String getAvatarPath(String pkgName) {
        return getFilePath(pkgName) + "/images/avatar/";
    }

    static String getFileExtension(String path) {
        return path.substring(path.lastIndexOf("."));
    }

    /**
     * 根据绝对路径或 URI 获得本地图片。
     *
     * @param path 文件路径或者 URI。
     * @return 文件对象。
     */
    static File getFile(String path) throws FileNotFoundException {
        File file = new File(path); // if it is a absolute path

        if (!file.isFile()) {
            URI uri = URI.create(path); // if it is a uri.
            file = new File(uri);
        }

        if (!file.exists() || !file.isFile()) {
            throw new FileNotFoundException();
        }

        return file;
    }

}
