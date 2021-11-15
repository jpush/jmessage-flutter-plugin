package com.jiguang.jmessageflutter;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import cn.jpush.im.android.api.ContactManager;
import cn.jpush.im.android.api.JMessageClient;
import cn.jpush.im.android.api.callback.CreateGroupCallback;
import cn.jpush.im.android.api.callback.DownloadCompletionCallback;
import cn.jpush.im.android.api.callback.GetAvatarBitmapCallback;
import cn.jpush.im.android.api.callback.GetBlacklistCallback;
import cn.jpush.im.android.api.callback.GetGroupIDListCallback;
import cn.jpush.im.android.api.callback.GetGroupInfoCallback;
import cn.jpush.im.android.api.callback.GetGroupInfoListCallback;
import cn.jpush.im.android.api.callback.GetNoDisurbListCallback;
import cn.jpush.im.android.api.callback.GetReceiptDetailsCallback;
import cn.jpush.im.android.api.callback.GetUserInfoCallback;
import cn.jpush.im.android.api.callback.GetUserInfoListCallback;
import cn.jpush.im.android.api.callback.IntegerCallback;
import cn.jpush.im.android.api.callback.RequestCallback;
import cn.jpush.im.android.api.content.CustomContent;
import cn.jpush.im.android.api.content.FileContent;
import cn.jpush.im.android.api.content.ImageContent;
import cn.jpush.im.android.api.content.LocationContent;
import cn.jpush.im.android.api.content.MessageContent;
import cn.jpush.im.android.api.content.TextContent;
import cn.jpush.im.android.api.content.VideoContent;
import cn.jpush.im.android.api.content.VoiceContent;
import cn.jpush.im.android.api.enums.ContentType;
import cn.jpush.im.android.api.enums.PlatformType;
import cn.jpush.im.android.api.event.ChatRoomMessageEvent;
import cn.jpush.im.android.api.event.CommandNotificationEvent;
import cn.jpush.im.android.api.event.ContactNotifyEvent;
import cn.jpush.im.android.api.event.ConversationRefreshEvent;
import cn.jpush.im.android.api.event.GroupApprovalEvent;
import cn.jpush.im.android.api.event.GroupApprovalRefuseEvent;
import cn.jpush.im.android.api.event.GroupApprovedNotificationEvent;
import cn.jpush.im.android.api.event.LoginStateChangeEvent;
import cn.jpush.im.android.api.event.MessageEvent;
import cn.jpush.im.android.api.event.MessageReceiptStatusChangeEvent;
import cn.jpush.im.android.api.event.MessageRetractEvent;
import cn.jpush.im.android.api.event.NotificationClickEvent;
import cn.jpush.im.android.api.event.OfflineMessageEvent;
import cn.jpush.im.android.api.exceptions.JMFileSizeExceedException;
import cn.jpush.im.android.api.model.Conversation;
import cn.jpush.im.android.api.model.GroupBasicInfo;
import cn.jpush.im.android.api.model.GroupInfo;
import cn.jpush.im.android.api.model.GroupMemberInfo;
import cn.jpush.im.android.api.model.Message;
import cn.jpush.im.android.api.model.UserInfo;
import cn.jpush.im.android.api.options.MessageSendingOptions;
import cn.jpush.im.android.api.options.RegisterOptionalUserInfo;
import cn.jpush.im.api.BasicCallback;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.jiguang.jmessageflutter.JMessageUtils.getFile;
import static com.jiguang.jmessageflutter.JMessageUtils.getFileExtension;
import static com.jiguang.jmessageflutter.JMessageUtils.handleResult;
import static com.jiguang.jmessageflutter.JMessageUtils.sendMessage;
import static com.jiguang.jmessageflutter.JMessageUtils.toMessageSendingOptions;
import static com.jiguang.jmessageflutter.JsonUtils.fromJson;
import static com.jiguang.jmessageflutter.JsonUtils.toJson;

/**
 * JmessageFlutterPlugin
 */
public class JmessageFlutterPlugin implements FlutterPlugin, MethodCallHandler {

    public static JmessageFlutterPlugin instance;

    private static String TAG = "| JMessage | Android | ";

    static final int ERR_CODE_PARAMETER = 1;
    static final int ERR_CODE_CONVERSATION = 2;
    static final int ERR_CODE_MESSAGE = 3;
    static final int ERR_CODE_FILE = 4;
    static final int ERR_CODE_PERMISSION = 5;

    static final String ERR_MSG_PARAMETER = "Parameters error";
    static final String ERR_MSG_CONVERSATION = "Can't get the conversation";
    static final String ERR_MSG_MESSAGE = "No such message";
    static final String ERR_MSG_FILE = "Not find the file";
    static final String ERR_MSG_PERMISSION_WRITE_EXTERNAL_STORAGE = "Do not have 'WRITE_EXTERNAL_STORAGE' permission";

    static String appKey = null;
    private Context mContext;
    private MethodChannel channel;

