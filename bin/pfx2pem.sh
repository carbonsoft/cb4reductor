#!/bin/bash

set -u
set -e

. /usr/local/reductor/etc/const

NO_PFX_FOUND="����������� ����� �������� ����������������� ����������� �������, �������� ����� ��������������� �������������� �������, ������ ������� ����� ����������� �� ������: 

	http://minsvyaz.ru/common/upload/Perechen_akkreditovannih_UZ.xls

��� ���������� ��������� ����� �� ���������� ����� �������� ���������������� � ������� ����������� ������� ��������� pkcs12 � ����� $USERDIR � ����������� *.pfx. ����������� ������� � ������ ������������ �� ������ 

	http://docs.carbonsoft.ru/pages/viewpage.action?pageId=42827780

���� � ��� �������� ��������� - $GOTO_SUPPORT."

find_pfx() {
	find $USERDIR -type f -name "*.pfx"
}

convert() {
	PFX="$(find_pfx)"
	[ -z "$PFX" -o ! -s "$PFX" ] && terminate "�� ������� ����� ���������� pfx-���������" 
	${OPENSSL} pkcs12 -in $PFX -out ${USERDIR}/provider.pem -nodes -clcerts || terminate "�� ������� ������� �� $PFX �������� ����, $GOTO_SUPPORT"
	grep -q 'BEGIN PRIVATE KEY' ${USERDIR}/provider.pem || terminate "� provider.pem ����������� �������� ����, $GOTO_SUPPORT"
}

check_pfx_exist() {
	find_pfx | grep -q pfx
}

main() {
	check_pfx_exist || terminate "$NO_PFX_FOUND" 
	ask_custom "��������������" "������" "�������������� �������� ���� �� $(find_pfx)" || exit
	convert || terminate "�� ������� ��������������� pfx � pem"
	show_msg "������� ����������� ���ۣ� �������."
}

${1:-main}
