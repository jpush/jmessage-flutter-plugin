package com.jiguang.jmessageflutter;

import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import cn.jmessage.support.google.gson.JsonElement;
import cn.jmessage.support.google.gson.JsonObject;
import cn.jmessage.support.google.gson.JsonParser;
import cn.jpush.im.android.api.JMessageClient;
import cn.jpush.im.android.api.content.CustomContent;
import cn.jpush.im.android.api.content.EventNotificationContent;
import cn.jpush.im.android.api.content.FileContent;
import cn.jpush.im.android.api.content.ImageContent;
import cn.jpush.im.android.api.content.LocationContent;
import cn.jpush.im.android.api.content.MessageContent;
import cn.jpush.im.android.api.content.TextContent;
import cn.jpush.im.android.api.content.VideoContent;
import cn.jpush.im.android.api.content.VoiceContent;
import cn.jpush.im.android.api.enums.ConversationType;
import cn.jpush.im.android.api.enums.MessageDirect;
import cn.jpush.im.android.api.model.ChatRoomInfo;
import cn.jpush.im.android.api.model.Conversation;
import cn.jpush.im.android.api.model.GroupBasicInfo;
import cn.jpush.im.android.api.model.GroupInfo;
import cn.jpush.im.android.api.model.GroupMemberInfo;
import cn.jpush.im.android.api.model.Message;
import cn.jpush.im.android.api.model.UserInfo;

class JsonUtils {

    static Map<String, String> fromJson(JSONObject jsonObject) {
        Map<String, String> map = new HashMap<String, String>();
        try {
            Iterator<String> keysItr = jsonObject.keys();
            while (keysItr.hasNext()) {
                String key = keysItr.next();
                String value = jsonObject.getString(key);
                map.put(key, value);
            }
        } catch (JSONException e) {

        }

        return map;
    }

    static HashMap toJson(Map<String, String> map) {
        HashMap result = new HashMap<String, Object>();
        Iterator<String> iterator = map.keySet().iterator();

//        JSONObject jsonObject = new JSONObject();
        while (iterator.hasNext()) {
            String key = iterator.next();

            result.put(key, map.get(key));
        }
        return result;
    }

    static HashMap toJson(final UserInfo userInfo) {
        if (userInfo == null) {
            return null;
        }

        final HashMap result = new HashMap<String, Object>();

        result.put("type", "user");

        if (null != userInfo.getGender()) {
            switch (userInfo.getGender()) {
                case male:
                    result.put("gender", "male");
                    break;
                case female:
                    result.put("gender", "female");
                    break;
                case unknown:
                    result.put("gender", "unknown");

            }
        } else {
            result.put("gender", "unknown");
        }

        result.put("username", userInfo.getUserName() != null ? userInfo.getUserName() : "");
        result.put("appKey", userInfo.getAppKey());
        result.put("nickname", userInfo.getNickname() != null ? userInfo.getNickname() : "");
        if (userInfo.getAvatarFile() != null) {
            result.put("avatarThumbPath", userInfo.getAvatarFile().getAbsolutePath());
        } else {
            result.put("avatarThumbPath", "");
        }

        if (userInfo.getBirthday() != 0) {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                String tsStr = sdf.format(userInfo.getBirthday());
                result.put("birthday", tsStr);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            long time = userInfo.getBirthday();
            result.put("birthday", "");
        }

        result.put("region", userInfo.getRegion() != null ? userInfo.getRegion() : "");
        result.put("signature", userInfo.getSignature() != null ? userInfo.getSignature() : "");
        result.put("address", userInfo.getAddress() != null ? userInfo.getAddress() : "");
        result.put("noteName", userInfo.getNotename() != null ? userInfo.getNotename() : "");
        result.put("noteText", userInfo.getNoteText() != null ? userInfo.getNoteText() : "");
        result.put("isNoDisturb", userInfo.getNoDisturb() == 1);
        result.put("isInBlackList", userInfo.getBlacklist() == 1);
        result.put("isFriend", userInfo.isFriend());
        Map<String, String> extras = userInfo.getExtras();
        result.put("extras", extras != null ? extras : new HashMap<String, String>());
        return result;
    }

