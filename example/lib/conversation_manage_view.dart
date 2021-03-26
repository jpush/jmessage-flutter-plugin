import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jmessage_flutter/jmessage_flutter.dart';
import 'package:jmessage_flutter_example/main.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ConversationManageView extends StatefulWidget {
  @override
  _ConversationManageViewState createState() => _ConversationManageViewState();
}

class _ConversationManageViewState extends State<ConversationManageView> {
  List<JMConversationInfo> dataList = [];
  bool _loading = false;
  String _result = "请选择需要操作的会话";
  int selectIndex = -1;
  JMConversationInfo selectConversationInfo;

  @override
  void initState() {
    super.initState();

    demoGetConversationList();
  }

  void addMessageEvent() async {
    jmessage.addReceiveMessageListener((msg) {
      //+
      print('listener receive event - message ： ${msg.toJson()}');

      verifyMessage(msg);

      setState(() {
        _result = "【收到消息】${msg.toJson()}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("会话列表", style: TextStyle(fontSize: 20)),
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
          margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
          color: Colors.brown,
          child: Text(_result),
          width: double.infinity,
          height: 120,
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Text(" "),
            new CustomButton(title: "发送文本消息", onPressed: demoSendTextMessage),
            new Text(" "),
            new CustomButton(title: "获取历史消息", onPressed: demoGetHistorMessage),
            new Text(" "),
            new CustomButton(
                title: "刷新会话列表",
                onPressed: () {
                  demoGetConversationList();
                }),
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

  Widget _buildRow(JMConversationInfo object, int index) {
    String title =
        "【${getStringFromEnum(object.conversationType)}】${object.title}";

    return new Container(
      height: 60,
      child: new ListTile(
        //dense: true,
        //leading: CircleAvatar(backgroundImage: NetworkImage(url)),
        //trailing: Icon(Icons.keyboard_arrow_right),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        //设置内容边距，默认是 16
        title: new Text(title),
        subtitle: new Text(object.latestMessage.toString()),
        selected: selectIndex == index,
        onTap: () {
          print("点击了第【${index + 1}】行");
          setState(() {
            selectIndex = index;
            _result = "【选择的会话】\n ${object.toJson()}";
          });
          selectConversationInfo = object;
        },
      ),
    );
  }

  /// 获取公开群列表
  void demoGetConversationList() async {
    print("demoGetConversationList");
    setState(() {
      selectIndex = -1;
      selectConversationInfo = null;
      _result = "请选择需要操作的会话";
      _loading = true;
    });

    List<JMConversationInfo> conversations = await jmessage.getConversations();

    setState(() {
      _loading = false;
      dataList = conversations;
    });

    for (JMConversationInfo info in conversations) {
      print('会话：${info.toJson()}');
    }
  }

  int textIndex = 0;

  void demoSendTextMessage() async {
    print("demoSendTextMessage");

    if (selectConversationInfo == null) {
      setState(() {
        _result = "请选着需要操作的会话";
      });
      return;
    }
    setState(() {
      _loading = true;
    });

    JMTextMessage msg = await selectConversationInfo.sendTextMessage(
        text: "send msg queen index $textIndex");
    setState(() {
      _loading = false;
      _result = "【文本消息】${msg.toJson()}";
    });
    textIndex++;
  }

  // 历史消息
  void demoGetHistorMessage() async {
    print("demoGetHistorMessage");

    if (selectConversationInfo == null) {
      setState(() {
        _result = "请选着需要操作的会话";
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    selectConversationInfo
        .getHistoryMessages(from: 0, limit: 20)
        .then((msgList) {
      for (JMNormalMessage msg in msgList) {
        print("get conversation history msg :   ${msg.toJson()}");
      }

      setState(() {
        _loading = false;
        _result = "【消息列表】${msgList.toString()}";
      });
    });
  }
}
