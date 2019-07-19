import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'bloc.dart';
import 'base.dart' show DYBase, DYhttp, DYio;

class DyIndexPage extends StatefulWidget {
  final arguments;
  DyIndexPage({Key key, this.arguments}) : super(key: key);

  @override
  _DyIndexPageState createState() {
    return _DyIndexPageState(arguments);
  }
}

class _DyIndexPageState extends State<DyIndexPage> with DYBase {
  // 路由传入的数据
  final routeProp;
  _DyIndexPageState(this.routeProp);

  CounterBloc counterBloc;

  /*---- 实例属性 State ----*/
  int _navIndex = 0;
  List navList = [];
  List swiperPic = [];
  List liveData = [];

  /*---- 生命周期 ----*/
  @override
  void initState() {
    DYio.getTempFile('navList').then((dynamic data) {
      if (data == null) return;
      setState(() {
        navList = data['data'];
        _getLiveData(navList[0]);
      });
    });
    _getNav();
    _getSwiperPic();
  }

  /*---- 网络请求 ----*/
  // 获取导航列表
  void _getNav() {
    DYhttp.get(
      '/dy/flutter/nav',
      cacheName: 'navList',
    ).then((res) {
      setState(() {
        navList = res['data']; 
      });
      _getLiveData(navList[0]);
    });
  }
  // 获取轮播图数据
  void _getSwiperPic() {
    DYhttp.post('/dy/flutter/swiper').then((res) {
      setState(() {
        swiperPic = res['data']; 
      });
    });
  }
  // 获取正在直播列表数据
  void _getLiveData(String i) {
    DYhttp.post(
      '/dy/flutter/liveData',
      param: {
        'typeName': i
      }
    ).then((res) {
      setState(() {
       liveData = res['data']; 
      });
    });
  }

  /*---- 事件对应方法 ----*/
  // 点击悬浮标
  void _incrementCounter() {
    counterBloc.dispatch(CounterEvent.increment);
  }
  // 选择导航tab
  void _chooseTabNav(i) {
    setState(() {
      _navIndex = i;
    });
  }
  // 跳转直播间
  void _goToLiveRoom(item) {
    Navigator.pushNamed(context, '/room', arguments: item);
  }

