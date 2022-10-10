#/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

#安装wget、curl、unzip
${InstallMethod} install unzip wget curl -y > /dev/null 2>&1 
copyright(){
    clear
echo -e "
——————————————————————————————————————————————————————————————————————————————————————————————————————————————————                                                                                                                         
  _|_|                                      _|                                    _|_|_|  _|                      
_|    _|    _|    _|    _|_|_|  _|_|_|    _|_|_|_|  _|    _|  _|_|_|  _|_|      _|              _|_|_|  _|_|_|    
_|  _|_|    _|    _|  _|    _|  _|    _|    _|      _|    _|  _|    _|    _|      _|_|    _|  _|    _|  _|    _|  
_|    _|    _|    _|  _|    _|  _|    _|    _|      _|    _|  _|    _|    _|          _|  _|  _|    _|  _|    _|  
  _|_|  _|    _|_|_|    _|_|_|  _|    _|      _|_|    _|_|_|  _|    _|    _|    _|_|_|    _|    _|_|_|  _|    _|  
                                                                                                    _|            
                                                                          _|_|_|_|_|            _|_|      


                                 ${green}Quantum_Sign 一键安装脚本， 解放双手无脑残障专用 。                           
                                                                                           ----v999.999 ${plain}                                                                                      
——————————————————————————————————————————————————————————————————————————————————————————————————————————————————
"
}
quit(){
exit
}

install_Quantum_Sign(){
echo -e "${red}开始自动化安装,请双手离开键盘鼠标${plain}"
# apt install git -y || yum install git -y > /dev/null 
echo -e "${green}正在拉取Quantum_Sign主程序等文件,体积100多M，请耐心等待···${plain}"
mkdir -p  /root/Quantum_Sign && cd /root/Quantum_Sign
echo -e "${green}请选择机器类型···${plain}"
read -p "国外机器请按回车继续，国内机器请输入1 [回车默认国外机器]: " China && printf "\n"
	if [ "$China" = "1" ] ;then
    echo -e "${green}你的机器为国内机器，下载时间将会很漫长···${plain}"
    wget http://180.76.137.96:999/down/zPOvpRkBprnH && mv zPOvpRkBprnH Quantum_Sign.zip    
else 
    wget https://github.com/Bulletgod/Quantum_Sign/releases/download/v1.0.1/Quantum_Sign.zip Quantum_Sign.zip

fi

echo -e "${green}下载完成，正在解压缩···${plain}"
unzip Quantum_Sign.zip > /dev/null 2>&1 
echo -e "${green}解压缩完成，删除压缩包···${plain}"
rm  -f Quantum_Sign.zip > /dev/null 2>&1 
echo -e "${green}删除压缩包完成，开始安装docker镜像···${plain}"


#read -p "请输入Quantum_Sign主程序希望使用的端口号: " portinfo && printf "\n"

#修改主程序配置文件 ，端口

cat > /root/Quantum_Sign/WskeyConvert/appsettings.json << EOF
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  //服务监听端口
  "HostPort": 8899,
  // sign 服务地址
  "SignBaseUrl": "http://172.17.0.1:8014"
}

EOF

#修改端口


read -p "请输入Quantum_Sign主程序希望使用的端口号[回车键默认 8899]: " portinfo && printf "\n"
	if [ ! -n "$portinfo" ];then
    sed -i "10c \ \"HostPort\": \"8899\"," /root/Quantum_Sign/WskeyConvert/appsettings.json
else
    sed -i "10c \ \"HostPort\": \"${portinfo}\"," /root/Quantum_Sign/WskeyConvert/appsettings.json
fi



#安装docker镜像
echo -e  "${green}开始拉取dotnet/sdk镜像文件，镜像大约650兆大，请耐心等待...${plain}"

docker run -d \
  -v /root/Quantum_Sign/WskeyConvert:/app/ \
  -v /etc/localtime:/etc/localtime \
   -w /app \
  --privileged=true \
  --net host \
  --restart=unless-stopped \
  --name WskeyConvert \
  mcr.microsoft.com/dotnet/sdk:5.0 dotnet Quantum.WskeyConvert.dll


echo -e  "${green}开始拉取openjdk镜像文件，镜像大约85兆大，请耐心等待...${plain}"

docker run -d --restart=always -p 8014:8014 -v /root/Quantum_Sign/jdSign/jar:/jar -v /root/Quantum_Sign/jdSign/jd:/jd --name jdSign openjdk:8-jre-alpine java -jar /jar/unidbg-server-1.0.0.jar


#创建并启动容器
echo -e  "${green}重启并查看容器运行情况...${plain}"
docker restart WskeyConvert
echo -e  "${green}WskeyConvert重启完成...${plain}"
docker restart jdSign
echo -e  "${green}jdSign重启完成...${plain}"
docker ps
echo -e  "${green}查看docker运行情况...${plain}"

#放行防火墙端口
echo -e  "${green}开启服务需的安全组端口...${plain}"
firewall-cmd --zone=public --add-port=8014/tcp --permanent
firewall-cmd --zone=public --add-port=${portinfo}/tcp --permanent
firewall-cmd --reload


echo -e "
———————————————————————————————————————————————————————————————————————————————————

${green}安装重启完毕,添加量子变量
        变量名称：WskeyConvertService
        变量值：http://IP:${portinfo}/api/open/ConvertWskey  
                                                  脚本执行完毕，祝你早日炸鸡.....${plain}
———————————————————————————————————————————————————————————————————————————————————
" 
}





#删除容器
uninstall_Quantum_Sign(){
echo -e  "${green}开始卸载容器...${plain}"
docker rm -f WskeyConvert
echo -e  "${green}WskeyConvert卸载完成...${plain}"
docker rm -f jdSign
echo -e  "${green}jdSign卸载完成...${plain}"
rm -rf /root/Quantum_Sign
echo -e "${green}Quantum_Sign已卸载，脚本自动退出，请手动删除WskeyConvert和jdSign的镜像。${plain}"
exit 0
}

menu() {
  echo -e "\
${green}0.${plain} 退出脚本
${green}1.${plain} 安装Quantum_Sign
${green}2.${plain} 卸载Quantum_Sign
"



  read -p "请输入数字 :" num
  case "$num" in
  0)
    quit
    ;;
  1)
    install_Quantum_Sign
    ;;
  2)
    uninstall_Quantum_Sign
    ;;	    
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-2]"
    sleep 5s
    menu
    ;;
  esac
}

copyright

menu

