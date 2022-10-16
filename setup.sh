#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
  echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1

sudo apt update && sudo apt install ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
cd $HOME
rm -rf subspace*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-2a-2022-oct-06/subspace-node-ubuntu-x86_64-gemini-2a-2022-oct-06
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-2a-2022-oct-06/subspace-farmer-ubuntu-x86_64-gemini-2a-2022-oct-06
chmod +x subspace*
mv subspace* /usr/local/bin/

systemctl stop subspaced subspaced-farmer &>/dev/null
rm -rf ~/.local/share/subspace*

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/subspace-node --chain gemini-2a --execution wasm --state-pruning archive --validator --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/subspace-farmer farm --reward-address $SUBSPACE_WALLET --plot-size $PLOT_SIZE
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


mv $HOME/subspaced* /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer

echo -e "\n\e[93mSubspace Gemini II\e[0m"
if [ "$language" = "uk" ]; then
  echo -e '\n\e[94mСтатус ноди\e[0m\n' && sleep 1
  if [[ `service subspaced status | grep active` =~ "running" ]]; then
    echo -e "Ваша Subspace нода \e[92mвстановлена та працює\e[0m!"
    echo -e "Перевірити статус Вашої ноди можна командою \e[92mservice subspaced status\e[0m"
    echo -e "Натисність \e[92mQ\e[0m щоб вийти з статус меню"
  else
    echo -e "Ваша Subspace нода \e[91mбула встановлена неправильно\e[39m, виконайте перевстановлення."
  fi
  sleep 2
  echo -e '\n\e[94mFarmer статус\e[0m\n' && sleep 1
  if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
    echo -e "Ваш Subspace farmer \e[92mвстановлений та працює\e[0m!"
    echo -e "Перевірити статус Вашого farmer можна командою \e[92mservice subspaced-farmer status\e[0m"
    echo -e "Натисність \e[92mQ\e[0m щоб вийти з статус меню"
  else
    echo -e "Ваш Subspace farmer \e[91mбув встановлений неправильно\e[39m, виконайте перевстановлення."
  fi
else
  echo -e '\n\e[94mNode Status\e[0m\n' && sleep 1
  if [[ `service subspaced status | grep active` =~ "running" ]]; then
    echo -e "Your Subspace node \e[92msuccessfully installed and running\e[0m!"
    echo -e "Check your node status: \e[92mservice subspaced status\e[0m"
    echo -e "Press \e[92mQ\e[0m to exit menu"
  else
    echo -e "Your Subspace Node \e[91mwas not installed correctly\e[39m, please reinstall."
  fi
  sleep 2
  echo -e '\n\e[94mFarmer status\e[0m\n' && sleep 1
  if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
    echo -e "Your Subspace farmer \e[92msuccessfully installed and running\e[0m!"
    echo -e "Check your farmer status: \e[92mservice subspaced-farmer status\e[0m"
    echo -e "Press \e[92mQ\e[0m to exit menu"
  else
    echo -e "Your Subspace Farmer \e[91mwas not installed correctly\e[39m, please reinstall."
  fi
fi