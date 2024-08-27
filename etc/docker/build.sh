#!/bin/bash
# 将脚本设置为在命令执行失败时立即退出
set -e

echo "1.切换到测试分支"
# 切换到生产分支
git switch main

project_name="seaurl-drawio"
project_port=19990
project_namespace="drawio"

# 定义aliyun 地址
repository="registry.cn-hangzhou.aliyuncs.com/com-seaurl/${project_name}"

# 执行第一个命令并将结果存储在变量中
commit_hash=$(git rev-parse --short HEAD)
echo "2.显示提交的hash值：${commit_hash}"

echo "3.使用buildx 编译 docker镜像"
# 使用变量作为第二个命令的参数
docker buildx build --platform linux/amd64 -t "${repository}:${commit_hash}" -f Dockerfile . --load

echo "4.登录aliyun docker镜像服务器"
# 登录aliyun docker 镜像库
docker login --username=zhangwei900808@126.com --password=@zhangwei0808 registry.cn-hangzhou.aliyuncs.com

echo "5.推送aliyun docker镜像服务器"
# 推送到aliyun docker 镜像库
docker push "registry.cn-hangzhou.aliyuncs.com/com-seaurl/${project_name}:${commit_hash}"

echo "推送成功！"

echo "6.复制一份master环境的k8s yaml文件，目的是修改yaml文件并应用"
# 复制一份新文件出来
cp etc/k8s/${project_name}.yaml etc/k8s/new_${project_name}.yaml

echo "7.修改上面的yaml文件"
# 修改本地k8s yaml文件
perl -p -i -e "s#<imagename>#${repository}:${commit_hash}#g;s#<podname>#${project_namespace}#g;s#<podport>#${project_port}#g" etc/k8s/new_${project_name}.yaml

echo "8.应用上面的yaml文件"
kubectl create namespace ${project_namespace}
# 执行k8s命令应用上面修改的yaml文件
kubectl apply -f etc/k8s/new_${project_name}.yaml -n ${project_namespace}

echo "9.删除上面的yaml文件"
#删除上面复制出来的文件
rm -rf etc/k8s/new_${project_name}.yaml

echo "10.删除上面编译的docker镜像"
# 获取符合条件的镜像信息，并提取镜像 ID
image_ids=$(docker images | grep "${repository}" | awk '{print $3}')

# 循环删除每个镜像
for image_id in $image_ids; do
    echo "Image ID: ${image_id}"
    docker rmi $image_id
done

echo "发布成功！"

