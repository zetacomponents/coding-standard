.PHONY: test test-report test-fix update-compatibility-patch

PHP_VERSION:=$(shell php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;")
PATCH_FILE="tests/php$(PHP_VERSION)-compatibility.patch"

test: test-report test-fix

test-report: vendor
	@if [ -f "$(PATCH_FILE)" ]; then git apply $(PATCH_FILE) ; fi
	@vendor/bin/phpcs `find tests/input/* | sort` --report=summary --report-file=phpcs.log; diff -u tests/expected_report.txt phpcs.log; if [ $$? -ne 0 ] && [ -f "$(PATCH_FILE)" ]; then git apply -R $(PATCH_FILE) ; exit 1; fi
	@if [ -f "$(PATCH_FILE)" ]; then git apply -R $(PATCH_FILE) ; fi

test-fix: vendor
	@if [ -f "$(PATCH_FILE)" ]; then git apply $(PATCH_FILE) ; fi
	@cp -R tests/input/ tests/input2/
	@vendor/bin/phpcbf tests/input2; diff -u tests/input2 tests/fixed; if [ $$? -ne 0 ]; then rm -rf tests/input2/; if [ -f "$(PATCH_FILE)" ]; then git apply -R $(PATCH_FILE) ; fi; exit 1; fi
	@rm -rf tests/input2/;
	@if [ -f "$(PATCH_FILE)" ]; then git apply -R $(PATCH_FILE) ; fi

vendor: composer.json
	composer update
	touch -c vendor