    static HashMap toJson(GroupInfo groupInfo) {

        final HashMap result = new HashMap<String, Object>();

        result.put("type", "group");
        result.put("id", String.valueOf(groupInfo.getGroupID()));

        switch (groupInfo.getGroupType()) {
            case public_group: {
            }
            result.put("groupType", "public");
            break;
            default:
                result.put("groupType", "private");
                break;
        }

        result.put("name", groupInfo.getGroupName());
        result.put("desc", groupInfo.getGroupDescription());
        result.put("level", groupInfo.getGroupLevel());
        result.put("owner", groupInfo.getGroupOwner() != null ? groupInfo.getGroupOwner() : "");
        GroupMemberInfo memberInfo = groupInfo.getOwnerMemberInfo();
//
//        if (memberInfo != null) {
//
//            result.put("owner", memberInfo.getUserInfo().getUserName());
//        }

//        result.put("ownerAppKey", groupInfo.getOwnerMemberInfo().getUserInfo().getAppKey());
        result.put("ownerAppKey", groupInfo.getOwnerAppkey() != null ? groupInfo.getOwnerAppkey() : "");
        result.put("maxMemberCount", groupInfo.getMaxMemberCount());
        result.put("isNoDisturb", groupInfo.getNoDisturb() == 1);
        result.put("isBlocked", groupInfo.isGroupBlocked() == 1);

        return result;
    }

    static HashMap toJson(GroupMemberInfo groupMemberInfo) {

        final HashMap result = new HashMap<String, Object>();
        result.put("user", toJson(groupMemberInfo.getUserInfo()));
        result.put("groupNickname", groupMemberInfo.getNickName());

        if (groupMemberInfo.getType() == GroupMemberInfo.Type.group_owner) {
            result.put("memberType", "owner");
        } else if (groupMemberInfo.getType() == GroupMemberInfo.Type.group_keeper) {
            result.put("memberType", "admin");
        } else {
            result.put("memberType", "ordinary");
        }
        result.put("joinGroupTime", groupMemberInfo.getJoinGroupTime());

        return result;
    }

    static HashMap toJson(GroupBasicInfo groupInfo) {
        final HashMap result = new HashMap<String, Object>();
        result.put("type", "group");
        result.put("id", String.valueOf(groupInfo.getGroupID()));
        result.put("name", groupInfo.getGroupName());
        result.put("desc", groupInfo.getGroupDescription());
        result.put("level", groupInfo.getGroupLevel());
        result.put("avatarThumbPath", groupInfo.getAvatar());
        result.put("maxMemberCount", groupInfo.getMaxMemberCount());//String.valueOf(groupInfo.getMaxMemberCount())
        switch (groupInfo.getGroupType()) {
            case public_group: {
            }
            result.put("groupType", "public");
            break;
            default:
                result.put("groupType", "private");
                break;
        }

        return result;
    }

