package com.jiguang.jmessageflutter;

//import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import cn.jpush.im.android.api.ChatRoomManager;
import cn.jpush.im.android.api.JMessageClient;
import cn.jpush.im.android.api.callback.RequestCallback;
import cn.jpush.im.android.api.model.ChatRoomInfo;
import cn.jpush.im.android.api.model.Conversation;
import cn.jpush.im.api.BasicCallback;

import static com.jiguang.jmessageflutter.JmessageFlutterPlugin.ERR_CODE_PARAMETER;
import static com.jiguang.jmessageflutter.JmessageFlutterPlugin.ERR_MSG_PARAMETER;
import static com.jiguang.jmessageflutter.JMessageUtils.handleResult;
import static com.jiguang.jmessageflutter.JsonUtils.toJson;

import io.flutter.plugin.common.MethodChannel.Result;


/**
 * 处理聊天室相关 API。
 */

class ChatRoomHandler {

    static void getChatRoomInfoListOfApp(JSONObject data, final Result callback) {
        int start, count;
        try {

            start = data.getInt("start");
            count = data.getInt("count");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }

        ChatRoomManager.getChatRoomListByApp(start, count, new RequestCallback<List<ChatRoomInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<ChatRoomInfo> chatRoomInfos) {
                if (status != 0) {
                    handleResult(status, desc, callback);
                    return;
                }

                ArrayList jsonArr = new ArrayList();
                for (ChatRoomInfo chatroomInfo : chatRoomInfos) {
                    jsonArr.add(toJson(chatroomInfo));
                }
                callback.success(jsonArr);
            }
        });
    }

    static void getChatRoomInfoListOfUser(JSONObject data, final Result callback) {
        ChatRoomManager.getChatRoomListByUser(new RequestCallback<List<ChatRoomInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<ChatRoomInfo> chatRoomInfoList) {
                if (status != 0) {
                    handleResult(status, desc, callback);
                    return;
                }

                ArrayList jsonArr = new ArrayList();
                for (ChatRoomInfo chatroomInfo : chatRoomInfoList) {
                    jsonArr.add(toJson(chatroomInfo));
                }
                callback.success(jsonArr);
            }
        });
    }

    static void getChatRoomInfoListById(JSONObject data, final Result callback) {
        Set<Long> roomIds = new HashSet<Long>(); // JS 层为了和 iOS 统一，因此 roomId 类型为 String，在原生做转换。

        try {

            JSONArray roomIdArr = data.getJSONArray("roomIds");

            for (int i = 0; i < roomIdArr.length(); i++) {
                roomIds.add(Long.valueOf(roomIdArr.getString(i)));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }

        ChatRoomManager.getChatRoomInfos(roomIds, new RequestCallback<List<ChatRoomInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<ChatRoomInfo> chatRoomInfos) {
                if (status != 0) {
                    handleResult(status, desc, callback);
                    return;
                }

                ArrayList jsonArr = new ArrayList();
                for (ChatRoomInfo chatroomInfo : chatRoomInfos) {
                    jsonArr.add(toJson(chatroomInfo));
                }
                callback.success(jsonArr);
            }
        });
    }

    static void getChatRoomOwner(JSONObject data, final Result callback) {
        final long roomId;

        try {
            roomId = Long.parseLong(data.getString("roomId"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }

        Set<Long> roomIds = new HashSet<Long>();
        roomIds.add(roomId);

        ChatRoomManager.getChatRoomInfos(roomIds, new RequestCallback<List<ChatRoomInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<ChatRoomInfo> chatRoomInfoList) {
                if (status != 0) {
                    handleResult(status, desc, callback);
                    return;
                }

                HashMap chatroomInfoJson = toJson(chatRoomInfoList.get(0));
                callback.success(chatroomInfoJson);
            }
        });
    }

    static void enterChatRoom(JSONObject data, final Result callback) {
        final long roomId;

        try {
            roomId = Long.parseLong(data.getString("roomId"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }

        ChatRoomManager.enterChatRoom(roomId, new RequestCallback<Conversation>() {
            @Override
            public void gotResult(int status, String desc, Conversation conversation) {
                if (status != 0) {
                    handleResult(status, desc, callback);
                    return;
                }

//                HashMap result = new HashMap();
//                result.put("roomId", roomId);
//                result.put("conversation", toJson(conversation));
                callback.success(toJson(conversation));
            }
        });
    }

    static void exitChatRoom(JSONObject data, final Result callback) {
        final long roomId;

        try {
            roomId = Long.parseLong(data.getString("roomId"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }

        ChatRoomManager.leaveChatRoom(roomId, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                if (status == 0) { // success
                    callback.success(null);
                } else {
                    handleResult(status, desc, callback);
                }
            }
        });
    }

    static void getChatRoomConversationList(JSONObject data, final Result callback) {
        List<Conversation> conversations = JMessageClient.getChatRoomConversationList();

        ArrayList result = new ArrayList();

        if (conversations == null) {
            callback.success(result);
            return;
        }

        for (Conversation con : conversations) {
            result.add(toJson(con));
        }
        callback.success(result);
    }

}
