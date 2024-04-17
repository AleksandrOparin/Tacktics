#!/bin/bash

# Credentials
source src/Credentials.sh


# Функция кодирует текст
# Получает текст
# Возвращает закодированный текст + контрольную сумму
encodeText() {
  local text=$1
  
  # Шифруем данные
  local encodedText
  encodedText=$(echo "$text" | openssl enc -aes-256-cbc -e -a -pbkdf2 -iter "$ItersCount" -k "$Password")
  
  # Вычисляем контрольную сумму зашифрованных данных
  local checksum
  checksum=$(echo -n "$encodedText" | md5sum | awk '{print $1}')
  
  echo "$encodedText$checksum"
}

# Функция декодирует текст
# Получает текст - закодированный текст + контрольная сумма
# Возвращает декодированный текст и флаг того, совпадает ли контрольная сумма
decodeText() {
  local text=$1
  
  # Читаем зашифрованные данные и контрольную сумму
  local checksum encodedText
  checksum=${text: -32}
  encodedText=${text%"$checksum"}
  
  # Проверяем контрольную сумму
  local calculatedChecksum
  calculatedChecksum=$(echo -n "$encodedText" | md5sum | awk '{print $1}')
  if [[ "$calculatedChecksum" != "$checksum" ]]; then
      return 1
  fi
  
  # Декодируем текст
  local decodedText
  decodedText=$(echo "$encodedText" | openssl enc -aes-256-cbc -d -a -pbkdf2 -iter "$ItersCount" -k "$Password")

  # Возвращаем декодированный текст
  echo "$decodedText"
  
  return 0
}

# Функция декодирует текст, содержащийся в файле
# Получает имя файла
# Возвращает декодированный текст и флаг того, совпадает ли контрольная сумма
decodeTextFromFile() {
  local file=$1
  
  local text
  text=$(cat "$file")
  
  decodeText "$text"
}