    static HashMap toJson(Message msg) {

        final HashMap result = new HashMap<String, Object>();

        result.put("id", String.valueOf(msg.getId())); // 本地数据库 id
        result.put("serverMessageId", String.valueOf(msg.getServerMessageId())); // 服务器端 id
        result.put("from", toJson(msg.getFromUser())); // 消息发送者

        boolean isSend = msg.getDirect().equals(MessageDirect.send);
        result.put("isSend", isSend); // 消息是否是由当前用户发出

        HashMap targetJson = null;
        switch (msg.getTargetType()) {
            case single:
                if (isSend) { // 消息发送
                    targetJson = toJson((UserInfo) msg.getTargetInfo());
                } else { // 消息接收
                    targetJson = toJson(JMessageClient.getMyInfo());
                }
                break;
            case group:
                targetJson = toJson((GroupInfo) msg.getTargetInfo());
                break;
            case chatroom:
                targetJson = toJson((ChatRoomInfo) msg.getTargetInfo());
                break;
            default:
        }
        result.put("target", targetJson);
        switch (msg.getStatus()) {
            case created:
                result.put("state", "draft");
                break;
            case send_going:
                result.put("state", "sending");
                break;
            case send_fail:
                result.put("state", "send_failed");
                break;
            case send_draft:
                result.put("state", "draft");
                break;
            case receive_fail:
                result.put("state", "download_failed");
                break;
            case send_success:
                result.put("state", "send_succeed");
                break;
            case receive_going:
                result.put("state", "receiving");
                break;
            case receive_success:
                result.put("state", "received");
                break;
        }
        MessageContent content = msg.getContent();
        if (content.getStringExtras() != null) {
            result.put("extras", content.getStringExtras());
        } else {
            result.put("extras", new HashMap());
        }

        result.put("createTime", msg.getCreateTime());

        switch (msg.getContentType()) {
            case text:
                result.put("type", "text");
                result.put("text", ((TextContent) content).getText());
                break;
            case image:
                result.put("type", "image");
                result.put("thumbPath", ((ImageContent) content).getLocalThumbnailPath());
                break;
            case voice:
                result.put("type", "voice");
                result.put("path", ((VoiceContent) content).getLocalPath());
                result.put("duration", ((VoiceContent) content).getDuration() + 0.0);
                break;
            case file:
                result.put("type", "file");
                result.put("fileName", ((FileContent) content).getFileName());
                break;
            case custom:
                result.put("type", "custom");
                Map<String, String> customObject = ((CustomContent) content).getAllStringValues();
                result.put("customObject", toJson(customObject));
                break;
            case location:
                result.put("type", "location");
                result.put("latitude", ((LocationContent) content).getLatitude().doubleValue());
                result.put("longitude", ((LocationContent) content).getLongitude().doubleValue());
                result.put("address", ((LocationContent) content).getAddress());
                result.put("scale", ((LocationContent) content).getScale().intValue());
                break;
            case video:
                result.put("type", "video");
                result.put("duration", ((VideoContent) content).getDuration());
                result.put("videoPath", ((VideoContent) content).getVideoLocalPath());
                result.put("thumbImagePath", ((VideoContent) content).getThumbLocalPath());
                result.put("videoFileName", ((VideoContent) content).getFileName());
                result.put("thumbFormat", ((VideoContent) content).getThumbFormat());
                break;
            case eventNotification:
                result.put("type", "event");
                List usernameList = ((EventNotificationContent) content).getUserNames();
                if (usernameList != null) {
                    result.put("usernames", toJson(usernameList));
                }

                List displayNameList = ((EventNotificationContent) content).getUserDisplayNames();
                if (usernameList != null) {
                    result.put("nicknames", toJson(displayNameList));
                }
                switch (((EventNotificationContent) content).getEventNotificationType()) {
                    case group_member_added:
                        // 群成员加群事件
                        result.put("eventType", "group_member_added");
                        break;
                    case group_member_removed:
                        // 群成员被踢事件
                        result.put("eventType", "group_member_removed");
                        break;
                    case group_member_exit:
                        // 群成员退群事件
                        result.put("eventType", "group_member_exit");
                        break;
                    case group_info_updated:
                        result.put("eventType", "group_info_updated");
                        break;
                    case group_member_keep_silence:
                        result.put("eventType", "group_member_keep_silence");
                        break;
                    case group_member_keep_silence_cancel:
                        result.put("eventType", "group_member_keep_silence_cancel");
                        break;
                    case group_keeper_added:
                        result.put("eventType", "group_keeper_added");
                        break;
                    case group_keeper_removed:
                        result.put("eventType", "group_keeper_removed");
                        break;
                    case group_dissolved:
                        // 解散群组事件
                        result.put("eventType", "group_dissolved");
                        break;
                    case group_owner_changed:
                        // 移交群组事件
                        result.put("eventType", "group_owner_changed");
                        break;
                    case group_type_changed:
                        // 移交群组事件
                        result.put("eventType", "group_type_changed");
                        break;
                    default:
                }
            default:
        }
        return result;
    }

