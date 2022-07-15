<?php
    header("Content-Type:text/html;charset=utf-8");
    if (!class_exists('redis')) {
        echo 'PHP redis extension was not installed';
        exit;
    }

    //连接
    $redis=new Redis();
    try {
        $redis->connect('127.0.0.1', 6379);
        //$redis->auth('password'); //如果设置了密码，将password更高为你的密码
        //显示版本
        echo "Redis Server version:  ". $redis->info()['redis_version'] ."<br />";

        //保存数据
        $redis->set('key1', 'This is first value');
        echo "Get key1 value: " . $redis->get('key1') ."<br />";

        //删除数据
        $redis->del('key1');
        echo "Get key1 value: " . $redis->get('key1') . "<br />";
    } catch (Exception $e) {
        echo "Cannot connect to Redis server: " .$e->getMessage(). "<br />";
    }

?>
Redis Test tools for <a href="https://lnmp.org" target="_blank">LNMP一键安装包</a> <a href="https://bbs.vpser.net/forum-25-1.html" target="_blank">LNMP支持论坛</a>