---
title: Java使用websocket和WebRTC实现视频通话
date: 2017-03-11 12:06:23
categories: Java二三事
tags:
	- WebSocket
	- WebRTC
---
最近这段时间折腾了一下WebRTC，这两天终于是抽了时间把WebRTC搞定了，去年就想弄的，但是确实没时间。看了网上的https://apprtc.appspot.com/的例子（可能需要翻墙访问），这个例子是部署在Google App Engine上的应用程序，依赖与GAE的环境，后台的语言是python，而且还依赖Google App Engine Channel API，所以无法在本地运行，也无法扩展。费了一番功夫研读了例子的python端的源代码，决定用Java实现，Tomcat7之后开始支持WebSocket，打算用WebSocket代替Google App Engine Channel API实现前后台的通讯，在整个例子中Java+WebSocket起到的作用是负责客户端之间的通信，并不负责视频的传输，视频的传输依赖于WebRTC。 
<!--more-->

首先WebRTC,这个可以百度一下，大概就是一个音频和视频通讯技术，可以跨平台，只要能用浏览器的基本都可以使用，当然要你的浏览器支持。
  
这里引用了google的js库：<code>channel.js</code>。不过还是下载下来放到本地服务器吧，因为很多地方访问google.com很吃力啊。最开始就是这个js没有加载完郁闷了很久，还一直以为是代码写错了。

另外在进入页面的时候，注意初始化页面js中的一个参数：<code>initiator</code>：如果是创建人这个参数设为false；如果是加入的时候这个设置为true。为true的时候，才会发起视频通话的请求。

**<h2>实现</h2>**

对于前端JS代码及用到的对象大家可以去查看详细的代码介绍，我就贴一个连接的方法。首先建立一个客户端实时获取状态的连接，在GAE的例子上是通过GAE Channel API实现，我在这里用WebSocket实现，代码：

```
function openChannel() {  
     console.log("打开websocket");
     socket = new WebSocket("ws://192.168.1.158:8080/WebRTC/acgist.video/${requestScope.uid}");				
	 socket.onopen = onChannelOpened;
	 socket.onmessage = onChannelMessage;
	 socket.onclose = onChannelClosed;  
	 socket.onerror = onChannelError();
    }  
```

服务端代码很简单，就是收到用户的请求，发送给另外一个用户就可以了，这里处理的其实是用户WebRTC的一些信息，并不是去传输视频，如下：

```
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
 
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

/**
 * @author 李智
 * @date 2017/3/11
 *
 * WebRTC视频通话
 */
 
@ServerEndpoint("/acgist.video/{uid}")
public class AcgistVideo {
    // 最大通话数量
    private static final int MAX_COUNT = 10;
    private static final long MAX_TIME_OUT = 1 * 60 * 1000;
    // 用户和用户的对话映射
    private static final Map<String, String> user_user = Collections.synchronizedMap(new HashMap<String, String>()); 
    // 用户和websocket的session映射
    private static final Map<String, Session> sessions = Collections.synchronizedMap(new HashMap<String, Session>());
     
    /**
     * 打开websocket
     * @param session websocket的session
     * @param uid 打开用户的UID
     */
    @OnOpen
    public void onOpen(Session session, @PathParam("uid")String uid) {
        session.setMaxIdleTimeout(MAX_TIME_OUT);
        sessions.put(uid, session);
    }
 
    /**
     * websocket关闭
     * @param session 关闭的session
     * @param uid 关闭的用户标识
     */
    @OnClose
    public void onClose(Session session, @PathParam("uid")String uid) {
        remove(session, uid);
    }
 
    /**
     * 收到消息
     * @param message 消息内容
     * @param session 发送消息的session
     * @param uid
     */
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("uid")String uid) {
        try {
            if(uid != null && user_user.get(uid) != null && AcgistVideo.sessions.get(user_user.get(uid)) != null) {
                Session osession = sessions.get(user_user.get(uid)); // 被呼叫的session
                if(osession.isOpen())
                    osession.getAsyncRemote().sendText(new String(message.getBytes("utf-8")));
                else
                    this.nowaiting(osession);
            } else {
                this.nowaiting(session);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
     
    /**
     * 没有人在等待
     * @param session 发送消息的session
     */
    private void nowaiting(Session session) {
        session.getAsyncRemote().sendText("{\"type\" : \"nowaiting\"}");
    }
     
    /**
     * 是否可以继续创建通话房间
     * @return 可以：true；不可以false；
     */
    public static boolean canCreate() {
        return sessions.size() <= MAX_COUNT;
    }
     
    /**
     * 判断是否可以加入
     * @param oid 被申请对话的ID
     * @return 如果能加入返回：true；否则返回false；
     */
    public static boolean canJoin(String oid) {
        return !(oid != null && user_user.containsKey(oid) && user_user.get(oid) != null);
    }
     
    /**
     * 添加视频对象
     * @param uid 申请对话的ID
     * @param oid 被申请对话的ID
     * @return 是否是创建者：如果没有申请对话ID为创建者，否则为为加入者。创建者返回：true；加入者返回：false；
     */
    public static boolean addUser(String uid, String oid) {
        if(oid != null && !oid.isEmpty()) {
            AcgistVideo.user_user.put(uid, oid);
            AcgistVideo.user_user.put(oid, uid);
             
            return false;
        } else {
            AcgistVideo.user_user.put(uid, null);
             
            return true;
        }
    }
     
    /**
     * 移除聊天用户
     * @param session 移除的session
     * @param uid 移除的UID
     */
    private static void remove(Session session, String uid) {
        String oid = user_user.get(uid);
         
        if(oid != null) user_user.put(oid, null); // 设置对方无人聊天
         
        sessions.remove(uid); // 异常session
        user_user.remove(uid); // 移除自己
         
        try {
            if(session != null && session.isOpen()) session.close(); // 关闭session
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
 
}
```

自己测试的时候搞个公用的stun服务器弄一弄就好了。不过人多的时候会延迟很就是了，成功截图就不放了，人丑家贫。