    public static HashMap<String, GroupApprovalEvent> groupApprovalEventHashMap = new HashMap<>();


    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jmessage_flutter");
        channel.setMethodCallHandler(this);
        mContext = flutterPluginBinding.getApplicationContext();
    }


    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    public JmessageFlutterPlugin() {
        JmessageFlutterPlugin.instance = this;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("setup")) {
            setup(call, result);
        } else if (call.method.equals("setDebugMode")) {
            setDebugMode(call, result);
        } else if (call.method.equals("userRegister")) {
            userRegister(call, result);
        } else if (call.method.equals("login")) {
            login(call, result);
        } else if (call.method.equals("logout")) {
            logout(call, result);
        } else if (call.method.equals("setBadge")) {
            setBadge(call, result);
        } else if (call.method.equals("getMyInfo")) {
            getMyInfo(call, result);
        } else if (call.method.equals("getUserInfo")) {
            getUserInfo(call, result);
        } else if (call.method.equals("updateMyPassword")) {
            updateMyPassword(call, result);
        } else if (call.method.equals("updateMyAvatar")) {
            updateMyAvatar(call, result);
        } else if (call.method.equals("updateMyInfo")) {
            updateMyInfo(call, result);
        } else if (call.method.equals("updateGroupAvatar")) {
            updateGroupAvatar(call, result);
        } else if (call.method.equals("downloadThumbGroupAvatar")) {
            downloadThumbGroupAvatar(call, result);
        } else if (call.method.equals("downloadOriginalGroupAvatar")) {
            downloadOriginalGroupAvatar(call, result);
        } else if (call.method.equals("setConversationExtras")) {
            setConversationExtras(call, result);
        } else if (call.method.equals("createMessage")) {
            createMessage(call, result);
        } else if (call.method.equals("sendDraftMessage")) {
            sendDraftMessage(call, result);
        } else if (call.method.equals("sendTextMessage")) {
            sendTextMessage(call, result);
        } else if (call.method.equals("sendImageMessage")) {
            sendImageMessage(call, result);
        } else if (call.method.equals("sendVoiceMessage")) {
            sendVoiceMessage(call, result);
        } else if (call.method.equals("sendCustomMessage")) {
            sendCustomMessage(call, result);
        } else if (call.method.equals("sendLocationMessage")) {
            sendLocationMessage(call, result);
        } else if (call.method.equals("sendFileMessage")) {
            sendFileMessage(call, result);
        } else if (call.method.equals("retractMessage")) {
            retractMessage(call, result);
        } else if (call.method.equals("getHistoryMessages")) {
            getHistoryMessages(call, result);
        } else if (call.method.equals("getMessageByServerMessageId")) {
            getMessageByServerMessageId(call, result);
        } else if (call.method.equals("getMessageById")) {
            getMessageById(call, result);
        } else if (call.method.equals("deleteMessageById")) {
            deleteMessageById(call, result);
        } else if (call.method.equals("sendInvitationRequest")) {
            sendInvitationRequest(call, result);
        } else if (call.method.equals("acceptInvitation")) {
            acceptInvitation(call, result);
        } else if (call.method.equals("declineInvitation")) {
            declineInvitation(call, result);
        } else if (call.method.equals("removeFromFriendList")) {
            removeFromFriendList(call, result);
        } else if (call.method.equals("updateFriendNoteName")) {
            updateFriendNoteName(call, result);
        } else if (call.method.equals("updateFriendNoteText")) {
            updateFriendNoteText(call, result);
        } else if (call.method.equals("getFriends")) {
            getFriends(call, result);
        } else if (call.method.equals("createGroup")) {
            createGroup(call, result);
        } else if (call.method.equals("getGroupInfo")) {
            getGroupInfo(call, result);
        } else if (call.method.equals("getGroupIds")) {
            getGroupIds(call, result);
        } else if (call.method.equals("updateGroupInfo")) {
            updateGroupInfo(call, result);
        } else if (call.method.equals("addGroupMembers")) {
            addGroupMembers(call, result);
        } else if (call.method.equals("removeGroupMembers")) {
            removeGroupMembers(call, result);
        } else if (call.method.equals("exitGroup")) {
            exitGroup(call, result);
        } else if (call.method.equals("getGroupMembers")) {
            getGroupMembers(call, result);
        } else if (call.method.equals("addUsersToBlacklist")) {
            addUsersToBlacklist(call, result);
        } else if (call.method.equals("removeUsersFromBlacklist")) {
            removeUsersFromBlacklist(call, result);
        } else if (call.method.equals("getBlacklist")) {
            getBlacklist(call, result);
        } else if (call.method.equals("setNoDisturb")) {
            setNoDisturb(call, result);
        } else if (call.method.equals("getNoDisturbList")) {
            getNoDisturbList(call, result);
        } else if (call.method.equals("setNoDisturbGlobal")) {
            setNoDisturbGlobal(call, result);
        } else if (call.method.equals("isNoDisturbGlobal")) {
            isNoDisturbGlobal(call, result);
        } else if (call.method.equals("blockGroupMessage")) {
            blockGroupMessage(call, result);
        } else if (call.method.equals("isGroupBlocked")) {
            isGroupBlocked(call, result);
        } else if (call.method.equals("getBlockedGroupList")) {
            getBlockedGroupList(call, result);
        } else if (call.method.equals("downloadThumbUserAvatar")) {
            downloadThumbUserAvatar(call, result);
        } else if (call.method.equals("downloadOriginalUserAvatar")) {
            downloadOriginalUserAvatar(call, result);
        } else if (call.method.equals("downloadThumbImage")) {
            downloadThumbImage(call, result);
        } else if (call.method.equals("downloadOriginalImage")) {
            downloadOriginalImage(call, result);
        } else if (call.method.equals("downloadVoiceFile")) {
            downloadVoiceFile(call, result);
        } else if (call.method.equals("downloadFile")) {
            downloadFile(call, result);
        } else if (call.method.equals("downloadVideoFile")) {
            downloadVideoFile(call, result);
        } else if (call.method.equals("createConversation")) {
            createConversation(call, result);
        } else if (call.method.equals("deleteConversation")) {
            deleteConversation(call, result);
        } else if (call.method.equals("enterConversation")) {
            enterConversation(call, result);
        } else if (call.method.equals("exitConversation")) {
            exitConversation(call, result);
        } else if (call.method.equals("getConversation")) {
            getConversation(call, result);
        } else if (call.method.equals("getConversations")) {
            getConversations(call, result);
        } else if (call.method.equals("resetUnreadMessageCount")) {
            resetUnreadMessageCount(call, result);
        } else if (call.method.equals("transferGroupOwner")) {
            transferGroupOwner(call, result);
        } else if (call.method.equals("setGroupMemberSilence")) {
            setGroupMemberSilence(call, result);
        } else if (call.method.equals("isSilenceMember")) {
            isSilenceMember(call, result);
        } else if (call.method.equals("groupSilenceMembers")) {
            groupSilenceMembers(call, result);
        } else if (call.method.equals("setGroupNickname")) {
            setGroupNickname(call, result);
        } else if (call.method.equals("enterChatRoom")) {
            enterChatRoom(call, result);
        } else if (call.method.equals("exitChatRoom")) {
            exitChatRoom(call, result);
        } else if (call.method.equals("getChatRoomConversation")) {
            getChatRoomConversation(call, result);
        } else if (call.method.equals("getChatRoomConversationList")) {
            getChatRoomConversationList(call, result);
        } else if (call.method.equals("getAllUnreadCount")) {
            getAllUnreadCount(call, result);
        } else if (call.method.equals("addGroupAdmins")) {
            addGroupAdmins(call, result);
        } else if (call.method.equals("removeGroupAdmins")) {
            removeGroupAdmins(call, result);
        } else if (call.method.equals("changeGroupType")) {
            changeGroupType(call, result);
        } else if (call.method.equals("getPublicGroupInfos")) {
            getPublicGroupInfos(call, result);
        } else if (call.method.equals("applyJoinGroup")) {
            applyJoinGroup(call, result);
        } else if (call.method.equals("processApplyJoinGroup")) {
            processApplyJoinGroup(call, result);
        } else if (call.method.equals("dissolveGroup")) {
            dissolveGroup(call, result);
        } else if (call.method.equals("sendMessageTransCommand")) {
            sendMessageTransCommand(call, result);
        } else if (call.method.equals("sendCrossDeviceTransCommand")) {
            sendCrossDeviceTransCommand(call, result);
        } else if (call.method.equals("getMessageUnreceiptCount")) {
            getMessageUnreceiptCount(call, result);
        } else if (call.method.equals("getMessageReceiptDetails")) {
            getMessageReceiptDetails(call, result);
        } else if (call.method.equals("setMessageHaveRead")) {
            setMessageHaveRead(call, result);
        } else if (call.method.equals("sendVideoMessage")) {
            sendVideoMessage(call, result);
        } else if (call.method.equals("getMessageHaveReadStatus")) {
            getMessageHaveReadStatus(call, result);
        } else {
            result.notImplemented();
        }
    }


    private void setup(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);

            boolean isOpenMessageRoaming = false;
            if (params.has("isOpenMessageRoaming")) {
                isOpenMessageRoaming = params.getBoolean("isOpenMessageRoaming");
            }

            if (params.has("appkey")) {
                JmessageFlutterPlugin.appKey = params.getString("appkey");
            }
            JMessageClient.init(mContext, isOpenMessageRoaming);
            JMessageClient.registerEventReceiver(this);
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void setDebugMode(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            boolean enable = params.getBoolean("enable");
            JMessageClient.setDebugMode(enable);
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void userRegister(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String username, password;
        RegisterOptionalUserInfo optionalUserInfo = new RegisterOptionalUserInfo();
        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            password = params.getString("password");

            if (params.has("nickname"))
                optionalUserInfo.setNickname(params.getString("nickname"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        Log.d("Android", "Action - userRegister: username=" + username + ",pw=" + password);

        JMessageClient.register(username, password, optionalUserInfo, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void login(MethodCall call, final Result result) {

        HashMap<String, Object> map = call.arguments();
        String username, password;

        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            password = params.getString("password");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        Log.d("Android", "Action - login: username=" + username + ",pw=" + password);

        JMessageClient.login(username, password, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void logout(MethodCall call, Result result) {
        JMessageClient.logout();
    }

    private void setBadge(MethodCall call, Result result) {
        //  NOTE:  android do not support this function.
        result.success(null);
    }

    private void getMyInfo(MethodCall call, Result result) {
        UserInfo myInfo = JMessageClient.getMyInfo();
        if (myInfo != null) {
            result.success(toJson(myInfo));
        } else {
            // TODO:
            result.success(null);
        }
    }

    private void getUserInfo(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String username, appKey;

        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");

            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    handleResult(toJson(userInfo), status, desc, result);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void updateMyPassword(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String oldPwd, newPwd;
        try {
            JSONObject params = new JSONObject(map);
            oldPwd = params.getString("oldPwd");
            newPwd = params.getString("newPwd");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.updateUserPassword(oldPwd, newPwd, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void updateMyAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            if (!params.has("imgPath")) {
                handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
                return;
            }

            String imgPath = params.getString("imgPath");
            File img = new File(imgPath);
            String format = imgPath.substring(imgPath.lastIndexOf(".") + 1);
            JMessageClient.updateUserAvatar(img, format, new BasicCallback() {
                @Override
                public void gotResult(int status, String desc) {
                    handleResult(status, desc, result);
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void updateMyInfo(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        UserInfo myInfo = JMessageClient.getMyInfo();
        try {
            JSONObject params = new JSONObject(map);
            if (params.has("birthday")) {
                long birthday = params.getLong("birthday");
                myInfo.setBirthday(birthday);
            }

            if (params.has("nickname")) {
                myInfo.setNickname(params.getString("nickname"));
            }

            if (params.has("signature")) {
                myInfo.setSignature(params.getString("signature"));
            }

            if (params.has("gender")) {
                if (params.getString("gender").equals("male")) {
                    myInfo.setGender(UserInfo.Gender.male);
                } else if (params.getString("gender").equals("female")) {
                    myInfo.setGender(UserInfo.Gender.female);
                } else {
                    myInfo.setGender(UserInfo.Gender.unknown);
                }
            }

            if (params.has("region")) {
                myInfo.setRegion(params.getString("region"));
            }

            if (params.has("address")) {
                myInfo.setAddress(params.getString("address"));
            }

            if (params.has("extras")) {
                Map<String, String> extras = fromJson(params.getJSONObject("extras"));
                Iterator it = extras.entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry pair = (Map.Entry) it.next();
                    System.out.println(pair.getKey() + " = " + pair.getValue());
                    myInfo.setUserExtras(pair.getKey().toString(), pair.getValue().toString());
                    it.remove(); // avoids a ConcurrentModificationException
                }
            }

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        // 这里是为了规避 SDK 中的一个 bug，在 SDK bug 修复后会删除。
        if (myInfo.getBirthday() == 0)
            myInfo.setBirthday(0);

        JMessageClient.updateMyInfo(UserInfo.Field.all, myInfo, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void updateGroupAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        final String imgPath;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
            imgPath = params.getString("imgPath");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status != 0) { // error
                    handleResult(status, desc, result);
                    return;
                }

                File file;
                try {
                    file = getFile(imgPath);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    handleResult(ERR_CODE_FILE, ERR_MSG_FILE, result);
                    return;
                }

                String extension = getFileExtension(imgPath);

                groupInfo.updateAvatar(file, extension, new BasicCallback() {
                    @Override
                    public void gotResult(int status, String desc) {
                        handleResult(status, desc, result);
                    }
                });
            }
        });
    }

    private void downloadThumbGroupAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String id;
        try {
            JSONObject params = new JSONObject(map);
            id = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(Long.parseLong(id), new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    File avatarFile = groupInfo.getAvatarFile();
                    HashMap res = new HashMap();
                    res.put("id", groupInfo.getGroupID() + "");
                    String avatarFilePath = (avatarFile == null ? "" : avatarFile.getAbsolutePath());
                    res.put("filePath", avatarFilePath);
                    result.success(res);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void downloadOriginalGroupAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String id;

        try {
            JSONObject params = new JSONObject(map);
            id = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(Long.parseLong(id), new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, final GroupInfo groupInfo) {
                if (status != 0) {
                    handleResult(status, desc, result);
                    return;
                }

                if (groupInfo.getBigAvatarFile() == null) { // 本地不存在头像原图，进行下载。
                    groupInfo.getBigAvatarBitmap(new GetAvatarBitmapCallback() {
                        @Override
                        public void gotResult(int status, String desc, Bitmap bitmap) {
                            if (status != 0) { // 下载失败
                                handleResult(status, desc, result);
                                return;
                            }

                            String filePath = "";

                            if (bitmap != null) {
                                filePath = groupInfo.getBigAvatarFile().getAbsolutePath();
                            }

                            HashMap res = new HashMap();
                            res.put("id", groupInfo.getGroupID() + "");
                            res.put("filePath", filePath);
                            result.success(res);
                        }
                    });

                } else {
                    HashMap res = new HashMap();
                    res.put("id", groupInfo.getGroupID() + "");
                    res.put("filePath", groupInfo.getBigAvatarFile().getAbsolutePath());
                    result.success(res);
                }
            }
        });
    }

    private void setConversationExtras(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        JSONObject extra = null;

        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.getConversation(params);

            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            if (params.has("extras")) {
                extra = params.getJSONObject("extras");
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        String extraStr = extra == null ? "" : extra.toString();
        conversation.updateConversationExtra(extraStr);
        handleResult(toJson(conversation), 0, null, result);
    }

    private void createMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        String text;
        Map<String, String> extras = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            String type = params.getString("messageType");
            MessageContent content;
            switch (type) {
                case "text":
                    content = new TextContent(params.getString("text"));
                    break;
                case "image":
                    String path = params.getString("path");
                    String suffix = path.substring(path.lastIndexOf(".") + 1);
                    content = new ImageContent(new File(path), suffix);
                    break;
                case "voice":
                    path = params.getString("path");
                    File file = new File(path);
                    MediaPlayer mediaPlayer = MediaPlayer.create(mContext, Uri.parse(path));
                    int duration = mediaPlayer.getDuration() / 1000; // Millisecond to second.
                    content = new VoiceContent(file, duration);
                    mediaPlayer.release();
                    break;
                case "file":
                    path = params.getString("path");
                    file = new File(path);
                    content = new FileContent(file);
                    break;
                case "custom":
                    JSONObject customObject = params.getJSONObject("customObject");
                    CustomContent customContent = new CustomContent();
                    customContent.setAllValues(fromJson(customObject));
                    content = customContent;
                    break;
                case "location":
                    double latitude = params.getDouble("latitude");
                    double longitude = params.getDouble("longitude");
                    int scale = params.getInt("scale");
                    String address = params.getString("address");
                    content = new LocationContent(latitude, longitude, scale, address);
                    break;
                case "video":
                    String thumbImagePath = "", thumbFormat = "", videoPath, videoFileName = "";
                    videoPath = params.getString("videoPath");
                    if (params.has("thumbFormat")) {
                        thumbFormat = params.getString("thumbFormat");
                    }
                    if (params.has("thumbImagePath")) {
                        thumbImagePath = params.getString("thumbImagePath");
                    }
                    if (params.has("duration")) {
                        duration = params.getInt("duration");
                    } else {
                        mediaPlayer = MediaPlayer.create(mContext, Uri.parse(videoPath));
                        duration = mediaPlayer.getDuration() / 1000;
                        mediaPlayer.release();
                    }
                    if (params.has("videoFileName")) {
                        videoFileName = params.getString("videoFileName");
                    }

                    File videoFile = getFile(videoPath);

                    Bitmap bitmap = null;
                    if (!TextUtils.isEmpty(thumbImagePath)) {
                        bitmap = BitmapFactory.decodeFile(thumbImagePath);
                    }
                    content = new VideoContent(bitmap, thumbFormat, videoFile, videoFileName, duration);
                    break;
                default:
                    content = new CustomContent();
                    break;
            }

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
                content.setExtras(extras);
            }

            final Message msg = conversation.createSendMessage(content);
            result.success(toJson(msg));

        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void sendDraftMessage(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();


        MessageSendingOptions messageSendingOptions = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.createConversation(params);
            final Message message = conversation.getMessage(Integer.parseInt(params.getString("id")));

            if (params.has("messageSendingOptions")) {
                messageSendingOptions = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }

            message.setOnSendCompleteCallback(new BasicCallback() {
                @Override
                public void gotResult(int status, String desc) {
                    if (status == 0) {
                        HashMap json = JsonUtils.toJson(message);
                        handleResult(json, status, desc, result);
                    } else {
                        handleResult(status, desc, result);
                    }
                }
            });

            if (messageSendingOptions == null) {
                JMessageClient.sendMessage(message);
            } else {
                JMessageClient.sendMessage(message, messageSendingOptions);
            }

        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void sendTextMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        String text;
        Map<String, String> extras = null;
        MessageSendingOptions messageSendingOptions = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            text = params.getString("text");

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                messageSendingOptions = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        TextContent content = new TextContent(text);
        if (extras != null) {
            content.setExtras(extras);
        }

        sendMessage(conversation, content, messageSendingOptions, result);
    }

    private void sendImageMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        String path;
        Map<String, String> extras = null;
        MessageSendingOptions messageSendingOptions = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            path = params.getString("path");

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                messageSendingOptions = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        ImageContent content;
        try {
            File file = getFile(path);
            String suffix = path.substring(path.lastIndexOf(".") + 1);
            content = new ImageContent(file, suffix);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_FILE, ERR_MSG_FILE, result);
            return;
        }

        if (extras != null) {
            content.setExtras(extras);
        }

        sendMessage(conversation, content, messageSendingOptions, result);
    }

    private void sendVoiceMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        String path;
        Map<String, String> extras = null;
        MessageSendingOptions messageSendingOptions = null;
        Conversation conversation;


        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            path = params.getString("path");

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                messageSendingOptions = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        try {
            MediaPlayer mediaPlayer = MediaPlayer.create(mContext, Uri.parse(path));
            int duration = mediaPlayer.getDuration() / 1000; // Millisecond to second.

            File file = getFile(path);
            VoiceContent content = new VoiceContent(file, duration);

            mediaPlayer.release();

            if (extras != null) {
                content.setExtras(extras);
            }

            sendMessage(conversation, content, messageSendingOptions, result);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_FILE, ERR_MSG_FILE, result);
        }
    }

    private void sendCustomMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            Conversation conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            JSONObject customObject = params.getJSONObject("customObject");

            MessageSendingOptions options = null;
            if (params.has("messageSendingOptions")) {
                options = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }

            CustomContent content = new CustomContent();
            content.setAllValues(fromJson(customObject));
            sendMessage(conversation, content, options, result);
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void sendFileMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        String path, fileName = "";
        Map<String, String> extras = null;
        MessageSendingOptions options = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            path = params.getString("path");

            if (params.has("fileName")) {
                fileName = params.getString("fileName");
            }

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                options = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        try {
            File file = getFile(path);
            FileContent content = new FileContent(file, fileName);
            if (extras != null) {
                content.setExtras(extras);
            }
            sendMessage(conversation, content, options, result);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_FILE, ERR_MSG_FILE, result);
        } catch (JMFileSizeExceedException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_FILE, "File size is too large", result);
        }
    }

    private void sendVideoMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        int duration;
        String thumbImagePath = "", thumbFormat = "", videoPath, videoFileName = "";
        Map<String, String> extras = null;
        MessageSendingOptions options = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            videoPath = params.getString("videoPath");

            if (params.has("thumbFormat")) {
                thumbFormat = params.getString("thumbFormat");
            }

            if (params.has("thumbImagePath")) {
                thumbImagePath = params.getString("thumbImagePath");
            }

            if (params.has("duration")) {
                duration = params.getInt("duration");
            } else {
                MediaPlayer mediaPlayer = MediaPlayer.create(mContext, Uri.parse(videoPath));
                duration = mediaPlayer.getDuration() / 1000;
                mediaPlayer.release();
            }

            if (params.has("videoFileName")) {
                videoFileName = params.getString("videoFileName");
            }

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                options = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        try {
            File videoFile = getFile(videoPath);

            Bitmap bitmap = null;
            if (!TextUtils.isEmpty(thumbImagePath)) {
                bitmap = BitmapFactory.decodeFile(thumbImagePath);
            }

            VideoContent content = new VideoContent(bitmap, thumbFormat, videoFile, videoFileName, duration);
            if (extras != null) {
                content.setExtras(extras);
            }

            sendMessage(conversation, content, options, result);
        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_FILE, ERR_MSG_FILE, result);
        }

    }

    private void sendLocationMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        double latitude, longitude;
        int scale;
        String address;
        Map<String, String> extras = null;
        MessageSendingOptions options = null;
        Conversation conversation;

        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.createConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            latitude = params.getDouble("latitude");
            longitude = params.getDouble("longitude");
            scale = params.getInt("scale");
            address = params.getString("address");

            if (params.has("extras")) {
                extras = fromJson(params.getJSONObject("extras"));
            }

            if (params.has("messageSendingOptions")) {
                options = toMessageSendingOptions(params.getJSONObject("messageSendingOptions"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        LocationContent content = new LocationContent(latitude, longitude, scale, address);
        if (extras != null) {
            content.setExtras(extras);
        }

        sendMessage(conversation, content, options, result);
    }

    private void retractMessage(MethodCall call, final Result result) {
        Log.d("Android", "retractMessage:" + call.arguments);

        HashMap<String, Object> map = call.arguments();

        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            messageId = params.getString("messageId");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Long.parseLong(messageId));
        conversation.retractMessage(msg, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void getMessageUnreceiptCount(MethodCall call, final Result result) {
        Log.d(TAG, "getMessageUnreceiptCount:" + call.arguments);

        HashMap<String, Object> map = call.arguments();

        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            messageId = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Integer.parseInt(messageId));
        int count = 0;
        if (msg != null) {
            count = msg.getUnreceiptCnt();
        } else {
            Log.d(TAG, "this message was not found.");
        }
        result.success(count);
    }

    private void getMessageReceiptDetails(MethodCall call, final Result result) {
        Log.d(TAG, "getMessageReceiptDetails: " + call.arguments);

        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }
            messageId = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Integer.parseInt(messageId));
        if (msg != null) {
            msg.getReceiptDetails(new GetReceiptDetailsCallback() {
                @Override
                public void gotResult(int code, String dec, List<ReceiptDetails> list) {
                    if (code == 0) {
                        ReceiptDetails details = list.get(0);
                        List<UserInfo> receiptList = details.getReceiptList();
                        List<UserInfo> unreceiptList = details.getUnreceiptList();
                        String serverMsgID = details.getServerMsgID() + "";

                        HashMap resMap = new HashMap();

                        ArrayList receiptJSONArr = new ArrayList();
                        for (UserInfo userInfo : receiptList) {
                            receiptJSONArr.add(toJson(userInfo));
                        }
                        resMap.put("receiptList", receiptJSONArr);

                        ArrayList unreceiptJSONArr = new ArrayList();
                        for (UserInfo userInfo : unreceiptList) {
                            unreceiptJSONArr.add(toJson(userInfo));
                        }
                        resMap.put("unreceiptList", unreceiptJSONArr);

                        result.success(resMap);
                    } else {
                        handleResult(code, dec, result);
                    }
                }
            });
        } else {
            Log.d(TAG, "can not found this msg(msgid=" + messageId + ")");
            handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
        }
    }

    private void setMessageHaveRead(MethodCall call, final Result result) {
        Log.d(TAG, "setMessageHaveRead: " + call.arguments);

        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }
            messageId = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Integer.parseInt(messageId));
        if (msg != null) {
            msg.setHaveRead(new BasicCallback() {
                @Override
                public void gotResult(int code, String s) {
                    if (code == 0) {
                        result.success(true);
                    } else {
                        result.success(false);
                    }
                }
            });
        } else {
            Log.d(TAG, "can not found this msg(msgid = " + messageId + ")");
            result.success(false);
        }
    }

    private void getMessageHaveReadStatus(MethodCall call, Result result) {
        Log.d(TAG, "getMessageHaveReadStatus: " + call.arguments);

        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }
            messageId = params.getString("id");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Integer.parseInt(messageId));
        if (msg != null) {
            Boolean isHaveRead = msg.haveRead();
            result.success(isHaveRead);
        } else {
            Log.d(TAG, "can not found this msg(msgid = " + messageId + ")");
            result.success(false);
        }
    }

    private void getHistoryMessages(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        int from, limit;
        boolean isDescend;
        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);
            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }

            isDescend = params.has("isDescend") ? params.getBoolean("isDescend") : false;

            from = params.getInt("from");
            limit = params.getInt("limit");

            if (from < 0 || limit < -1) {
                handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
                return;
            }

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        List<Message> messageList;

        if (limit == -1) { // 意味着要获得从 from 开始的所有消息。
            if (from == 0) {
                messageList = conversation.getAllMessage();// 按时间升序
                Collections.reverse(messageList);// 按时间降序
            } else {
                int messageCount = conversation.getAllMessage().size() - from;
                messageList = conversation.getMessagesFromNewest(from, messageCount); // 按时间降序
            }
        } else {
            messageList = conversation.getMessagesFromNewest(from, limit);
        }

        if (!isDescend) {
            Collections.reverse(messageList);
        }

        ArrayList messageJSONArr = new ArrayList();

        for (Message msg : messageList) {
            messageJSONArr.add(toJson(msg));
        }
