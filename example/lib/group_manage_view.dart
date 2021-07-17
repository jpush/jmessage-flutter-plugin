import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jmessage_flutter/jmessage_flutter.dart';
import 'package:jmessage_flutter_example/main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class GroupManageView extends StatefulWidget {
  @override
  _GroupManageViewState createState() => _GroupManageViewState();
}

class _GroupManageViewState extends State<GroupManageView> {
  List<dynamic> dataList = [];
  bool _loading = false;
  String _result = "选择需要操作的群组";
  int selectIndex = -1;
  JMGroupInfo? selectedGroupInfo;

  var usernameTextEC1 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("群组列表", style: TextStyle(fontSize: 20)),
        leading: IconButton(
            icon: new Image.asset("assets/nav_close.png"),
            onPressed: () {
              Navigator.maybePop(context);
            }),
      ),
      body: ModalProgressHUD(inAsyncCall: _loading, child: _buildContentView()),
    );
  }

  Widget _buildContentView() {
    return new Column(
      children: <Widget>[
        new Container(
          height: 100,
          child: new Row(
            children: <Widget>[
              Expanded(
                child: new Container(
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                  color: Colors.brown,
                  child: Text(_result),
                  height: double.infinity,
                ),
                flex: 2,
              ),
              Expanded(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new CustomButton(title: "私有群列表", onPressed: demoGetGidList),
                    new CustomButton(
                        title: "公开群列表", onPressed: demoGetPublicGroupInfos),
                  ],
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        new CustomTextField(
            hintText: "请输入username/group name", controller: usernameTextEC1),
        new Row(
          children: <Widget>[
            new Text(" "),
            new CustomButton(title: "成员列表", onPressed: demoGetMemberlist),
            new Text(" "),
            new CustomButton(title: "加入成员", onPressed: demoAddMember),
            new Text(" "),
            new CustomButton(title: "移除成员", onPressed: demoRemoveMember),
            new Text(" "),
            new CustomButton(title: "申请加入", onPressed: demoApplyJoinGroup),
          ],
        ),
        new Row(
          children: <Widget>[
            new Text(" "),
            new CustomButton(
                title: "创建公开群组",
                onPressed: () {
                  demoCreateGroup(JMGroupType.public);
                }),
            new Text(" "),
            new CustomButton(
                title: "创建私有群组",
                onPressed: () {
                  demoCreateGroup(JMGroupType.private);
                }),
            new Text(" "),
            new CustomButton(title: "创建群聊会话", onPressed: demoCreatConversation),
          ],
        ),
        Expanded(
          child: new Container(
            color: Colors.grey,
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: new ListView.builder(
                itemCount: dataList.length * 2,
                itemBuilder: (context, i) {
                  if (i.isOdd) return new Divider();
                  final index = i ~/ 2;
                  return _buildRow(dataList[index], index);
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(dynamic object, int index) {
    String title = "";
    String subTitle = "";
    if (object is String) {
      title = "【私有群】gid: " + object;
    } else if (object is JMGroupInfo) {
      title = "【公开群】name: " + object.name;
      subTitle = " gid: " + object.id;
    }

    return new Container(
      height: 60,
      child: new ListTile(
        //dense: true,
        //leading: CircleAvatar(backgroundImage: NetworkImage(url)),
        //trailing: Icon(Icons.keyboard_arrow_right),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        //设置内容边距，默认是 16
        title: new Text(title),
        subtitle: new Text(subTitle, style: TextStyle(fontSize: 14)),
        selected: selectIndex == index,
        onTap: () {
          print("点击了第【${index + 1}】行");
          String? gid;
          if (object is String) {
            gid = object;
          } else if (object is JMGroupInfo) {
            gid = object.id;
          }
          demoGetGroupInfo(gid);
          setState(() {
            selectIndex = index;
          });
        },
      ),
    );
  }

  void demoGetGroupInfo(String? gid) async {
    print("demoGetGroupInfo gid = $gid");

    setState(() {
      _loading = true;
    });

    JMGroupInfo groupInfo = await jmessage.getGroupInfo(id: gid);
    print("群信息：${groupInfo.toJson()}");

    selectedGroupInfo = groupInfo;

    setState(() {
      _loading = false;
      _result = "【选择的群组信息】\n ${groupInfo.toJson()}";
    });
  }

  void demoGetMemberlist() async {
    print("demoGetMemberlist ");

    if (selectedGroupInfo == null) {
      setState(() {
        _result = "请选着需要操作的群组";
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    String gid = selectedGroupInfo!.id;
    List<JMGroupMemberInfo> res = await jmessage.getGroupMembers(id: gid);
    print("群组【gid:$gid】的群成员列表：");
    for (JMGroupMemberInfo member in res) {
      print("group member info :   ${member.toJson()}");
    }
    setState(() {
      _loading = false;
      _result = "【群成员信息】请查看控制台 log 输出";
    });
  }

  void demoAddMember() async {
    print("demoAddMember ");

    if (usernameTextEC1.text.isEmpty) {
      setState(() {
        _loading = false;
        _result = "【添加群成员】username 不能为空";
      });
      return;
    }
    if (selectedGroupInfo == null) {
      setState(() {
        _loading = false;
        _result = "【添加群成员】请选着需要操作的群组";
      });
      return;
    }
    String gid = selectedGroupInfo!.id;
    String username = usernameTextEC1.text;
    await jmessage.addGroupMembers(id: gid, usernameArray: [username]);
    setState(() {
      _loading = false;
      _result = "【添加群成员】操作完成";
    });
  }

  void demoRemoveMember() async {
    print("demoRemoveMember ");

    if (usernameTextEC1.text.isEmpty) {
      setState(() {
        _loading = false;
        _result = "【移除群成员】username 不能为空";
      });
      return;
    }
    if (selectedGroupInfo == null) {
      setState(() {
        _loading = false;
        _result = "【移除群成员】请选着需要操作的群组";
      });
      return;
    }
    String gid = selectedGroupInfo!.id;
    String username = usernameTextEC1.text;
    await jmessage.removeGroupMembers(id: gid, usernames: [username]);

    setState(() {
      _loading = false;
      _result = "【移除群成员】操作完成";
    });
  }

  void demoApplyJoinGroup() async {
    print("demoApplyJoinGroup");

    setState(() {
      _loading = true;
    });

    if (selectedGroupInfo == null) {
      setState(() {
        _loading = false;
        _result = "【申请加入群组】请选着需要操作的群组";
      });
      return;
    }

    if (selectedGroupInfo!.groupType == JMGroupType.private) {
      setState(() {
        _loading = false;
        _result = "【申请加入群组】该群为私有群，可直接加入";
      });
      return;
    }

    String gid = selectedGroupInfo!.id;
    await jmessage.applyJoinGroup(groupId: gid);

    setState(() {
      _loading = false;
      _result = "【申请加入群组】操作完成";
    });
  }

  /// 获取 我的群列表
  void demoGetGidList() async {
    print("demoGetGroupList");

    reset();

    setState(() {
      _loading = true;
    });
    List<String> list = await jmessage.getGroupIds();
    setState(() {
      _loading = false;
      dataList = list;
    });
  }

  /// 获取公开群列表
  void demoGetPublicGroupInfos() async {
    print("demoGetPublicGroupInfos");

    reset();
    setState(() {
      _loading = true;
    });

    JMUserInfo? userInfo = await jmessage.getMyInfo();
    String? appkey = userInfo!.appKey;

    List<JMGroupInfo> groupList =
        await jmessage.getPublicGroupInfos(appKey: appkey, start: 0, count: 20);
    setState(() {
      _loading = false;
      dataList = groupList;
    });
  }

  void demoCreateGroup(JMGroupType type) async {
    print("demoCreateGroup" + usernameTextEC1.text);

    setState(() {
      _loading = true;
    });

    if (usernameTextEC1.text.isEmpty) {
      setState(() {
        _loading = false;
        _result = "【创建公开群】group name 不能为空";
      });
      return;
    }
    String name = usernameTextEC1.text;
    String groupIdString = await jmessage.createGroup(
        groupType: type, name: name, desc: "$name-的群描述信息");
    setState(() {
      _loading = false;
      _result = "【创建群组】创建成功，gid = $groupIdString";
    });
  }

  void demoCreatConversation() async {
    print("demoCreatConversation");

    setState(() {
      _loading = true;
    });

    if (selectedGroupInfo == null) {
      setState(() {
        _loading = false;
        _result = "【创建群聊会话】请选着需要操作的群组";
      });
      return;
    }

    String gid = selectedGroupInfo!.id;
    JMGroup group = JMGroup.fromJson({"groupId": gid});
    JMConversationInfo conversationInfo =
        await jmessage.createConversation(target: group);

    setState(() {
      _loading = false;
      _result = "【创建群聊会话】 $conversationInfo";
    });
  }

  void reset() {
    setState(() {
      _result = "选择需要操作的群组";
      selectIndex = -1;
      selectedGroupInfo = null;
    });
  }
}
