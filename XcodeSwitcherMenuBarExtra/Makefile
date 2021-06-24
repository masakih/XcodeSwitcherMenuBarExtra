// encoding=utf-8

LOCALIZE_FILES=LocalizedStrings.swift

Localizable: $(LOCALIZE_FILES)
	genstrings -s LocalizedString -o ja.lproj $^
	(cd ja.lproj; ${MAKE} $@;)

checkLocalizable:
	(cd ja.lproj; ${MAKE} $@;)
