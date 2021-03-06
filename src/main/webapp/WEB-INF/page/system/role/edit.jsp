<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2019/1/21
  Time: 22:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="description" content="">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="format-detection" content="telephone=no">
    <link rel="stylesheet" href="/layui/css/layui.css" media="all">
    <style>
        .frameContent {padding:30px}
        .frameBtn {text-align:center;margin:20px 0px 0px 30px;padding-top:20px;border-top:1px rgb(204,204,204) dashed}
        .funList {float: left;padding: 5px 0px;}
        .role-bor{
            border: 1px solid rgb(230, 230, 230);
            border-radius: 2px;
            /*box-shadow: 0 2px 5px 0 rgba(0,0,0,.1);*/
        }
        .role-title{
            background-color: #f2f2f2;
            padding: 8.3px;
            border-bottom: 1px solid #e6e6e6;
        }
        .role-check{
            padding: 5px 0px;
        }
    </style>
</head>
<body>
<div>
    <form class="layui-form frameContent layui-form-pane" lay-filter="form">
        <input type="hidden" id="id" name="id" />
        <div class="layui-form-item">
            <div class="layui-form-label">角色名称</div>
            <div class="layui-input-inline">
                <input type="text" name="name" required lay-verify="required" placeholder="角色名称" autocomplete="off" class="layui-input" >
            </div>
        </div>

        <div class="layui-form-item">
            <div class="layui-form-label">角色备注</div>
            <div class="layui-input-block">
                <input type="text" name="remark" placeholder="请输入角色备注" autocomplete="off" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <div class="layui-form-label">角色资源</div>
            <div class="layui-input-block funn">
            </div>
        </div>
        <div class="frameBtn">
            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
            <button class="layui-btn" lay-submit lay-filter="submit">保存</button>
        </div>
    </form>
</div>
</body>
<script src="/layui/layui.js" charset="utf-8"></script>
<script>

    var data;
    function child(d) {
        data = d;
        //alert(data);
    }

    var roleId = '${sessionScope.userInfo.roleId}';

    layui.use(['form'], function(){
        var form = layui.form;
        var $ = layui.jquery;

        //表单初始赋值
        form.val('form', {
            "id":data.id
            ,"name":data.name
            ,"remark":data.remark
        });

        var funcids;
        //获取用户角色
        $.ajax({
            url:'/role/findFun',
            type:'post',
            data:{'id':data.id},
            dataType:"json",
            async:false,
            success:function(data){
                //do something
                if(data.code===0){
                    funcids = data.data.funs;
                } else {
                    layer.alert('抱歉，系统繁忙，请稍后再试！',{icon:2});
                }
            },
            error:function(data){
                //do something
                layer.msg('与服务器连接失败',{icon: 2});
            }
        });

        //获取菜单列表
        $.ajax({
            url:'/fun/allFun',
            type:'get',
            dataType:"json",
            async:false,
            beforeSend:function(){
                //console.log(JSON.stringify(data.field));
            },
            success:function(data){
                var funarr = funcids.split(',');
                if(data.code===0){
                    var str = '<div class="role-bor">';

                    var item = data.data;
                    var parent;
                    var childs;

                    for(i = 0;i<item.length;i++) {

                        /**
                         * 父节点
                         */
                        parent = item[i].parent;
                        str += '<div class="layui-hide"><input type="checkbox" name="funs" checked value="' + parent.id + '"/></div>';
                        str += '<p class="role-title">' + parent.name + '</p><div class="role-check">';

                        /**
                         * 子节点
                         */
                        childs = item[i].childs;
                        for (j = 0; j < childs.length; j++) {
                            var d = childs[j].id;
                            d = String(d);
                            if ($.inArray(d, funarr) != -1) {
                                str += '<input type="checkbox" name="funs" checked value="' + childs[j].id + '" title="' + childs[j].name + '" />';
                            } else {
                                str += '<input type="checkbox" name="funs" value="' + childs[j].id + '" title="' + childs[j].name + '" />';
                            }
                        }

                        str += "</div>";
                    }

                    str+='</div>';
                    $('.funn').html(str);
                    form.render('checkbox');

                } else {
                    layer.alert('抱歉，系统繁忙，请稍后再试！',{icon:2});
                }
            },
            error:function(data){
                //do something
                layer.msg('与服务器连接失败',{icon: 2});
            }
        });

        //监听提交
        form.on('submit(submit)',function(formData){

            var checkboxValue="";
            $("input:checkbox[name='funs']:checked").each(function() { // 遍历name=standard的多选框
                if(checkboxValue==0){
                    checkboxValue = $(this).val();
                    return true;
                }
                checkboxValue += ',' + $(this).val();
            });

            if(checkboxValue.length<1){
                layer.alert('最少选择一项',{icon: 2});
                return false;
            }
            formData.field.funs=checkboxValue;
            $.ajax({
                url:'/role/save',
                type:'post',
                data:formData.field,
                dataType:"json",
                beforeSend:function(){
                    //console.log(JSON.stringify(data.field));
                },
                success:function(result){
                    //do something
                    if(result.code===0){
                        var index = parent.layer.getFrameIndex(window.name);//获取当前窗口索引
                        if(roleId === String(data.id)){
                            parent.layer.alert('修改成功', {icon : 1},function () {
                                parent.layer.close(index);
                                parent.parent.window.location.reload();
                                //parent.layui.table.reload('tableList');//重新加载父级tabel数据
                            });
                        }else{
                            parent.layer.msg('修改成功', {icon : 1});
                            parent.layer.close(index);
                            //parent.parent.window.location.reload();
                            parent.layui.table.reload('tableList');//重新加载父级tabel数据
                        }

                    } else {
                        layer.alert(data.msg,{icon:2});
                    }
                },
                error:function(data){
                    //do something
                    layer.msg('与服务器连接失败',{icon: 2});
                }
            });
            return false;
        });
    });
</script>
</html>