  /*---- 部件buid函数入口 ----*/
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: DYBase.dessignWidth)..init(context);
    counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      body: BlocBuilder<CounterEvent, int>(
        bloc: counterBloc,
        builder: (BuildContext context, int count) {
          return Container(
            child: Column(
              children: [
                _header(),
                _nav(),
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.only(top: 0),
                    children: [
                      _swiper(),
                      _liveTable(count),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // 右下角悬浮按钮(Bloc计数状态演示)
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        foregroundColor: Color(0xffff5d23),
        backgroundColor: Colors.white,
        tooltip: 'Increment',
        child: Icon(Icons.favorite),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  /*---- 组件化拆分 ----*/
  // Header容器
  Widget _header() {
    return Container(
      width: dp(375),
      height: dp(80),
      padding: EdgeInsets.fromLTRB(dp(10), dp(24), dp(20), 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(0.6, 0.0),
          colors: <Color>[
            Color(0xffffffff),
            Color(0xffff9b7a)
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // 斗鱼LOGO
          GestureDetector(
            onTap: DYio.clearCache,
            child: Image(
              image: AssetImage('lib/images/dylogo.png'),
              width: dp(76),
              height: dp(34),
            ),
          ),
          // 搜索区域容器
          Expanded(
            flex: 1,
            child: Container(
              width: dp(150),
              height: dp(30),
              margin: EdgeInsets.only(left: dp(15)),
              padding: EdgeInsets.only(left: dp(5), right: dp(5)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(dp(15)),
                ), 
              ),
              child: Row(
                children: <Widget>[
                  // 搜索ICON
                  Image.asset(
                    'lib/images/search.png',
                    width: dp(25),
                    height: dp(15),
                  ),
                  // 搜索输入框
                  Expanded(
                    flex: 1,
                    child: TextField(
                      cursorColor: Color(0xffff5d23),
                      cursorWidth: 1.5,
                      style: TextStyle(
                        color: Color(0xffff5d23),
                        fontSize: 14.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintText: '搜索你想看的直播内容',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // tab 切换导航
  Widget _nav() {
    return SizedBox(
      height: dp(40),
      // 导航滚动列表视图
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10),
        children: _creatNavList(),
      ),
      // 滚动视图的另一种快捷API实现 
      /* child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10),
        itemCount: config.navListData.length,
        itemBuilder: (context, i) {
          return Container(
            color: Colors.orange,
            margin: EdgeInsets.only(right: dp(10)),
            child: Text(
              '${config.navListData[i]}',
            ),
          );
        },
      ), */
    );
  }

  // 创建导航子项
  List<Container> _creatNavList() {
    var navWidgetList = List<Container>();

    for (var i = 0; i < navList.length; i++) {
      var border, style;
      Color actColor = Color(0xffff5d23);

      if (i == _navIndex) {
        border = Border(bottom: BorderSide(color: actColor, width: dp(2)));
        style = TextStyle(
          color: actColor,
        );
      } else {
        style = TextStyle(
          color: Color(0xff3f3f3f),
        );
      }
      navWidgetList.add(
        Container(
          decoration: BoxDecoration(
            border: border
          ),
          margin: EdgeInsets.only(right: dp(10)),
          child: GestureDetector(
            onTap: () {
              _chooseTabNav(i);
            },
            child: Text(
              '${navList[i]}',
              style: style,
            ),
          ),
        ),
      );
    }
    return navWidgetList;
  }

  // 轮播图
  Widget _swiper() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 1.7686,
      child: swiperPic.length < 1 ? null : Swiper(
        itemBuilder: _swiperBuilder,
        itemCount: swiperPic.length,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
          color: Color.fromRGBO(0, 0, 0, .2),
          activeColor: Color(0xfffa7122),
        )),
        control: SwiperControl(),
        scrollDirection: Axis.horizontal,
        autoplay: true,
        onTap: (index) => print('this is $index click'),
      ),
    );
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return (Image.network(
      swiperPic[index],
      fit: BoxFit.fill,
    ));
  }

  // 直播列表
  Widget _liveTable(count) {
    return Column(
      children: <Widget>[
        _listTableHeader(count),
        _listTableInfo(),
      ]
    );
  }

  // 直播列表头部
  Widget _listTableHeader(count) {
    return Padding(
      padding: EdgeInsets.only(left: dp(6), right: dp(6)),
      child: Row(
        children: <Widget>[
          Container(
            width: dp(20),
            height: dp(30),
            margin: EdgeInsets.only(right: dp(5)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/isLive.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            child: Text('正在直播'),
          ),
          Row(
            children: <Widget>[
              Text('当前',
                style: TextStyle(
                  color: Color(0xff999999),
                ),
              ),
              Text('$count',
                style: TextStyle(
                  color: Color(0xffff7700),
                ),
              ),
              Text('个直播',
                style: TextStyle(
                  color: Color(0xff999999),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: dp(5)),
                child: Image.asset(
                  'lib/images/next.png',
                  height: dp(14),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // 直播列表详情
  Widget _listTableInfo() {
    final liveList = List<Widget>();
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: 12.0
    );

    liveData.forEach((item) {
      liveList.add(
        GestureDetector(
          onTap: () {
            _goToLiveRoom(item);
          },
          child: Padding(
          key: ObjectKey(item['rid']),
          padding: EdgeInsets.all(dp(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: dp(175),
                  height: dp(101.25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(dp(4)),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(item['roomSrc']),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: dp(120),
                          height: dp(18),
                          padding: EdgeInsets.only(right: dp(5)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(dp(4))),
                            gradient: LinearGradient(
                              begin: Alignment(-.4, 0.0),
                              end: Alignment(1, 0.0),
                              colors: <Color>[
                                Color.fromRGBO(0, 0, 0, 0),
                                Color.fromRGBO(0, 0, 0, .6),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Image.asset(
                                'lib/images/hot.png',
                                height: dp(14),
                              ),
                              Padding(padding: EdgeInsets.only(right: dp(3))),
                              Text(
                                item['hn'],
                                style: fontStyle,
                              ),
                            ],
                          ),
                        ),
                        top: 0,
                        right: 0,
                      ),
                      Positioned(
                        child: Container(
                          width: dp(175),
                          height: dp(18),
                          padding: EdgeInsets.only(right: dp(5)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(dp(4)),
                              bottomRight: Radius.circular(dp(4)),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment(0, -.5),
                              end: Alignment(0, 1.3),
                              colors: <Color>[
                                Color.fromRGBO(0, 0, 0, 0),
                                Color.fromRGBO(0, 0, 0, .6),
                              ],
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(left: dp(3))),
                              Image.asset(
                                'lib/images/member.png',
                                height: dp(14),
                              ),
                              Padding(padding: EdgeInsets.only(right: dp(3))),
                              Text(
                                item['nickname'],
                                style: fontStyle,
                              ),
                            ],
                          ),
                        ),
                        bottom: 0,
                        left: 0,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: dp(175),
                  padding: EdgeInsets.fromLTRB(dp(1), dp(4), 0, 0),
                  child: Text(
                    item['roomName'],
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      );
    });

    return Wrap(
      children: liveList,
    );
  }
}