    static Message JsonToMessage(JSONObject json) {
        Conversation conversation = null;
        int msgId = 0;

        try {
            msgId = Integer.parseInt(json.getString("id"));
            boolean isSend = json.getBoolean("isSend");

            JSONObject target = json.getJSONObject("target");

            if (target.getString("type").equals("user")) {
                String username;
                String appKey;

                if (isSend) { // 消息由当前用户发送，则聊天对象为消息接收方。
                    username = target.getString("username");
                    appKey = target.has("appKey") ? target.getString("appKey") : null;

                } else { // 当前用户为消息接收方，则聊天对象为消息发送方。
                    JSONObject opposite = json.getJSONObject("from");
                    username = opposite.getString("username");
                    appKey = opposite.has("appKey") ? opposite.getString("appKey") : null;
                }

                conversation = JMessageClient.getSingleConversation(username, appKey);

            } else if (target.getString("type").equals("group")) {
                long groupId = Long.parseLong(target.getString("id"));
                conversation = JMessageClient.getGroupConversation(groupId);

            } else if (target.getString("type").equals("chatRoom")) {
                long roomId = Long.parseLong(target.getString("roomId"));
                conversation = JMessageClient.getChatRoomConversation(roomId);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return conversation != null ? conversation.getMessage(msgId) : null;
    }

    static HashMap toJson(Conversation conversation) {

        final HashMap json = new HashMap<String, Object>();
        json.put("title", conversation.getTitle() != null ? conversation.getTitle() : "");
        json.put("unreadCount", conversation.getUnReadMsgCnt());

        if (conversation.getLatestMessage() != null) {
            json.put("latestMessage", toJson(conversation.getLatestMessage()));
        }

        if (conversation.getType() == ConversationType.single) {
            UserInfo targetInfo = (UserInfo) conversation.getTargetInfo();
            json.put("conversationType", "single");
            json.put("target", toJson(targetInfo));

        } else if (conversation.getType() == ConversationType.group) {
            GroupInfo targetInfo = (GroupInfo) conversation.getTargetInfo();
            json.put("conversationType", "group");
            json.put("target", toJson(targetInfo));
        } else if (conversation.getType() == ConversationType.chatroom) {
            ChatRoomInfo chatRoom = (ChatRoomInfo) conversation.getTargetInfo();
            json.put("target", toJson(chatRoom));
            json.put("conversationType", "chatRoom");
        }

        if (!TextUtils.isEmpty(conversation.getExtra())) {
            HashMap extrasMap = new HashMap<String, Object>();
            String extras = conversation.getExtra();
            JsonParser parser = new JsonParser();
            JsonObject jsonObject = parser.parse(extras).getAsJsonObject();
            for (Map.Entry<String, JsonElement> entry : jsonObject.entrySet()) {
                extrasMap.put(entry.getKey(), entry.getValue().toString());
            }
            json.put("extras", extrasMap);
        } else {
            json.put("extras", new HashMap());
        }

        Log.d("flutter plugin", "native the conversation:" + json.toString());

        return json;
    }

    static List toJson(List list) {

        List jsonArray = new ArrayList();

        if (list == null) {
            return jsonArray;
        }

        for (Object object : list) {

            if (object instanceof UserInfo) {
                jsonArray.add(toJson((UserInfo) object));
            } else if (object instanceof GroupInfo) {
                jsonArray.add(toJson((GroupInfo) object));
            } else if (object instanceof GroupBasicInfo) {
                jsonArray.add(toJson((GroupBasicInfo) object));
            } else if (object instanceof Message) {
                jsonArray.add(toJson((Message) object));
            } else if (object instanceof GroupMemberInfo) {
                jsonArray.add(toJson((GroupMemberInfo) object));
            } else {
                jsonArray.add(object);
            }
        }

        return jsonArray;
    }

    static HashMap toJson(String eventName, JSONObject value) {
        final HashMap result = new HashMap<String, Object>();
        result.put("eventName", eventName);
        result.put("value", value);
        return result;
    }

    static HashMap toJson(String eventName, JSONArray value) {
        final HashMap result = new HashMap<String, Object>();
        result.put("eventName", eventName);
        result.put("value", value);
        return result;
    }

    static HashMap toJson(ChatRoomInfo chatRoomInfo) {

        final HashMap json = new HashMap<String, Object>();
        json.put("type", "chatRoom");
        json.put("roomId", String.valueOf(chatRoomInfo.getRoomID())); // 配合 iOS，将 long 转成 String。
        json.put("name", chatRoomInfo.getName() != null ? chatRoomInfo.getName() : "");
        json.put("appKey", chatRoomInfo.getAppkey());
        json.put("description", chatRoomInfo.getDescription() != null ? chatRoomInfo.getDescription() : "");
        json.put("createTime", chatRoomInfo.getCreateTime()); // 创建日期，单位秒。
        json.put("maxMemberCount", chatRoomInfo.getMaxMemberCount()); // 最大成员数。
        json.put("memberCount", chatRoomInfo.getTotalMemberCount()); // 当前成员数。
        return json;
    }
}
