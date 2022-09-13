Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m" && Green="\033[32m" && Red="\033[31m" && Yellow="\033[33m" && Blue='\033[34m' && Purple='\033[35m' && Ocean='\033[36m' && Black='\033[37m' && Morg="\033[5m" && Reverse="\033[7m" && Font="\033[1m"
Get_IP(){
  ip=$(curl -s ifconfig.me)
}
clientsdomain=$(cat /etc/openvpn/client-template.txt | sed -n 4p | cut -d ' ' -f 2)
get_public_ip=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/")")
clear
echo "IP адрес вашего сервера  $get_public_ip "
echo "IP/Домен используемый в client-template.txt  $clientsdomain "

read -e -p "Хотите синхронизовать параметр remote на сервере y/n? " ans
[[ -z "${ans}" ]] && ans=y
if [[ ${ans} == "y" ]]; then
echo "Введите доменное имя или IP-адрес сервера"
	read -e -p "(нажмите Enter чтобы использовать IP адрес вашего сервера): " domain
	if [[ -z "${domain}" ]]; then
		Get_IP
		domain="${ip}"
	fi
echo "Введите порт(укажите именно тот порт, который использовали при создании сервера!)"
  read -e -p "(нажмите Enter чтобы использовать порт 443): " port
	if [[ -z "${port}" ]]; then
		port="443"
	fi

#Синхронизация конфигураций
sed -i '3d' /root/OVPNConfigs/*.ovpn
sed -i "2a\remote $domain $port" /root/OVPNConfigs/*.ovpn
#Синхронизация client-template.txt
sed -i '4d' /etc/openvpn/client-template.txt
sed -i "3a\remote $domain $port" /etc/openvpn/client-template.txt

echo -e "${Green}Новые айпи адреса успешно прописаны!${Font_color_suffix}"
elif [[ ${ans} == "n" ]]; then
  echo -e "${Error}Отмена..." && exit 1
fi


