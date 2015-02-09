#!/bin/bash

set -u
set -e

. /usr/local/reductor/etc/const

NO_PFX_FOUND="Обязательно нужно получить квалифицированную электронную подпись, выданную любым аккредитованным удостоверяющим центром, список центров можно просмотреть по адресу: 

	http://minsvyaz.ru/common/upload/Perechen_akkreditovannih_UZ.xls

Для извлечения закрытого ключа из контейнера нужно положить экспортированный с помощью специальной утилиты контейнер pkcs12 в папку $USERDIR с расширением *.pfx. Подробности описаны в статье документации по адресу 

	http://docs.carbonsoft.ru/pages/viewpage.action?pageId=42827780

Если у вас возникли трудности - $GOTO_SUPPORT."

find_pfx() {
	find $USERDIR -type f -name "*.pfx"
}

convert() {
	PFX="$(find_pfx)"
	[ -z "$PFX" -o ! -s "$PFX" ] && terminate "Не удалось найти корректный pfx-контейнер" 
	${OPENSSL} pkcs12 -in $PFX -out ${USERDIR}/provider.pem -nodes -clcerts || terminate "Не удалось извлечь из $PFX закрытый ключ, $GOTO_SUPPORT"
	grep -q 'BEGIN PRIVATE KEY' ${USERDIR}/provider.pem || terminate "В provider.pem отсутствует закрытый ключ, $GOTO_SUPPORT"
}

check_pfx_exist() {
	find_pfx | grep -q pfx
}

main() {
	check_pfx_exist || terminate "$NO_PFX_FOUND" 
	ask_custom "Конвертировать" "Отмена" "Экспортировать закрытый ключ из $(find_pfx)" || exit
	convert || terminate "Не удалось сконвертировать pfx в pem"
	show_msg "Экспорт сертификата прошёл успешно."
}

${1:-main}