//    TODO: test JSONArray to dart.
        result.success(messageJSONArr);
    }

    private void getMessageByServerMessageId(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        Conversation conversation;
        String serverMessageId;
        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.getConversation(params);

            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, "Can't get conversation", result);
                return;
            }

            serverMessageId = params.getString("serverMessageId");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        Message msg = conversation.getMessage(Long.parseLong(serverMessageId));
        if (msg == null) {
            result.success(null);
        } else {
            result.success(toJson(msg));
        }
    }

    private void getMessageById(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();

        Conversation conversation;
        String messageId;
        try {
            JSONObject params = new JSONObject(map);
            conversation = JMessageUtils.getConversation(params);

            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, "Can't get conversation", result);
                return;
            }

            messageId = params.getString("messageId");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        Message msg = conversation.getMessage(Integer.parseInt(messageId));

        if (msg == null) {
            result.success(null);
        } else {
            result.success(toJson(msg));
        }
    }

    private void deleteMessageById(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        Conversation conversation;
        String messageId;

        try {
            JSONObject params = new JSONObject(map);

            conversation = JMessageUtils.getConversation(params);

            if (conversation == null) {
                handleResult(ERR_CODE_CONVERSATION, "Can't get conversation", result);
                return;
            }

            messageId = params.getString("messageId");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        boolean success = conversation.deleteMessage(Integer.parseInt(messageId));

        if (success) {
            result.success(null);
        } else {
            HashMap error = new HashMap();
            error.put("code", ERR_CODE_MESSAGE);
            error.put("description", ERR_MSG_MESSAGE);
            result.error(ERR_CODE_MESSAGE + "", ERR_MSG_MESSAGE, "");
        }
    }

    private void sendInvitationRequest(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String username, appKey, reason;

        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            reason = params.getString("reason");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        ContactManager.sendInvitationRequest(username, appKey, reason, new BasicCallback() {

            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void acceptInvitation(MethodCall call, final Result result) {

        HashMap<String, Object> map = call.arguments();
        String username, appKey;
        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        ContactManager.acceptInvitation(username, appKey, new BasicCallback() {

            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void declineInvitation(MethodCall call, final Result result) {

        HashMap<String, Object> map = call.arguments();
        String username, appKey, reason;

        try {
            JSONObject params = new JSONObject(map);

            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            reason = params.getString("reason");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        ContactManager.sendInvitationRequest(username, appKey, reason, new BasicCallback() {

            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });

    }

    private void removeFromFriendList(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String username, appKey;
        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {

            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    userInfo.removeFromFriendList(new BasicCallback() {

                        @Override
                        public void gotResult(int status, String desc) {
                            handleResult(status, desc, result);
                        }
                    });

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void updateFriendNoteName(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();

        final String username, appKey, noteName;
        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            noteName = params.getString("noteName");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {

            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    userInfo.updateNoteName(noteName, new BasicCallback() {

                        @Override
                        public void gotResult(int status, String desc) {
                            handleResult(status, desc, result);
                        }
                    });

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void updateFriendNoteText(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final String username, appKey, noteText;

        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            noteText = params.getString("noteText");

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {

            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    userInfo.updateNoteText(noteText, new BasicCallback() {

                        @Override
                        public void gotResult(int status, String desc) {
                            handleResult(status, desc, result);
                        }
                    });

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void getFriends(MethodCall call, final Result result) {
        ContactManager.getFriendList(new GetUserInfoListCallback() {

            @Override
            public void gotResult(int status, String desc, List list) {
                if (status == 0) {
                    handleResult(toJson(list), status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void createGroup(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String name, desc, avatarFilePath, groupType;

        try {
            JSONObject params = new JSONObject(map);
            name = params.getString("name");
            desc = params.getString("desc");
            groupType = params.getString("groupType");
            if (groupType.equals("private")) {
                JMessageClient.createGroup(name, desc, new CreateGroupCallback() {
                    @Override
                    public void gotResult(int status, String desc, long groupId) {
                        if (status == 0) {
                            result.success(String.valueOf(groupId));
                        } else {
                            handleResult(status, desc, result);
                        }
                    }
                });
            } else if (groupType.equals("public")) {
                JMessageClient.createPublicGroup(name, desc, new CreateGroupCallback() {
                    @Override
                    public void gotResult(int status, String desc, long groupId) {
                        if (status == 0) {
                            result.success(String.valueOf(groupId));
                        } else {
                            handleResult(status, desc, result);
                        }
                    }
                });
            } else {
                handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER + " : " + groupType, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }


    private void getGroupInfo(MethodCall call, final Result result) {

        HashMap<String, Object> map = call.arguments();


        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    handleResult(toJson(groupInfo), status, desc, result);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void getGroupIds(MethodCall call, final Result result) {
        JMessageClient.getGroupIDList(new GetGroupIDListCallback() {
            @Override
            public void gotResult(int status, String desc, List<Long> list) {
                if (status == 0) {
                    ArrayList groupIdJsonArr = new ArrayList();
                    for (Long id : list) {
                        groupIdJsonArr.add(String.valueOf(id));
                    }
                    handleResult(groupIdJsonArr, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });


    }

    private void updateGroupInfo(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    handleResult(toJson(groupInfo), status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void addGroupMembers(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();

        long groupId;
        JSONArray usernameJsonArr;
        String appKey;
        List<String> usernameList = new ArrayList<String>();

        try {
            JSONObject params = new JSONObject(map);

            groupId = Long.parseLong(params.getString("id"));
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            usernameJsonArr = params.getJSONArray("usernameArray");

            for (int i = 0; i < usernameJsonArr.length(); i++) {
                usernameList.add(usernameJsonArr.getString(i));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.addGroupMembers(groupId, appKey, usernameList, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void removeGroupMembers(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        JSONArray usernameJsonArr;
        String appKey;
        List<String> usernameList = new ArrayList<String>();
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            usernameJsonArr = params.getJSONArray("usernameArray");

            for (int i = 0; i < usernameJsonArr.length(); i++) {
                usernameList.add(usernameJsonArr.getString(i));
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.removeGroupMembers(groupId, appKey, usernameList, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void exitGroup(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.exitGroup(groupId, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void getGroupMembers(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupMembers(groupId, new RequestCallback<List<GroupMemberInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<GroupMemberInfo> groupMemberInfos) {
                if (status == 0) {
                    handleResult(toJson(groupMemberInfos), status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void addUsersToBlacklist(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        List<String> usernameList;
        String appKey;
        try {
            JSONObject params = new JSONObject(map);
            JSONArray usernameJsonArr = params.getJSONArray("usernameArray");

            usernameList = new ArrayList<String>();
            for (int i = 0; i < usernameJsonArr.length(); i++) {
                usernameList.add(usernameJsonArr.getString(i));
            }

            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.addUsersToBlacklist(usernameList, appKey, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void removeUsersFromBlacklist(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        List<String> usernameList;
        String appKey;
        try {
            JSONObject params = new JSONObject(map);
            JSONArray usernameJsonArr = params.getJSONArray("usernameArray");

            usernameList = new ArrayList<String>();
            for (int i = 0; i < usernameJsonArr.length(); i++) {
                usernameList.add(usernameJsonArr.getString(i));
            }

            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.delUsersFromBlacklist(usernameList, appKey, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void getBlacklist(MethodCall call, final Result result) {
        JMessageClient.getBlacklist(new GetBlacklistCallback() {
            @Override
            public void gotResult(int status, String desc, List list) {
                if (status == 0) {
                    handleResult(toJson(list), status, desc, result);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void setNoDisturb(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            String type = params.getString("type");
            final int isNoDisturb = params.getBoolean("isNoDisturb") ? ERR_CODE_PARAMETER : 0;

            if (type.equals("single")) {
                String username = params.getString("username");
                String appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
                JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {

                    @Override
                    public void gotResult(int status, String desc, UserInfo userInfo) {
                        if (status == 0) {
                            userInfo.setNoDisturb(isNoDisturb, new BasicCallback() {
                                @Override
                                public void gotResult(int status, String desc) {
                                    handleResult(status, desc, result);
                                }
                            });

                        } else {
                            handleResult(status, desc, result);
                        }
                    }
                });

            } else if (type.equals("group")) {
                final long groupId = Long.parseLong(params.getString("groupId"));

                JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {

                    @Override
                    public void gotResult(int status, String desc, GroupInfo groupInfo) {
                        if (status == 0) {
                            groupInfo.setNoDisturb(isNoDisturb, new BasicCallback() {
                                @Override
                                public void gotResult(int status, String desc) {
                                    handleResult(status, desc, result);
                                }
                            });

                        } else {
                            handleResult(status, desc, result);
                        }
                    }
                });
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void getNoDisturbList(MethodCall call, final Result result) {
        JMessageClient.getNoDisturblist(new GetNoDisurbListCallback() {

            @Override
            public void gotResult(int status, String desc, List userInfoList, List groupInfoList) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("userInfoArray", toJson(userInfoList));
                    res.put("groupInfoArray", toJson(groupInfoList));
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void setNoDisturbGlobal(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            int isNoDisturbGlobal = params.getBoolean("isNoDisturb") ? ERR_CODE_PARAMETER : 0;
            JMessageClient.setNoDisturbGlobal(isNoDisturbGlobal, new BasicCallback() {

                @Override
                public void gotResult(int status, String desc) {
                    handleResult(status, desc, result);
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void isNoDisturbGlobal(MethodCall call, final Result result) {
        JMessageClient.getNoDisturbGlobal(new IntegerCallback() {

            @Override
            public void gotResult(int status, String desc, Integer integer) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("isNoDisturb", integer == 1);
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void blockGroupMessage(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final long groupId;
        final int isBlock; // true: 屏蔽；false: 取消屏蔽。
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
            isBlock = params.getBoolean("isBlock") ? 1 : 0;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status != 0) {
                    handleResult(status, desc, result);
                    return;
                }

                groupInfo.setBlockGroupMessage(isBlock, new BasicCallback() {
                    @Override
                    public void gotResult(int status, String desc) {
                        handleResult(status, desc, result);
                    }
                });
            }
        });
    }

    private void isGroupBlocked(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("id"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status != 0) {
                    handleResult(status, desc, result);
                    return;
                }

                boolean isBlocked = (groupInfo.isGroupBlocked() == 1);
                HashMap res = new HashMap();
                res.put("isBlocked", isBlocked);
                handleResult(res, status, desc, result);
            }
        });
    }

    private void getBlockedGroupList(MethodCall call, final Result result) {
        JMessageClient.getBlockedGroupsList(new GetGroupInfoListCallback() {
            @Override
            public void gotResult(int status, String desc, List<GroupInfo> list) {
                if (status != 0) {
                    handleResult(status, desc, result);
                    return;
                }

                ArrayList res = new ArrayList();
                if (list != null) {
                    for (GroupInfo groupInfo : list) {
                        res.add(toJson(groupInfo));
                    }
                }
                handleResult(res, status, desc, result);
            }
        });
    }

    private void downloadThumbUserAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String username, appKey;

        try {
            JSONObject params = new JSONObject(map);
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getUserInfo(username, appKey, new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    File avatarFile = userInfo.getAvatarFile();
                    HashMap res = new HashMap();
                    res.put("username", userInfo.getUserName());
                    res.put("appKey", userInfo.getAppKey() != null ? userInfo.getAppKey() : "");
                    String avatarFilePath = (avatarFile != null ? avatarFile.getAbsolutePath() : "");
                    res.put("filePath", avatarFilePath);
                    result.success(res);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void downloadOriginalUserAvatar(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            final String username = params.getString("username");
            final String appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;

            JMessageUtils.getUserInfo(params, new GetUserInfoCallback() {
                @Override
                public void gotResult(int status, String desc, final UserInfo userInfo) {
                    if (status != 0) {
                        handleResult(status, desc, result);
                        return;
                    }

                    if (userInfo.getBigAvatarFile() == null) { // 本地不存在头像原图，进行下载。
                        userInfo.getBigAvatarBitmap(new GetAvatarBitmapCallback() {
                            @Override
                            public void gotResult(int status, String desc, Bitmap bitmap) {
                                if (status != 0) { // 下载失败
                                    handleResult(status, desc, result);
                                    return;
                                }

                                String filePath = "";

                                if (bitmap != null) {
                                    filePath = userInfo.getBigAvatarFile().getAbsolutePath();
                                }

                                HashMap res = new HashMap();
                                res.put("username", username);
                                res.put("appKey", appKey);
                                res.put("filePath", filePath);
                                result.success(res);
                            }
                        });

                    } else {
                        HashMap res = new HashMap();
                        res.put("username", username);
                        res.put("appKey", appKey);
                        res.put("filePath", userInfo.getBigAvatarFile().getAbsolutePath());
                        result.success(res);
                    }
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void downloadThumbImage(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final Message msg;
        try {
            JSONObject params = new JSONObject(map);
            msg = JMessageUtils.getMessage(params);
            if (msg == null) {
                handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
                return;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        if (msg.getContentType() != ContentType.image && msg.getContentType() != ContentType.video) {
            handleResult(ERR_CODE_MESSAGE, "Message type isn't image/video", result);
            return;
        }
        DownloadCompletionCallback cb = new DownloadCompletionCallback() {
            @Override
            public void onComplete(int status, String desc, File file) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("messageId", msg.getId());
                    res.put("filePath", file.getAbsolutePath());
                    handleResult(res, status, desc, result);
                } else {
                    handleResult(status, desc, result);
                }
            }
        };
        if (msg.getContentType() == ContentType.image) {
            ImageContent content = (ImageContent) msg.getContent();
            content.downloadThumbnailImage(msg, cb);
        } else {
            VideoContent content = (VideoContent) msg.getContent();
            content.downloadThumbImage(msg, cb);
        }


    }

    private void downloadOriginalImage(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final Message msg;
        try {
            JSONObject params = new JSONObject(map);
            msg = JMessageUtils.getMessage(params);
            if (msg == null) {
                handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
                return;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        if (msg.getContentType() != ContentType.image) {
            handleResult(ERR_CODE_MESSAGE, "Message type isn't image", result);
            return;
        }

        ImageContent content = (ImageContent) msg.getContent();
        content.downloadOriginImage(msg, new DownloadCompletionCallback() {
            @Override
            public void onComplete(int status, String desc, File file) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("messageId", msg.getId());
                    res.put("filePath", file.getAbsolutePath());
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void downloadVoiceFile(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final Message msg;
        try {
            JSONObject params = new JSONObject(map);
            msg = JMessageUtils.getMessage(params);
            if (msg == null) {
                handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
                return;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        if (msg.getContentType() != ContentType.voice) {
            handleResult(ERR_CODE_MESSAGE, "Message type isn't voice", result);
            return;
        }

        VoiceContent content = (VoiceContent) msg.getContent();
        content.downloadVoiceFile(msg, new DownloadCompletionCallback() {

            @Override
            public void onComplete(int status, String desc, File file) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("messageId", msg.getId());
                    res.put("filePath", file.getAbsolutePath());
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void downloadFile(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final Message msg;
        try {
            JSONObject params = new JSONObject(map);
            msg = JMessageUtils.getMessage(params);
            if (msg == null) {
                handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
                return;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        if (msg.getContentType() != ContentType.file) {
            handleResult(ERR_CODE_MESSAGE, "Message type isn't file", result);
            return;
        }

        FileContent content = (FileContent) msg.getContent();
        content.downloadFile(msg, new DownloadCompletionCallback() {
            @Override
            public void onComplete(int status, String desc, File file) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("messageId", msg.getId());
                    res.put("filePath", file.getAbsolutePath());
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void downloadVideoFile(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final Message msg;
        try {
            JSONObject params = new JSONObject(map);
            msg = JMessageUtils.getMessage(params);
            if (msg == null) {
                handleResult(ERR_CODE_MESSAGE, ERR_MSG_MESSAGE, result);
                return;
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        if (msg.getContentType() != ContentType.video) {
            handleResult(ERR_CODE_MESSAGE, "Message type isn't video", result);
            return;
        }

        VideoContent content = (VideoContent) msg.getContent();
        content.downloadVideoFile(msg, new DownloadCompletionCallback() {
            @Override
            public void onComplete(int status, String desc, File file) {
                if (status == 0) {
                    HashMap res = new HashMap();
                    res.put("messageId", msg.getId());
                    res.put("filePath", file.getAbsolutePath());
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void createConversation(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            Conversation conversation = JMessageUtils.createConversation(params);

            if (conversation != null) {
                result.success(toJson(conversation));
            } else {
                handleResult(ERR_CODE_CONVERSATION, "Can't create the conversation, please check your parameters",
                        result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void deleteConversation(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            String type = params.getString("type");

            if (type.equals("single")) {
                String username = params.getString("username");

                if (params.has("appKey") && !TextUtils.isEmpty(params.getString("appKey"))) {
                    JMessageClient.deleteSingleConversation(username, params.getString("appKey"));
                } else {
                    JMessageClient.deleteSingleConversation(username);
                }

            } else if (type.equals("group")) {
                long groupId = Long.parseLong(params.getString("groupId"));
                JMessageClient.deleteGroupConversation(groupId);

            } else if (type.equals("chatRoom")) {
                long roomId = Long.parseLong(params.getString("roomId"));
                JMessageClient.deleteChatRoomConversation(roomId);

            } else {
                handleResult(ERR_CODE_PARAMETER, "Conversation type is error", result);
                return;
            }

            result.success(null);
        } catch (JSONException e) {
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void enterConversation(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            String type = params.getString("type");

            if (type.equals("single")) {
                String username = params.getString("username");
                String appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;

                JMessageClient.enterSingleConversation(username, appKey);

            } else if (type.equals("group")) {
                long groupId = Long.parseLong(params.getString("groupId"));
                JMessageClient.enterGroupConversation(groupId);

            } else {
                handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
                return;
            }

            result.success(null);
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void exitConversation(MethodCall call, Result result) {
        JMessageClient.exitConversation();
        result.success(null);
    }

    private void getConversation(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            Conversation conversation = JMessageUtils.getConversation(params);
            if (conversation != null) {
                result.success(toJson(conversation));
            } else {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void getConversations(MethodCall call, Result result) {
        List<Conversation> conversationList = JMessageClient.getConversationList();
        ArrayList jsonArr = new ArrayList();
        for (Conversation conversation : conversationList) {
            jsonArr.add(toJson(conversation));
        }
        result.success(jsonArr);
    }

    private void resetUnreadMessageCount(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            Conversation conversation = JMessageUtils.getConversation(params);
            conversation.resetUnreadCount();
            result.success(null);
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void transferGroupOwner(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        final String username;
        final String appKey;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(final int status, final String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    groupInfo.changeGroupAdmin(username, appKey, new BasicCallback() {
                        @Override
                        public void gotResult(int i, String s) {
                            handleResult(status, desc, result);
                        }
                    });
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void setGroupMemberSilence(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        final String username;
        final String appKey;
        final Boolean isSilence;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            isSilence = params.getBoolean("isSilence");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(final int status, final String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    groupInfo.setGroupMemSilence(username, appKey, isSilence, new BasicCallback() {
                        @Override
                        public void gotResult(int i, String s) {
                            handleResult(i, s, result);
                        }
                    });
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void isSilenceMember(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        final String username;
        final String appKey;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    boolean isSilence = groupInfo.isKeepSilence(username, appKey);
                    HashMap res = new HashMap();
                    res.put("isSilence", isSilence);
                    handleResult(res, status, desc, result);

                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void groupSilenceMembers(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    List<GroupMemberInfo> groupSilenceMemberInfos = groupInfo.getGroupSilenceMemberInfos();
                    handleResult(toJson(groupSilenceMemberInfos), status, desc, result);
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void setGroupNickname(MethodCall call, final Result result) {
//    TODO:
        HashMap<String, Object> map = call.arguments();
        long groupId;
        final String username;
        final String appKey;
        final String nickname;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            username = params.getString("username");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            nickname = params.getString("nickName");

            JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
                @Override
                public void gotResult(int status, String desc, GroupInfo groupInfo) {
                    if (status == 0) {
                        groupInfo.setMemNickname(username, appKey, nickname, new BasicCallback() {
                            @Override
                            public void gotResult(int status, String desc) {
                                handleResult(status, desc, result);
                            }
                        });
                    } else {
                        handleResult(status, desc, result);
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }
    }

    private void enterChatRoom(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        JSONObject params = new JSONObject(map);
        ChatRoomHandler.enterChatRoom(params, result);
    }

    private void exitChatRoom(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        JSONObject params = new JSONObject(map);
        ChatRoomHandler.exitChatRoom(params, result);
    }

    private void getChatRoomConversation(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        long chatRoomId;
        try {
            JSONObject params = new JSONObject(map);
            chatRoomId = Long.parseLong(params.getString("roomId"));
            Conversation conversation = JMessageClient.getChatRoomConversation(chatRoomId);
            if (null == conversation) {
                handleResult(ERR_CODE_CONVERSATION, ERR_MSG_CONVERSATION, result);
                return;
            }
            result.success(toJson(conversation));
        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
        }

    }

    private void getChatRoomConversationList(MethodCall call, Result result) {
        ChatRoomHandler.getChatRoomConversationList(null, result);
    }

    private void getAllUnreadCount(MethodCall call, Result result) {
        int count = JMessageClient.getAllUnReadMsgCount();
        result.success(count);
    }

    private void addGroupAdmins(MethodCall call, final Result result) {
//    TODO: test it.
        HashMap<String, Object> map = call.arguments();
        final String appKey;
        long groupId;
        final JSONArray usernames;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            usernames = params.getJSONArray("usernames");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    final List<UserInfo> userInfos = new ArrayList<>();
                    for (int i = 0; i < usernames.length(); i++) {
                        try {
                            userInfos.add(groupInfo.getGroupMember(usernames.getString(i), appKey).getUserInfo());
                        } catch (JSONException e) {
                            e.printStackTrace();
                            handleResult(ERR_CODE_PARAMETER, "Can't find usernames.", result);
                            return;
                        }
                    }
                    groupInfo.addGroupKeeper(userInfos, new BasicCallback() {
                        @Override
                        public void gotResult(int status, String desc) {
                            handleResult(status, desc, result);
                        }
                    });
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void removeGroupAdmins(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final String appKey;
        final long groupId;
        final JSONArray usernames;

        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
            usernames = params.getJSONArray("usernames");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    final List<UserInfo> userInfos = new ArrayList<>();
                    for (int i = 0; i < usernames.length(); i++) {
                        try {
                            userInfos.add(groupInfo.getGroupMemberInfo(usernames.getString(i), appKey));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            handleResult(ERR_CODE_PARAMETER, "Can't find usernames.", result);
                            return;
                        }
                    }
                    groupInfo.removeGroupKeeper(userInfos, new BasicCallback() {
                        @Override
                        public void gotResult(int status, String desc) {
                            handleResult(status, desc, result);
                        }
                    });
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void changeGroupType(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        final String type;
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            type = params.getString("type");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.getGroupInfo(groupId, new GetGroupInfoCallback() {
            @Override
            public void gotResult(int status, String desc, GroupInfo groupInfo) {
                if (status == 0) {
                    if (type.equals("private")) {
                        groupInfo.changeGroupType(GroupInfo.Type.private_group, new BasicCallback() {
                            @Override
                            public void gotResult(int status, String desc) {
                                handleResult(status, desc, result);
                            }
                        });
                    } else if (type.equals("public")) {
                        groupInfo.changeGroupType(GroupInfo.Type.public_group, new BasicCallback() {
                            @Override
                            public void gotResult(int status, String desc) {
                                handleResult(status, desc, result);
                            }
                        });
                    } else {
                        handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER + ":" + type, result);
                    }
                } else {
                    handleResult(status, desc, result);
                }
            }
        });
    }

    private void getPublicGroupInfos(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String appKey;
        int start, count;
        try {
            JSONObject params = new JSONObject(map);
            start = Integer.parseInt(params.getString("start"));
            count = Integer.parseInt(params.getString("count"));
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }

        JMessageClient.getPublicGroupListByApp(appKey, start, count, new RequestCallback<List<GroupBasicInfo>>() {
            @Override
            public void gotResult(int status, String desc, List<GroupBasicInfo> groupBasicInfos) {
                handleResult(toJson(groupBasicInfos), status, desc, result);
            }
        });
    }

    private void applyJoinGroup(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String reason;
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
            reason = params.getString("reason");
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.applyJoinGroup(groupId, reason, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void processApplyJoinGroup(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        String reason, appKey;
        Boolean isAgree, isRespondInviter;
        JSONArray events;

        try {
            JSONObject params = new JSONObject(map);
            reason = params.getString("reason");
            isAgree = params.getBoolean("isAgree");
            isRespondInviter = params.getBoolean("isRespondInviter");
            events = params.getJSONArray("events");
            appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;

            final List<GroupApprovalEvent> groupApprovalEventList = new ArrayList<>();

            for (int i = 0; i < events.length(); i++) {
                GroupApprovalEvent groupApprovalEvent = groupApprovalEventHashMap.get(events.getString(i));
                if (groupApprovalEvent == null) {
                    handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER + ": can't get events.", result);
                    return;
                }
                groupApprovalEventList.add(groupApprovalEvent);
            }

            if (groupApprovalEventList.size() == 0) {
                handleResult(ERR_CODE_PARAMETER, "Can not find GroupApprovalEvent by events", result);
                return;
            }
            if (isAgree) {
                GroupApprovalEvent.acceptGroupApprovalInBatch(groupApprovalEventList, isRespondInviter,
                        new BasicCallback() {
                            @Override
                            public void gotResult(int status, String desc) {
                                handleResult(status, desc, result);
                            }
                        });
            } else {
                // 批量处理只有接受，插件做循环单拒绝
                for (int i = 0; i < groupApprovalEventList.size(); i++) {
                    GroupApprovalEvent groupApprovalEvent = groupApprovalEventList.get(i);
                    final int finalI = i;
                    groupApprovalEvent.refuseGroupApproval(groupApprovalEvent.getFromUsername(),
                            groupApprovalEvent.getfromUserAppKey(),
                            reason,
                            new BasicCallback() {
                                @Override
                                public void gotResult(int status, String desc) {
                                    // 统一返回最后一个拒绝结果
                                    if (finalI == groupApprovalEventList.size() - 1) {
                                        handleResult(status, desc, result);
                                    }
                                }
                            });
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void dissolveGroup(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        long groupId;
        try {
            JSONObject params = new JSONObject(map);
            groupId = Long.parseLong(params.getString("groupId"));
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
        JMessageClient.adminDissolveGroup(groupId, new BasicCallback() {
            @Override
            public void gotResult(int status, String desc) {
                handleResult(status, desc, result);
            }
        });
    }

    private void sendMessageTransCommand(MethodCall call, final Result result) {

        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            String message = params.getString("message");
            String type = params.getString("type");

            if (type.equals("single")) {
                String username = params.getString("username");
                String appKey = params.has("appKey") ? params.getString("appKey") : JmessageFlutterPlugin.appKey;

                JMessageClient.sendSingleTransCommand(username, appKey, message, new BasicCallback() {
                    @Override
                    public void gotResult(int status, String desc) {
                        handleResult(status, desc, result);
                    }
                });

            } else if (type.equals("group")) {
                final long groupId = Long.parseLong(params.getString("groupId"));

                JMessageClient.sendGroupTransCommand(groupId, message, new BasicCallback() {
                    @Override
                    public void gotResult(int status, String desc) {
                        handleResult(status, desc, result);
                    }
                });
            }
        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }

    private void sendCrossDeviceTransCommand(MethodCall call, final Result result) {
        HashMap<String, Object> map = call.arguments();
        try {
            JSONObject params = new JSONObject(map);
            String message = params.getString("message");
            String type = params.getString("platform");

            PlatformType platformType = PlatformType.all;
            if (type.equals("android")) {
                platformType = PlatformType.android;
            } else if (type.equals("ios")) {
                platformType = PlatformType.ios;
            } else if (type.equals("windows")) {
                platformType = PlatformType.windows;
            } else if (type.equals("web")) {
                platformType = PlatformType.web;
            } else {//all
                platformType = PlatformType.all;
            }

            JMessageClient.sendCrossDeviceTransCommand(platformType, message, new BasicCallback() {
                @Override
                public void gotResult(int status, String desc) {
                    handleResult(status, desc, result);
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, result);
            return;
        }
    }


    // Event Handler - start

    /**
     * 收到消息事件。
     *
     * @param event 消息事件。
     */
    public void onEventMainThread(MessageEvent event) {

        HashMap msgJson = toJson(event.getMessage());

        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveMessage", msgJson);
    }

    /**
     * 触发通知栏点击事件。
     *
     * @param event 通知栏点击事件。
     */
    public void onEventMainThread(NotificationClickEvent event) {
        // 点击通知启动应用。


        Intent launchIntent = mContext.getApplicationContext().getPackageManager()
                .getLaunchIntentForPackage(mContext.getPackageName());
        launchIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        mContext.startActivity(launchIntent);

        HashMap msgJson = toJson(event.getMessage());
        JmessageFlutterPlugin.instance.channel.invokeMethod("onClickMessageNotification", msgJson);
    }


    /**
     * 同步离线消息。
     *
     * @param event 离线消息事件。
     */
    public void onEventMainThread(OfflineMessageEvent event) {
        final HashMap json = new HashMap();
        json.put("conversation", toJson(event.getConversation()));

        final List<Message> offlineMsgList = event.getOfflineMessageList();
        int latestMediaMessageIndex = -1;

        for (int i = offlineMsgList.size() - 1; i >= 0; i--) {
            Message msg = offlineMsgList.get(i);
            if (msg.getContentType() == ContentType.image || msg.getContentType() == ContentType.voice) {
                latestMediaMessageIndex = i;
                break;
            }
        }

        final ArrayList msgJsonArr = new ArrayList();

        if (latestMediaMessageIndex == -1) { // 没有多媒体消息
            for (Message msg : offlineMsgList) {
                msgJsonArr.add(toJson(msg));
            }
            json.put("messageArray", msgJsonArr);
            JmessageFlutterPlugin.instance.channel.invokeMethod("onSyncOfflineMessage", json);
        } else {
            final int fLatestMediaMessageIndex = latestMediaMessageIndex;

            for (int i = 0; i < offlineMsgList.size(); i++) {
                Message msg = offlineMsgList.get(i);

                final int fI = i;

                switch (msg.getContentType()) {
                    case image:
                        ((ImageContent) msg.getContent()).downloadThumbnailImage(msg, new DownloadCompletionCallback() {
                            @Override
                            public void onComplete(int status, String desc, File file) {
                                if (fI == fLatestMediaMessageIndex) {
                                    for (Message msg : offlineMsgList) {
                                        msgJsonArr.add(toJson(msg));
                                    }
                                    json.put("messageArray", msgJsonArr);
                                    JmessageFlutterPlugin.instance.channel.invokeMethod("onSyncOfflineMessage", json);
                                }
                            }
                        });
                        break;
                    case voice:
                        ((VoiceContent) msg.getContent()).downloadVoiceFile(msg, new DownloadCompletionCallback() {
                            @Override
                            public void onComplete(int status, String desc, File file) {
                                if (fI == fLatestMediaMessageIndex) {
                                    for (Message msg : offlineMsgList) {
                                        msgJsonArr.add(toJson(msg));
                                    }
                                    json.put("messageArray", msgJsonArr);
                                    JmessageFlutterPlugin.instance.channel.invokeMethod("onSyncOfflineMessage", json);
                                }
                            }
                        });
                    default:
                }
            }
        }
    }

    private boolean mHasRoamingMsgListener;
    private List<HashMap> mRoamingMessageCache;

    /**
     * 漫游消息同步事件。
     * <p>
     * 因为漫游消息同步事件在调用 init 方法后即会触发，因此添加缓存。
     *
     * @param event 漫游消息同步事件。
     */
    public void onEventMainThread(ConversationRefreshEvent event) {
//    TODO:
        if (event.getReason() == ConversationRefreshEvent.Reason.MSG_ROAMING_COMPLETE) {
            HashMap json = new HashMap();
            json.put("conversation", toJson(event.getConversation()));

            if (!mHasRoamingMsgListener) {
                if (mRoamingMessageCache == null) {
                    mRoamingMessageCache = new ArrayList<HashMap>();
                }
                mRoamingMessageCache.add(json);

            } else if (mRoamingMessageCache == null) { // JS 已添加监听事件，没有缓存，直接触发事件。
                JmessageFlutterPlugin.instance.channel.invokeMethod("onSyncRoamingMessage", json);
            }
        }
    }

    /**
     * JS 层传入漫游消息同步事件监听。
     */
    void addSyncRoamingMessageListener(JSONArray data, Readable callback) {
        mHasRoamingMsgListener = true;

        if (mRoamingMessageCache != null) { // 触发缓存
            for (HashMap json : mRoamingMessageCache) {
                JmessageFlutterPlugin.instance.channel.invokeMethod("onSyncRoamingMessage", json);
            }
            mRoamingMessageCache = null;
        }
    }

    /**
     * 用户登录状态变更事件。
     *
     * @param event 用户登录状态变更事件。
     */
    public void onEventMainThread(LoginStateChangeEvent event) throws JSONException {
        HashMap json = new HashMap();
        json.put("type", event.getReason().toString());

        JmessageFlutterPlugin.instance.channel.invokeMethod("onLoginStateChanged", json);
    }

    /**
     * 联系人相关通知事件。
     *
     * @param event 联系人相关通知事件。
     */
    public void onEventMainThread(ContactNotifyEvent event) throws JSONException {
        HashMap json = new HashMap();
        json.put("type", event.getType().toString());
        json.put("reason", event.getReason());
        json.put("fromUsername", event.getFromUsername());
        json.put("fromUserAppKey", event.getfromUserAppKey());

        JmessageFlutterPlugin.instance.channel.invokeMethod("onContactNotify", json);
    }

    /**
     * 消息接收方收到的消息撤回事件。
     *
     * @param event 消息撤回事件。
     */
    public void onEventMainThread(MessageRetractEvent event) throws JSONException {
        Log.d("Android", "onEvent MessageRetractEvent:");

        HashMap json = new HashMap();
        json.put("conversation", toJson(event.getConversation()));
        json.put("retractedMessage", toJson(event.getRetractedMessage()));

        JmessageFlutterPlugin.instance.channel.invokeMethod("onRetractMessage", json);
    }

    public void onEventMainThread(MessageReceiptStatusChangeEvent event) throws JSONException {
        Log.d("Android", "onEvent MessageReceiptStatusChangeEvent:");

        Conversation conversation = event.getConversation();
        List<MessageReceiptStatusChangeEvent.MessageReceiptMeta> list = event.getMessageReceiptMetas();
        ArrayList<String> serverMessageIdList = new ArrayList();
        for (MessageReceiptStatusChangeEvent.MessageReceiptMeta meta : list) {
            String serverMsgId = String.valueOf(meta.getServerMsgId());
            serverMessageIdList.add(serverMsgId);
        }

        HashMap json = new HashMap();
        json.put("conversation", toJson(event.getConversation()));
        json.put("serverMessageIdList", serverMessageIdList);

        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveMessageReceiptStatusChange", json);
    }

    /**
     * 透传消息接收事件。
     *
     * @param event 透传消息事件。
     */
    public void onEventMainThread(final CommandNotificationEvent event) {
        final HashMap result = new HashMap();
        result.put("message", event.getMsg());

        event.getSenderUserInfo(new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    result.put("sender", toJson(userInfo));
                }
                event.getTargetInfo(new CommandNotificationEvent.GetTargetInfoCallback() {
                    @Override
                    public void gotResult(int status, String desc, Object obj, CommandNotificationEvent.Type type) {
                        if (status == 0) {
                            if (type == CommandNotificationEvent.Type.single) {
                                UserInfo receiver = (UserInfo) obj;
                                result.put("receiver", toJson(receiver));
                                result.put("receiverType", "user");

                            } else {
                                GroupInfo receiver = (GroupInfo) obj;
                                result.put("receiver", toJson(receiver));
                                result.put("receiverType", "group");
                            }

                            JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveTransCommand", result);
                        }
                    }
                });
            }
        });


    }

    /**
     * 处理聊天室消息事件。
     */
    public void onEventMainThread(ChatRoomMessageEvent event) {
        ArrayList jsonArr = new ArrayList<>();

        for (Message msg : event.getMessages()) {
            jsonArr.add(toJson(msg));
        }

        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveChatRoomMessage", jsonArr);
    }

    /**
     * 监听接收入群申请事件
     */
    public void onEventMainThread(final GroupApprovalEvent event) throws JSONException {
        Log.d(TAG, "GroupApprovalEvent, event: " + event);

        groupApprovalEventHashMap.put(event.getEventId() + "", event);
        GroupApprovalEvent.Type type = event.getType();

        final HashMap json = new HashMap();
        json.put("eventId", event.getEventId() + "");
        json.put("reason", event.getReason());
        json.put("groupId", event.getGid() + "");
        json.put("isInitiativeApply", type.equals(GroupApprovalEvent.Type.apply_join_group));

        // 先异步获取 fromuserinfo
        event.getFromUserInfo(new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    json.put("sendApplyUser", toJson(userInfo));
                } else {
                    json.put("sendApplyUser", new HashMap());
                }

                // 再获取 approve list
                event.getApprovalUserInfoList(new GetUserInfoListCallback() {
                    @Override
                    public void gotResult(int status, String s, List<UserInfo> list) {
                        if (status == 0) {
                            json.put("joinGroupUsers", toJson(list));
                        } else {
                            json.put("joinGroupUsers", new HashMap());
                        }
                        // 回调都回来了再发
                        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveApplyJoinGroupApproval", json);
                    }
                });
            }
        });


    }

    /**
     * 监听管理员同意入群申请事件
     */
    public void onEventMainThread(GroupApprovedNotificationEvent event) {
        Log.d(TAG, "GroupApprovedNotificationEvent, event: " + event);
        final HashMap json = new HashMap();
        json.put("isAgree", event.getApprovalResult());
        json.put("applyEventId", event.getApprovalEventID() + "");
        json.put("groupId", event.getGroupID() + "");

        event.getOperator(new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    json.put("groupAdmin", toJson(userInfo));
                }
            }
        });
        event.getApprovedUserInfoList(new GetUserInfoListCallback() {
            @Override
            public void gotResult(int status, String s, List<UserInfo> list) {
                if (status == 0) {
                    json.put("users", toJson(list));
                }
            }
        });
        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveGroupAdminApproval", json);
    }

    /**
     * 监听管理员拒绝入群申请事件
     */
    public void onEventMainThread(GroupApprovalRefuseEvent event) {
        Log.d(TAG, "GroupApprovalRefuseEvent, event: " + event);
        final HashMap json = new HashMap();
        json.put("reason", event.getReason());
        json.put("groupId", event.getGid() + "");

        event.getFromUserInfo(new GetUserInfoCallback() {
            @Override
            public void gotResult(int status, String desc, UserInfo userInfo) {
                if (status == 0) {
                    json.put("groupManager", toJson(userInfo));
                }
            }
        });

        JmessageFlutterPlugin.instance.channel.invokeMethod("onReceiveGroupAdminReject", json);

    }

    // Event Handler - end
}
