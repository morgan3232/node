
# Проверка наличия необходимых утилит, установка если отсутствуют
if ! command -v figlet &> /dev/null; then
    echo "figlet не найден. Устанавливаем..."
    sudo apt install -y figlet
fi

if ! command -v whiptail &> /dev/null; then
    echo "whiptail не найден. Устанавливаем..."
    sudo apt install -y whiptail
fi

# Определяем цвета для удобства
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

install_dependencies() {
    echo -e "${GREEN}Устанавливаем необходимые пакеты...${NC}"
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
}

# Вывод приветственного текста с помощью figlet
echo -e "${PINK}$(figlet -w 150 -f standard "SenseiCryptoX")${NC}"

echo "===================================================================================================================================="
echo "Добро пожаловать! Начинаем установку необходимых библиотек, пока подпишись на наши Telegram-каналы для обновлений и поддержки: "
echo ""
echo "SenseiCryptoX - https://t.me/SenseiCryptoX"
echo "SenseiCryptoX - https://t.me/SenseiCryptoX"
echo "===================================================================================================================================="

echo ""

# Определение функции анимации
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r${GREEN}Подгружаем меню${NC}."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}.."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}..."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}"
        sleep 0.3
    done
    echo ""
}

# Вызов функции анимации
animate_loading
echo ""

# Функция для установки ноды
install_node() {
    echo -e "${BLUE}Начинаем установку ноды...${NC}"

    # Обновление и установка зависимостей
    install_dependencies

    # Создание директории для кэша и переход в неё
    mkdir -p ~/pipe/download_cache
    cd ~/pipe

    # Скачиваем файл pop
    wget https://dl.pipecdn.app/v0.2.3/pop

    # Делаем файл исполнимым
    chmod +x pop

    # Создание новой сессии в screen
    screen -S pipe2 -dm

    echo -e "${YELLOW}Введите ваш публичный адрес Solana:${NC}"
    read SOLANA_PUB_KEY
    
    # Запрос значения для RAM
    echo -e "${YELLOW}Введите количество RAM в ГБ (целое число):${NC}"
    read RAM
    
    # Запрос значения для max-disk
    echo -e "${YELLOW}Введите количество max-disk в ГБ (целое число):${NC}"
    read DISK
    
    # Запуск команды с параметрами, с указанием публичного ключа Solana, RAM и max-disk
    screen -S pipe2 -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 3
    screen -S pipe2 -X stuff "e4313e9d866ee3df\n"

    echo -e "${GREEN}Процесс установки и запуска завершён!${NC}"
}

# Функция для проверки статуса ноды
check_status() {
    echo -e "${BLUE}Проверка статуса ноды...${NC}"
    
    cd pipe
    ./pop --status
    cd ..
}

# Функция для проверки поинтов ноды
check_points() {
    echo -e "${BLUE}Проверка поинтов ноды...${NC}"

    cd pipe
    
    ./pop --points
    
    cd ..
}

# Функция для удаления ноды
remove_node() {
    echo -e "${BLUE}Удаляем ноду...${NC}"

     pkill -f pop

    # Завершаем сеанс screen с именем 'pipe2' и удаляем его
    screen -S pipe2 -X quit

    # Удаление файлов ноды
    sudo rm -rf ~/pipe

    echo -e "${GREEN}Нода успешно удалена!${NC}"
}

# Основное меню
CHOICE=$(whiptail --title "Меню действий" \
    --menu "Выберите действие:" 15 50 6 \
    "1" "Установка ноды" \
    "2" "Проверка статуса ноды" \
    "3" "Проверка поинтов ноды" \
    "4" "Удаление ноды" \
    "5" "Выход" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1) 
        install_node
        ;;
    2) 
        check_status
        ;;
    3) 
        check_points
        ;;
    4) 
        remove_node
        ;;
    5)
        echo -e "${CYAN}Выход из программы.${NC}"
        ;;
    *)
        echo -e "${RED}Неверный выбор. Завершение программы.${NC}"
        ;;
esac
