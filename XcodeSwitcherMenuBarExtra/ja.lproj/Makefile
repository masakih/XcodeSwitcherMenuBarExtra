
MV=/bin/mv
SED=/usr/bin/sed
ICONV=/usr/bin/iconv

Localize_template=Localizable.strings.sed
temp_file=l.text
target_enc=utf-8

Localizable: Localizable.strings
	${ICONV} -f utf-16 -t ${target_enc} $< | ${SED} -f ${Localize_template} > ${temp_file}
	${MV} ${temp_file} $<

checkLocalizable:
	plutil Localizable.strings

